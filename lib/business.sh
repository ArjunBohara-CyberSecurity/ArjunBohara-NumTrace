#!/usr/bin/env bash

NUMTRACE_BUSINESS_RESULTS=

numtrace_business_add() {
  source=$1
  url=$2
  title=$3
  snippet=$4
  if [ -z "$NUMTRACE_BUSINESS_RESULTS" ]; then
    NUMTRACE_BUSINESS_RESULTS=$(printf '%s\t%s\t%s\t%s' "$source" "$url" "$title" "$snippet")
  else
    NUMTRACE_BUSINESS_RESULTS="$NUMTRACE_BUSINESS_RESULTS
$(printf '%s\t%s\t%s\t%s' "$source" "$url" "$title" "$snippet")"
  fi
}

numtrace_build_business_findings() {
  NUMTRACE_BUSINESS_RESULTS=
  if [ -z "$NUMTRACE_SEARCH_RESULTS" ]; then
    NUMTRACE_BUSINESS_COUNT=0
    return 0
  fi
  while IFS=$(printf '\t') read -r provider category title url domain snippet date; do
    case "$category" in
      BUSINESS)
        numtrace_business_add "$provider" "$url" "$title" "$snippet"
        ;;
    esac
    lower=$(printf '%s %s' "$title" "$snippet" | tr '[:upper:]' '[:lower:]')
    case "$lower" in
      *contact*|*directory*|*business*|*office*|*support*|*customer*|*phone*)
        if [ "$category" != 'DOCUMENT' ]; then
          numtrace_business_add "$provider" "$url" "$title" "$snippet"
        fi
        ;;
    esac
  done <<EOF
$NUMTRACE_SEARCH_RESULTS
EOF
  if [ -n "$NUMTRACE_BUSINESS_RESULTS" ]; then
    NUMTRACE_BUSINESS_COUNT=$(printf '%s\n' "$NUMTRACE_BUSINESS_RESULTS" | sed '/^$/d' | wc -l | tr -d ' ')
  else
    NUMTRACE_BUSINESS_COUNT=0
  fi
}
