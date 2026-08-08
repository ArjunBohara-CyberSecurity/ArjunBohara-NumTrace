#!/usr/bin/env bash

VERSION="1.0.0"

SCRIPT_PATH=${BASH_SOURCE[0]}
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)

NUMTRACE_SCRIPT_DIR=$SCRIPT_DIR

. "$SCRIPT_DIR/lib/utils.sh"
. "$SCRIPT_DIR/lib/cache.sh"
. "$SCRIPT_DIR/lib/dependencies.sh"
. "$SCRIPT_DIR/lib/phone.sh"
. "$SCRIPT_DIR/lib/search.sh"
. "$SCRIPT_DIR/lib/business.sh"
. "$SCRIPT_DIR/lib/documents.sh"
. "$SCRIPT_DIR/lib/reputation.sh"
. "$SCRIPT_DIR/lib/correlation.sh"
. "$SCRIPT_DIR/lib/timeline.sh"
. "$SCRIPT_DIR/lib/report.sh"

NUMTRACE_REPORT_DIR="$SCRIPT_DIR/reports"
NUMTRACE_CONFIG_FILE="${NUMTRACE_CONFIG_FILE:-$HOME/.config/numtrace/config}"
NUMTRACE_OUTPUT_JSON=0
NUMTRACE_OUTPUT_QUIET=0
NUMTRACE_NO_COLOR=0
NUMTRACE_OFFLINE=0
NUMTRACE_CLEAR_CACHE=0
NUMTRACE_BATCH_FILE=
NUMTRACE_COUNTRY=
NUMTRACE_TARGET=
NUMTRACE_MODE=analyze
NUMTRACE_SHOW_HELP=0
NUMTRACE_SHOW_VERSION=0
NUMTRACE_SHOW_PRIVACY=0
NUMTRACE_SHOW_CONFIG=0
NUMTRACE_SELF_AUDIT=0
NUMTRACE_CHECK_DEPS=0

NUMTRACE_TMPDIR=

cleanup() {
  if [ -n "$NUMTRACE_TMPDIR" ] && [ -d "$NUMTRACE_TMPDIR" ]; then
    rm -rf -- "$NUMTRACE_TMPDIR"
  fi
}

trap cleanup INT TERM EXIT

load_config_file() {
  if [ -f "$NUMTRACE_CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$NUMTRACE_CONFIG_FILE"
  fi
}

print_banner() {
  numtrace_print_banner "$VERSION"
}

print_help() {
  cat <<EOF
ArjunBohara-NumTrace v$VERSION
Map the Public Footprint.

Usage:
  ./numtrace.sh [OPTIONS] <PHONE>
  ./numtrace.sh --batch numbers.txt

Options:
  --country CC       Country context for ambiguous numbers
  --json             Emit machine-readable JSON
  --quiet            Reduce console output
  --no-color         Disable ANSI color
  --report DIR       Write reports to DIR
  --batch FILE       Analyze phone numbers from FILE
  --offline          Disable network providers
  --check-deps       Check local dependencies
  --clear-cache      Remove cached responses
  --config           Show configuration guidance
  --privacy          Show privacy guidance
  --self-audit       Summarize public exposure
  --help             Show this help
  --version          Show version

Examples:
  ./numtrace.sh +919876543210
  ./numtrace.sh --country IN +919876543210
  ./numtrace.sh --json +919876543210
  ./numtrace.sh --batch numbers.txt
EOF
}

print_version() {
  printf 'ArjunBohara-NumTrace v%s\n' "$VERSION"
}

print_privacy() {
  cat <<EOF
ArjunBohara-NumTrace privacy model

External data:
  - Optional public search requests
  - Only if you run a provider-backed search mode

Cached data:
  - Normalized numbers
  - Provider responses
  - Generated reports

Storage:
  - Cache: ${NUMTRACE_CACHE_DIR:-$HOME/.cache/numtrace}
  - Config: $NUMTRACE_CONFIG_FILE
  - Reports: $NUMTRACE_REPORT_DIR

Controls:
  - Use --offline to disable external providers
  - Use --clear-cache to delete cached responses
  - Edit the config file to change search behavior
EOF
}

print_config() {
  cat <<EOF
NumTrace configuration

Config file:
  $NUMTRACE_CONFIG_FILE

Example keys:
  NUMTRACE_CACHE_TTL="86400"
  NUMTRACE_SEARCH_PROVIDERS="duckduckgo"
  NUMTRACE_SEARCH_DELAY="1"

Create it from:
  $SCRIPT_DIR/config/config.example
EOF
}

print_self_audit() {
  phone_input=$1
  country=$2
  numtrace_analyze_phone "$phone_input" "$country" || true
  numtrace_search_number "$NUMTRACE_NORMALIZED" "$NUMTRACE_NATIONAL" "$NUMTRACE_COUNTRY" "$NUMTRACE_COUNTRY_CODE"
  numtrace_build_business_findings
  numtrace_build_document_findings
  numtrace_build_reputation_findings
  numtrace_build_timeline_findings
  numtrace_build_correlation_findings
  exposure=$(numtrace_public_exposure_level)
  cat <<EOF
## PUBLIC EXPOSURE

Web pages: $NUMTRACE_SEARCH_COUNT
Documents: $NUMTRACE_DOCUMENT_COUNT
Business listings: $NUMTRACE_BUSINESS_COUNT
News mentions: $NUMTRACE_NEWS_COUNT

Exposure:
$exposure

Recommendations:
  - Review old public contact pages
  - Remove unnecessary phone-number exposure
  - Review public documents
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --help|-h)
        NUMTRACE_SHOW_HELP=1
        return 0
        ;;
      --version|-V)
        NUMTRACE_SHOW_VERSION=1
        return 0
        ;;
      --json)
        NUMTRACE_OUTPUT_JSON=1
        ;;
      --quiet)
        NUMTRACE_OUTPUT_QUIET=1
        ;;
      --no-color)
        NUMTRACE_NO_COLOR=1
        ;;
      --offline)
        NUMTRACE_OFFLINE=1
        ;;
      --report)
        if [ $# -lt 2 ]; then
          printf 'Missing value for --report\n' >&2
          return 2
        fi
        shift
        NUMTRACE_REPORT_DIR=$1
        ;;
      --batch)
        if [ $# -lt 2 ]; then
          printf 'Missing value for --batch\n' >&2
          return 2
        fi
        shift
        NUMTRACE_BATCH_FILE=$1
        ;;
      --country)
        if [ $# -lt 2 ]; then
          printf 'Missing value for --country\n' >&2
          return 2
        fi
        shift
        NUMTRACE_COUNTRY=$1
        ;;
      --check-deps)
        NUMTRACE_CHECK_DEPS=1
        ;;
      --clear-cache)
        NUMTRACE_CLEAR_CACHE=1
        ;;
      --privacy)
        NUMTRACE_SHOW_PRIVACY=1
        ;;
      --config)
        NUMTRACE_SHOW_CONFIG=1
        ;;
      --self-audit)
        NUMTRACE_SELF_AUDIT=1
        ;;
      --)
        shift
        if [ $# -gt 0 ]; then
          NUMTRACE_TARGET=$1
        fi
        break
        ;;
      -*)
        printf 'Unknown option: %s\n' "$1" >&2
        return 2
        ;;
      *)
        NUMTRACE_TARGET=$1
        ;;
    esac
    shift
  done
  return 0
}

run_single_target() {
  target=$1
  country=$2
  numtrace_analyze_phone "$target" "$country" || return 1
  if [ "$NUMTRACE_OFFLINE" -eq 0 ]; then
    numtrace_search_number "$NUMTRACE_NORMALIZED" "$NUMTRACE_NATIONAL" "$NUMTRACE_COUNTRY" "$NUMTRACE_COUNTRY_CODE"
  else
    NUMTRACE_SEARCH_RESULTS=
    NUMTRACE_SEARCH_COUNT=0
    NUMTRACE_NEWS_COUNT=0
  fi
  numtrace_build_business_findings
  numtrace_build_document_findings
  numtrace_build_reputation_findings
  numtrace_build_timeline_findings
  numtrace_build_correlation_findings
  numtrace_generate_report "$NUMTRACE_REPORT_DIR" "$NUMTRACE_TARGET_INPUT" "$NUMTRACE_NORMALIZED"
  return 0
}

run_batch() {
  file=$1
  if [ ! -f "$file" ]; then
    log_error "Batch file not found: $file"
    return 1
  fi
  mkdir -p -- "$NUMTRACE_REPORT_DIR"
  line_no=0
  while IFS= read -r line || [ -n "$line" ]; do
    line_no=$((line_no + 1))
    case "$line" in
      ''|\#*)
        continue
        ;;
    esac
    NUMTRACE_TARGET_INPUT=$line
    if run_single_target "$line" "$NUMTRACE_COUNTRY"; then
      log_ok "Batch item $line_no completed"
    else
      log_warn "Batch item $line_no failed, continuing"
    fi
  done < "$file"
}

interactive_menu() {
  print_banner
  cat <<EOF
[1] Analyze phone number
[2] Analyze from file
[3] Batch analysis
[4] Configuration
[5] Dependency check
[6] Help
[7] About
[0] Exit
EOF
  printf 'Select an option: '
  IFS= read -r choice
  case "$choice" in
    1)
      printf 'Phone number: '
      IFS= read -r phone
      run_single_target "$phone" "$NUMTRACE_COUNTRY"
      ;;
    2|3)
      printf 'File path: '
      IFS= read -r path
      run_batch "$path"
      ;;
    4)
      print_config
      ;;
    5)
      numtrace_check_dependencies
      ;;
    6)
      print_help
      ;;
    7)
      print_version
      ;;
    *)
      exit 0
      ;;
  esac
}

main() {
  load_config_file
  parse_args "$@" || exit $?

  if [ "$NUMTRACE_NO_COLOR" -eq 1 ]; then
    numtrace_disable_color
  fi

  if [ "$NUMTRACE_SHOW_HELP" -eq 1 ]; then
    print_help
    return 0
  fi
  if [ "$NUMTRACE_SHOW_VERSION" -eq 1 ]; then
    print_version
    return 0
  fi
  if [ "$NUMTRACE_SHOW_PRIVACY" -eq 1 ]; then
    print_privacy
    return 0
  fi
  if [ "$NUMTRACE_SHOW_CONFIG" -eq 1 ]; then
    print_config
    return 0
  fi
  if [ "$NUMTRACE_CHECK_DEPS" -eq 1 ]; then
    numtrace_check_dependencies
    return 0
  fi
  if [ "$NUMTRACE_CLEAR_CACHE" -eq 1 ]; then
    numtrace_cache_clear
    log_ok "Cache cleared"
    return 0
  fi
  if [ "$NUMTRACE_SELF_AUDIT" -eq 1 ]; then
    [ -n "$NUMTRACE_TARGET" ] || { log_error "Self-audit requires a phone number"; return 1; }
    print_banner
    print_self_audit "$NUMTRACE_TARGET" "$NUMTRACE_COUNTRY"
    return 0
  fi

  if [ -n "$NUMTRACE_BATCH_FILE" ]; then
    run_batch "$NUMTRACE_BATCH_FILE"
    return $?
  fi

  if [ -n "$NUMTRACE_TARGET" ]; then
    if [ "$NUMTRACE_OUTPUT_QUIET" -eq 0 ] && [ "$NUMTRACE_OUTPUT_JSON" -eq 0 ]; then
      print_banner
    fi
    if run_single_target "$NUMTRACE_TARGET" "$NUMTRACE_COUNTRY"; then
      if [ "$NUMTRACE_OUTPUT_JSON" -eq 1 ]; then
        numtrace_report_json_stdout
      elif [ "$NUMTRACE_OUTPUT_QUIET" -eq 0 ]; then
        numtrace_report_print_summary
      fi
      return 0
    fi
    return 1
  fi

  interactive_menu
}

main "$@"
