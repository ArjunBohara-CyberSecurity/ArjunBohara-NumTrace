#!/usr/bin/env bash

NUMTRACE_REPUTATION_RESULTS=

numtrace_reputation_add() {
  source=$1
  url=$2
  title=$3
  snippet=$4
  entry=$(printf '%s\t%s\t%s\t%s' "$source" "$url" "$title" "$snippet")
  if [ -z "$NUMTRACE_REPUTATION_RESULTS" ]; then
    NUMTRACE_REPUTATION_RESULTS=$entry
  else
    NUMTRACE_REPUTATION_RESULTS="$NUMTRACE_REPUTATION_RESULTS
$entry"
  fi
}

numtrace_build_reputation_findings() {
  NUMTRACE_REPUTATION_RESULTS=
  if [ -z "$NUMTRACE_SEARCH_RESULTS" ]; then
    NUMTRACE_REPUTATION_COUNT=0
    return 0
  fi
  while IFS=$(printf '\t') read -r provider category title url domain snippet date; do
    lower=$(printf '%s %s %s' "$title" "$snippet" "$domain" | tr '[:upper:]' '[:lower:]')
    case "$lower" in
      *scam*|*spam*|*fraud*|*complaint*|*caller*|*telemark*|*who-calls*|*whocallsme*|*tellows*|*800notes*|*shouldianswer*)
        numtrace_reputation_add "$provider" "$url" "$title" "$snippet"
        ;;
    esac
  done <<EOF
$NUMTRACE_SEARCH_RESULTS
EOF
  if [ -n "$NUMTRACE_REPUTATION_RESULTS" ]; then
    NUMTRACE_REPUTATION_COUNT=$(printf '%s\n' "$NUMTRACE_REPUTATION_RESULTS" | sed '/^$/d' | wc -l | tr -d ' ')
  else
    NUMTRACE_REPUTATION_COUNT=0
  fi
}
