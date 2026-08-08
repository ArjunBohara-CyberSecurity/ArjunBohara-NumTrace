#!/usr/bin/env bash

NUMTRACE_COLOR_GREEN=''
NUMTRACE_COLOR_YELLOW=''
NUMTRACE_COLOR_RED=''
NUMTRACE_COLOR_BLUE=''
NUMTRACE_COLOR_RESET=''

numtrace_disable_color() {
  NUMTRACE_COLOR_GREEN=''
  NUMTRACE_COLOR_YELLOW=''
  NUMTRACE_COLOR_RED=''
  NUMTRACE_COLOR_BLUE=''
  NUMTRACE_COLOR_RESET=''
}

numtrace_enable_color() {
  if [ -t 1 ] && [ "${TERM:-}" != 'dumb' ]; then
    NUMTRACE_COLOR_GREEN=$(printf '\033[32m')
    NUMTRACE_COLOR_YELLOW=$(printf '\033[33m')
    NUMTRACE_COLOR_RED=$(printf '\033[31m')
    NUMTRACE_COLOR_BLUE=$(printf '\033[34m')
    NUMTRACE_COLOR_RESET=$(printf '\033[0m')
  fi
}

numtrace_init_colors() {
  if [ "${NUMTRACE_NO_COLOR:-0}" -eq 0 ]; then
    numtrace_enable_color
  else
    numtrace_disable_color
  fi
}

numtrace_print_banner() {
  version=$1
  numtrace_init_colors
  cat <<EOF
██████╗ ██████╗      ██╗██╗   ██╗█████╗   ██╗
██╔══██╗██╔══██╗     ██║██║   ██║██╔══██╗  ██║
███████║██████╔╝     ██║██║   ██║██║  ██║  ██║
██╔══██║██╔══██╗██   ██║██║   ██║██║  ██║  ██║
██║  ██║██║  ██║╚█████╔╝╚██████╔╝╚█████╔╝  ██║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚════╝  ╚═════╝  ╚════╝   ╚═╝

    A R J U N B O H A R A - N U M T R A C E
          Phone Intelligence Framework

Version: $version
Platform: $(numtrace_platform_name)
Mode: Public OSINT
Tagline: Map the Public Footprint.
EOF
}

numtrace_platform_name() {
  if [ -n "${PREFIX:-}" ]; then
    printf 'Termux / Android'
    return 0
  fi
  uname_s=$(uname -s 2>/dev/null || printf unknown)
  case "$uname_s" in
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        printf 'WSL'
      else
        printf 'Linux'
      fi
      ;;
    Darwin)
      printf 'macOS'
      ;;
    *)
      printf '%s' "$uname_s"
      ;;
  esac
}

numtrace_have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

numtrace_now_utc() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

numtrace_today() {
  date -u '+%Y-%m-%d'
}

numtrace_trim() {
  s=$1
  s=${s#"${s%%[![:space:]]*}"}
  s=${s%"${s##*[![:space:]]}"}
  printf '%s' "$s"
}

numtrace_json_escape() {
  printf '%s' "$1" | sed \
    -e 's/\\/\\\\/g' \
    -e 's/"/\\"/g' \
    -e 's/\r/ /g' \
    -e 's/\t/ /g' \
    -e ':a;N;$!ba;s/\n/\\n/g'
}

numtrace_sanitize_filename() {
  printf '%s' "$1" | tr -cd 'A-Za-z0-9+._-'
}

numtrace_urlencode() {
  s=$1
  out=
  i=0
  while [ $i -lt ${#s} ]; do
    c=${s:$i:1}
    case "$c" in
      [a-zA-Z0-9.~_-])
        out=$out$c
        ;;
      ' ')
        out=$out%20
        ;;
      *)
        printf -v hex '%%%02X' "'$c"
        out=$out$hex
        ;;
    esac
    i=$((i + 1))
  done
  printf '%s' "$out"
}

numtrace_urldecode() {
  s=$1
  s=${s//+/ }
  s=${s//%/\\x}
  printf '%b' "$s"
}

numtrace_url_domain() {
  url=$1
  printf '%s' "$url" | sed -n 's,^[a-zA-Z][a-zA-Z0-9+.-]*://\([^/]*\).*,\1,p' | sed 's/^www\.//'
}

numtrace_line_to_one_line() {
  printf '%s' "$1" | tr '\r\n' '  ' | sed 's/[[:space:]][[:space:]]*/ /g'
}

numtrace_join_lines() {
  first=1
  while IFS= read -r line || [ -n "$line" ]; do
    if [ $first -eq 1 ]; then
      first=0
    else
      printf '\n'
    fi
    printf '%s' "$line"
  done
}

numtrace_write_file() {
  path=$1
  content=$2
  umask 077
  printf '%s' "$content" > "$path"
}

numtrace_http_fetch() {
  url=$1
  outfile=$2
  timeout=${3:-20}
  retries=${4:-2}
  ua=${5:-ArjunBohara-NumTrace/1.0.0}
  if numtrace_have_cmd curl; then
    curl -L --silent --show-error --fail \
      --connect-timeout 10 \
      --max-time "$timeout" \
      --retry "$retries" \
      --retry-delay 1 \
      -A "$ua" \
      "$url" -o "$outfile"
    return $?
  fi
  if numtrace_have_cmd wget; then
    wget -q -T "$timeout" -O "$outfile" "$url"
    return $?
  fi
  return 127
}

numtrace_sleep() {
  secs=${1:-1}
  sleep "$secs"
}

log_info() {
  printf '%s→%s %s\n' "$NUMTRACE_COLOR_BLUE" "$NUMTRACE_COLOR_RESET" "$*"
}

log_ok() {
  printf '%s✓%s %s\n' "$NUMTRACE_COLOR_GREEN" "$NUMTRACE_COLOR_RESET" "$*"
}

log_warn() {
  printf '%s!%s %s\n' "$NUMTRACE_COLOR_YELLOW" "$NUMTRACE_COLOR_RESET" "$*"
}

log_error() {
  printf '%s✗%s %s\n' "$NUMTRACE_COLOR_RED" "$NUMTRACE_COLOR_RESET" "$*" >&2
}
