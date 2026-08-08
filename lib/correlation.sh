#!/usr/bin/env bash

NUMTRACE_CORRELATION_RESULTS=
NUMTRACE_ASSOCIATION_SCORE=0
NUMTRACE_ASSOCIATION_LABEL=UNVERIFIED

numtrace_correlation_add() {
  score=$1
  label=$2
  reason=$3
  entry=$(printf '%s\t%s\t%s' "$score" "$label" "$reason")
  if [ -z "$NUMTRACE_CORRELATION_RESULTS" ]; then
    NUMTRACE_CORRELATION_RESULTS=$entry
  else
    NUMTRACE_CORRELATION_RESULTS="$NUMTRACE_CORRELATION_RESULTS
$entry"
  fi
}

numtrace_build_correlation_findings() {
  NUMTRACE_CORRELATION_RESULTS=
  score=10
  reasons='Exact number match'
  if [ "$NUMTRACE_BUSINESS_COUNT" -gt 0 ]; then
    score=$((score + 35))
    reasons="$reasons; public business references"
  fi
  if [ "$NUMTRACE_DOCUMENT_COUNT" -gt 0 ]; then
    score=$((score + 20))
    reasons="$reasons; public document references"
  fi
  if [ "$NUMTRACE_NEWS_COUNT" -gt 0 ]; then
    score=$((score + 10))
    reasons="$reasons; news mentions"
  fi
  if [ "$NUMTRACE_REPUTATION_COUNT" -gt 0 ]; then
    score=$((score + 10))
    reasons="$reasons; reputation evidence"
  fi
  if [ "$NUMTRACE_COUNTRY" = 'IN' ] && [ "$NUMTRACE_NUMBER_TYPE" = 'mobile' ]; then
    score=$((score + 5))
    reasons="$reasons; numbering-plan match"
  fi
  if [ "$score" -gt 100 ]; then
    score=100
  fi
  case "$score" in
    90|91|92|93|94|95|96|97|98|99|100)
      label='CONFIRMED PUBLIC ASSOCIATION'
      ;;
    75|76|77|78|79|80|81|82|83|84|85|86|87|88|89)
      label='STRONG ASSOCIATION'
      ;;
    50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74)
      label='POSSIBLE ASSOCIATION'
      ;;
    25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49)
      label='WEAK ASSOCIATION'
      ;;
    *)
      label='UNVERIFIED'
      ;;
  esac
  NUMTRACE_ASSOCIATION_SCORE=$score
  NUMTRACE_ASSOCIATION_LABEL=$label
  numtrace_correlation_add "$score" "$label" "$reasons"
}
