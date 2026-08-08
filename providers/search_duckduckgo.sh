#!/usr/bin/env bash

numtrace_provider_duckduckgo() {
  query=$1
  if [ "$NUMTRACE_OFFLINE" -eq 1 ]; then
    return 0
  fi
  if ! numtrace_have_cmd curl; then
    log_warn "Provider unavailable: duckduckgo (curl missing)"
    return 0
  fi
  tmp=$(mktemp)
  url="https://html.duckduckgo.com/html/?q=$(numtrace_urlencode "$query")"
  if ! numtrace_http_fetch "$url" "$tmp" 20 1; then
    log_warn "Search provider timed out: duckduckgo"
    rm -f -- "$tmp"
    return 0
  fi
  count=0
  while IFS= read -r line; do
    href=$(printf '%s' "$line" | sed -n 's/.*href="\([^"]*\)".*/\1/p')
    title=$(printf '%s' "$line" | sed -n 's/.*>\(.*\)<\/a>.*/\1/p' | sed 's/<[^>]*>//g')
    [ -n "$href" ] || continue
    case "$href" in
      *uddg=*)
        encoded=${href#*uddg=}
        encoded=${encoded%%&*}
        href=$(numtrace_urldecode "$encoded")
        ;;
      //*)
        href=https:${href}
        ;;
    esac
    domain=$(numtrace_url_domain "$href")
    snippet=
    numtrace_search_add_result duckduckgo WEBSITE "$title" "$href" "$domain" "$snippet" ""
    count=$((count + 1))
    [ "$count" -ge 5 ] && break
  done < <(grep -oE '<a[^>]+class="result__a"[^>]*>[^<]+</a>' "$tmp" 2>/dev/null || true)
  rm -f -- "$tmp"
}
