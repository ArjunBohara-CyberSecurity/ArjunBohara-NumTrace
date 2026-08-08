#!/usr/bin/env bash

NUMTRACE_DOCUMENT_RESULTS=

numtrace_document_add() {
  source=$1
  url=$2
  title=$3
  date=$4
  snippet=$5
  entry=$(printf '%s\t%s\t%s\t%s\t%s' "$source" "$url" "$title" "$date" "$snippet")
  if [ -z "$NUMTRACE_DOCUMENT_RESULTS" ]; then
    NUMTRACE_DOCUMENT_RESULTS=$entry
  else
    NUMTRACE_DOCUMENT_RESULTS="$NUMTRACE_DOCUMENT_RESULTS
$entry"
  fi
}

numtrace_build_document_findings() {
  NUMTRACE_DOCUMENT_RESULTS=
  if [ -z "$NUMTRACE_SEARCH_RESULTS" ]; then
    NUMTRACE_DOCUMENT_COUNT=0
    return 0
  fi
  while IFS=$(printf '\t') read -r provider category title url domain snippet date; do
    case "$category" in
      DOCUMENT)
        numtrace_document_add "$provider" "$url" "$title" "$date" "$snippet"
        ;;
    esac
    case "$url" in
      *.pdf|*.doc|*.docx|*.txt|*.csv)
        numtrace_document_add "$provider" "$url" "$title" "$date" "$snippet"
        ;;
    esac
  done <<EOF
$NUMTRACE_SEARCH_RESULTS
EOF
  if [ -n "$NUMTRACE_DOCUMENT_RESULTS" ]; then
    NUMTRACE_DOCUMENT_COUNT=$(printf '%s\n' "$NUMTRACE_DOCUMENT_RESULTS" | sed '/^$/d' | wc -l | tr -d ' ')
  else
    NUMTRACE_DOCUMENT_COUNT=0
  fi
}
