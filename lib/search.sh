#!/usr/bin/env bash

NUMTRACE_SEARCH_RESULTS=
NUMTRACE_SEARCH_COUNT=0
NUMTRACE_NEWS_COUNT=0
NUMTRACE_DOCUMENT_COUNT=0
NUMTRACE_BUSINESS_COUNT=0
NUMTRACE_REPUTATION_COUNT=0

NUMTRACE_SEARCH_PROVIDERS="${NUMTRACE_SEARCH_PROVIDERS:-duckduckgo}"
NUMTRACE_SEARCH_DELAY="${NUMTRACE_SEARCH_DELAY:-1}"

numtrace_load_provider_modules() {
  if [ -f "$NUMTRACE_SCRIPT_DIR/providers/search_duckduckgo.sh" ]; then
    # shellcheck disable=SC1090
    . "$NUMTRACE_SCRIPT_DIR/providers/search_duckduckgo.sh"
  fi
}

numtrace_search_queries_from_number() {
  normalized=$1
  national=$2
  local_queries=
  seen=
  add_query() {
    q=$1
    case "
$seen
" in
      *"
$q
"*) return 0 ;;
    esac
    seen="$seen
$q"
    if [ -z "$local_queries" ]; then
      local_queries=$q
    else
      local_queries="$local_queries
$q"
    fi
  }
  add_query "$normalized"
  digits=${normalized#+}
  add_query "$digits"
  if [ -n "$national" ] && [ "$national" != 'UNKNOWN' ]; then
    add_query "$national"
  fi
  if [ -n "$digits" ] && [ "${#digits}" -gt 4 ]; then
    add_query "${digits#?}"
  fi
  printf '%s\n' "$local_queries"
}

numtrace_result_type_from_url() {
  url=$1
  case "$url" in
    *pdf|*.pdf|*.doc|*.docx|*.txt|*.csv)
      printf 'DOCUMENT'
      ;;
    *news*|*article*|*press*)
      printf 'NEWS'
      ;;
    *facebook*|*linkedin*|*instagram*|*x.com*|*twitter.com*)
      printf 'SOCIAL'
      ;;
    *maps*|*business*|*directory*|*yellowpages*|*justdial*|*yelp*|*foursquare*)
      printf 'BUSINESS'
      ;;
    *)
      printf 'WEBSITE'
      ;;
  esac
}

numtrace_result_category_from_fields() {
  type=$1
  url=$2
  snippet=$3
  lower=$(printf '%s %s' "$url" "$snippet" | tr '[:upper:]' '[:lower:]')
  case "$lower" in
    *pdf*|*.doc*|*.txt*|*.csv*) printf 'DOCUMENT' ;;
    *news*|*press*|*article*) printf 'NEWS' ;;
    *scam*|*spam*|*complaint*|*caller*|*who-calls*|*whocallsme*|*tellows*|*800notes*|*shouldianswer*) printf 'OTHER' ;;
    *maps*|*business*|*contact*|*directory*|*yellowpages*|*justdial*|*yelp*) printf 'BUSINESS' ;;
    *)
      printf '%s' "$type"
      ;;
  esac
}

numtrace_search_add_result() {
  provider=$1
  type=$2
  title=$3
  url=$4
  domain=$5
  snippet=$6
  date=$7
  if [ -z "$url" ]; then
    return 0
  fi
  case "
$NUMTRACE_SEARCH_RESULTS
" in
    *"
$url
"*)
      return 0
      ;;
  esac
  title=$(numtrace_line_to_one_line "$title")
  snippet=$(numtrace_line_to_one_line "$snippet")
  category=$(numtrace_result_category_from_fields "$type" "$url" "$snippet")
  record=$(printf '%s\t%s\t%s\t%s\t%s\t%s\t%s' "$provider" "$category" "$title" "$url" "$domain" "$snippet" "$date")
  if [ -z "$NUMTRACE_SEARCH_RESULTS" ]; then
    NUMTRACE_SEARCH_RESULTS=$record
  else
    NUMTRACE_SEARCH_RESULTS="$NUMTRACE_SEARCH_RESULTS
$record"
  fi
  NUMTRACE_SEARCH_COUNT=$((NUMTRACE_SEARCH_COUNT + 1))
  case "$category" in
    NEWS) NUMTRACE_NEWS_COUNT=$((NUMTRACE_NEWS_COUNT + 1)) ;;
    DOCUMENT) NUMTRACE_DOCUMENT_COUNT=$((NUMTRACE_DOCUMENT_COUNT + 1)) ;;
    BUSINESS) NUMTRACE_BUSINESS_COUNT=$((NUMTRACE_BUSINESS_COUNT + 1)) ;;
  esac
}

numtrace_search_provider_run() {
  provider=$1
  query=$2
  script="$NUMTRACE_SCRIPT_DIR/providers/search_${provider}.sh"
  if [ ! -f "$script" ]; then
    log_warn "Provider unavailable: $provider"
    return 0
  fi
  # shellcheck disable=SC1090
  . "$script"
  func="numtrace_provider_${provider}"
  if ! declare -F "$func" >/dev/null 2>&1; then
    log_warn "Provider unavailable: $provider"
    return 0
  fi
  "$func" "$query"
}

numtrace_search_number() {
  normalized=$1
  national=$2
  country=${3:-}
  calling_code=${4:-}
  NUMTRACE_SEARCH_RESULTS=
  NUMTRACE_SEARCH_COUNT=0
  NUMTRACE_NEWS_COUNT=0
  NUMTRACE_DOCUMENT_COUNT=0
  NUMTRACE_BUSINESS_COUNT=0
  load_provider_modules
  queries=$(numtrace_search_queries_from_number "$normalized" "$national")
  providers=$(printf '%s' "$NUMTRACE_SEARCH_PROVIDERS" | tr ',' '\n')
  while IFS= read -r q || [ -n "$q" ]; do
    [ -n "$q" ] || continue
    while IFS= read -r provider || [ -n "$provider" ]; do
      [ -n "$provider" ] || continue
      if [ "$NUMTRACE_OFFLINE" -eq 1 ]; then
        continue
      fi
      numtrace_search_provider_run "$provider" "$q"
      numtrace_sleep "$NUMTRACE_SEARCH_DELAY"
    done <<EOF
$providers
EOF
  done <<EOF
$queries
EOF
  return 0
}

numtrace_public_exposure_level() {
  score=0
  score=$((score + NUMTRACE_SEARCH_COUNT))
  score=$((score + NUMTRACE_DOCUMENT_COUNT * 2))
  score=$((score + NUMTRACE_BUSINESS_COUNT * 2))
  score=$((score + NUMTRACE_NEWS_COUNT * 2))
  if [ "$score" -ge 16 ]; then
    printf 'HIGH'
  elif [ "$score" -ge 6 ]; then
    printf 'MEDIUM'
  elif [ "$score" -gt 0 ]; then
    printf 'LOW'
  else
    printf 'UNKNOWN'
  fi
}
