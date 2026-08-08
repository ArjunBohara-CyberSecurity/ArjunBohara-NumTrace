#!/usr/bin/env bash

NUMTRACE_TIMELINE_EVENTS=

numtrace_timeline_add() {
  date=$1
  label=$2
  source=$3
  url=$4
  entry=$(printf '%s\t%s\t%s\t%s' "$date" "$label" "$source" "$url")
  if [ -z "$NUMTRACE_TIMELINE_EVENTS" ]; then
    NUMTRACE_TIMELINE_EVENTS=$entry
  else
    NUMTRACE_TIMELINE_EVENTS="$NUMTRACE_TIMELINE_EVENTS
$entry"
  fi
}

numtrace_build_timeline_findings() {
  NUMTRACE_TIMELINE_EVENTS=
  if [ -z "$NUMTRACE_SEARCH_RESULTS" ]; then
    return 0
  fi
  while IFS=$(printf '\t') read -r provider category title url domain snippet date; do
    if [ -n "$date" ]; then
      numtrace_timeline_add "$date" "$title" "$provider" "$url"
    fi
  done <<EOF
$NUMTRACE_SEARCH_RESULTS
EOF
}
