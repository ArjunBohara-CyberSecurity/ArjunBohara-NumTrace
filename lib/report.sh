#!/usr/bin/env bash

NUMTRACE_LAST_REPORT_TXT=
NUMTRACE_LAST_REPORT_JSON=
NUMTRACE_LAST_REPORT_HTML=

numtrace_report_stem() {
  normalized=$1
  stamp=$(date -u '+%Y-%m-%d_%H-%M')
  phone=$(numtrace_sanitize_filename "${normalized#+}")
  printf '%s_%s' "$stamp" "$phone"
}

numtrace_report_text_body() {
  cat <<EOF
===============================================
ARJUNBOHARA-NUMTRACE
PHONE INTELLIGENCE REPORT
===============================================

Target:
$NUMTRACE_TARGET_INPUT

Normalized:
$NUMTRACE_NORMALIZED

Generated:
$(numtrace_today)

## NUMBER ANALYSIS

Country:
${NUMTRACE_COUNTRY_NAME:-UNKNOWN}

Country calling code:
${NUMTRACE_COUNTRY_CODE:-UNKNOWN}

Type:
${NUMTRACE_NUMBER_TYPE:-UNKNOWN}

Timezone:
${NUMTRACE_TIMEZONE:-UNKNOWN}

Validity:
${NUMTRACE_VALIDITY:-UNKNOWN}

Confidence:
${NUMTRACE_CONFIDENCE:-unknown}

## PUBLIC FOOTPRINT

Web mentions: $NUMTRACE_SEARCH_COUNT
Business references: $NUMTRACE_BUSINESS_COUNT
Documents: $NUMTRACE_DOCUMENT_COUNT
News references: $NUMTRACE_NEWS_COUNT

## REPUTATION

Entries: $NUMTRACE_REPUTATION_COUNT

## CORRELATION

Association score: $NUMTRACE_ASSOCIATION_SCORE/100
Association label: $NUMTRACE_ASSOCIATION_LABEL

## LIMITATIONS

This report contains public OSINT findings.
It does not establish ownership or current physical location unless explicitly supported by authoritative public evidence.

===============================================
EOF
}

numtrace_json_array_from_results() {
  lines=$1
  kind=$2
  first=1
  printf '['
  if [ -n "$lines" ]; then
    while IFS=$(printf '\t') read -r a b c d e f g; do
      [ -n "$a$b$c$d$e$f$g" ] || continue
      if [ $first -eq 0 ]; then
        printf ','
      fi
      first=0
      case "$kind" in
        search)
          provider=$a; type=$b; title=$c; url=$d; domain=$e; snippet=$f; date=$g
          printf '{"provider":"%s","type":"%s","title":"%s","url":"%s","domain":"%s","snippet":"%s","date":"%s"}' \
            "$(numtrace_json_escape "$provider")" \
            "$(numtrace_json_escape "$type")" \
            "$(numtrace_json_escape "$title")" \
            "$(numtrace_json_escape "$url")" \
            "$(numtrace_json_escape "$domain")" \
            "$(numtrace_json_escape "$snippet")" \
            "$(numtrace_json_escape "$date")"
          ;;
        business)
          source=$a; url=$b; title=$c; snippet=$d
          printf '{"source":"%s","url":"%s","title":"%s","snippet":"%s"}' \
            "$(numtrace_json_escape "$source")" \
            "$(numtrace_json_escape "$url")" \
            "$(numtrace_json_escape "$title")" \
            "$(numtrace_json_escape "$snippet")"
          ;;
        document)
          source=$a; url=$b; title=$c; date=$d; snippet=$e
          printf '{"source":"%s","url":"%s","title":"%s","date":"%s","snippet":"%s"}' \
            "$(numtrace_json_escape "$source")" \
            "$(numtrace_json_escape "$url")" \
            "$(numtrace_json_escape "$title")" \
            "$(numtrace_json_escape "$date")" \
            "$(numtrace_json_escape "$snippet")"
          ;;
        reputation)
          source=$a; url=$b; title=$c; snippet=$d
          printf '{"source":"%s","url":"%s","title":"%s","snippet":"%s"}' \
            "$(numtrace_json_escape "$source")" \
            "$(numtrace_json_escape "$url")" \
            "$(numtrace_json_escape "$title")" \
            "$(numtrace_json_escape "$snippet")"
          ;;
        timeline)
          date=$a; label=$b; source=$c; url=$d
          printf '{"date":"%s","label":"%s","source":"%s","url":"%s"}' \
            "$(numtrace_json_escape "$date")" \
            "$(numtrace_json_escape "$label")" \
            "$(numtrace_json_escape "$source")" \
            "$(numtrace_json_escape "$url")"
          ;;
        correlation)
          score=$a; label=$b; reason=$c
          printf '{"score":%s,"label":"%s","reason":"%s"}' \
            "$score" \
            "$(numtrace_json_escape "$label")" \
            "$(numtrace_json_escape "$reason")"
          ;;
      esac
    done <<EOF
$lines
EOF
  fi
  printf ']'
}

numtrace_report_json() {
  search_json=$(numtrace_json_array_from_results "$NUMTRACE_SEARCH_RESULTS" search)
  business_json=$(numtrace_json_array_from_results "$NUMTRACE_BUSINESS_RESULTS" business)
  document_json=$(numtrace_json_array_from_results "$NUMTRACE_DOCUMENT_RESULTS" document)
  reputation_json=$(numtrace_json_array_from_results "$NUMTRACE_REPUTATION_RESULTS" reputation)
  timeline_json=$(numtrace_json_array_from_results "$NUMTRACE_TIMELINE_EVENTS" timeline)
  correlation_json=$(numtrace_json_array_from_results "$NUMTRACE_CORRELATION_RESULTS" correlation)
  cat <<EOF
{"tool":"ArjunBohara-NumTrace","version":"$VERSION","target":{"input":"$(numtrace_json_escape "$NUMTRACE_TARGET_INPUT")","normalized":"$(numtrace_json_escape "$NUMTRACE_NORMALIZED")"},"number":{"country":"$(numtrace_json_escape "${NUMTRACE_COUNTRY_NAME:-unknown}")","country_code":"$(numtrace_json_escape "${NUMTRACE_COUNTRY_CODE:-unknown}")","type":"$(numtrace_json_escape "${NUMTRACE_NUMBER_TYPE:-unknown}")","timezone":"$(numtrace_json_escape "${NUMTRACE_TIMEZONE:-unknown}")","validity":"$(numtrace_json_escape "${NUMTRACE_VALIDITY:-unknown}")","confidence":"$(numtrace_json_escape "${NUMTRACE_CONFIDENCE:-unknown}")"},"public_footprint":$search_json,"businesses":$business_json,"documents":$document_json,"reputation":$reputation_json,"timeline":$timeline_json,"correlations":$correlation_json,"sources":$search_json,"limitations":["Public OSINT only","No fabrication","No current physical location claims without authoritative public evidence"]}
EOF
}

numtrace_report_html() {
  cat <<EOF
<!doctype html>
<html><head><meta charset="utf-8"><title>ArjunBohara-NumTrace</title></head>
<body><pre>$(numtrace_report_text_body)</pre></body></html>
EOF
}

numtrace_generate_report() {
  report_dir=$1
  input=$2
  normalized=$3
  mkdir -p -- "$report_dir"
  stem=$(numtrace_report_stem "$normalized")
  NUMTRACE_LAST_REPORT_TXT="$report_dir/${stem}.txt"
  NUMTRACE_LAST_REPORT_JSON="$report_dir/${stem}.json"
  NUMTRACE_LAST_REPORT_HTML="$report_dir/${stem}.html"

  text=$(numtrace_report_text_body)
  json=$(numtrace_report_json)
  html=$(numtrace_report_html)
  umask 077
  printf '%s\n' "$text" > "$NUMTRACE_LAST_REPORT_TXT"
  printf '%s\n' "$json" > "$NUMTRACE_LAST_REPORT_JSON"
  printf '%s\n' "$html" > "$NUMTRACE_LAST_REPORT_HTML"
  if [ "$NUMTRACE_OUTPUT_QUIET" -eq 0 ] && [ "$NUMTRACE_OUTPUT_JSON" -eq 0 ]; then
    log_ok "Report written"
    printf '  TXT : %s\n' "$NUMTRACE_LAST_REPORT_TXT"
    printf '  JSON: %s\n' "$NUMTRACE_LAST_REPORT_JSON"
  fi
}

numtrace_report_print_summary() {
  cat <<EOF
Target: $NUMTRACE_TARGET_INPUT
Normalized: $NUMTRACE_NORMALIZED
Country: ${NUMTRACE_COUNTRY_NAME:-UNKNOWN}
Type: ${NUMTRACE_NUMBER_TYPE:-UNKNOWN}
Web mentions: $NUMTRACE_SEARCH_COUNT
Business references: $NUMTRACE_BUSINESS_COUNT
Documents: $NUMTRACE_DOCUMENT_COUNT
News references: $NUMTRACE_NEWS_COUNT
Association: $NUMTRACE_ASSOCIATION_LABEL ($NUMTRACE_ASSOCIATION_SCORE/100)
EOF
}

numtrace_report_json_stdout() {
  numtrace_report_json
}
