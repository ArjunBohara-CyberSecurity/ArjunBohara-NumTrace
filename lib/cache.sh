#!/usr/bin/env bash

NUMTRACE_CACHE_DIR="${NUMTRACE_CACHE_DIR:-$HOME/.cache/numtrace}"
NUMTRACE_CACHE_TTL="${NUMTRACE_CACHE_TTL:-86400}"

numtrace_cache_key() {
  key=$1
  if numtrace_have_cmd sha256sum; then
    printf '%s' "$key" | sha256sum | cut -d' ' -f1
    return 0
  fi
  if numtrace_have_cmd shasum; then
    printf '%s' "$key" | shasum -a 256 | cut -d' ' -f1
    return 0
  fi
  if numtrace_have_cmd openssl; then
    printf '%s' "$key" | openssl dgst -sha256 | sed 's/^.* //'
    return 0
  fi
  printf '%s' "$key" | cksum | cut -d' ' -f1
}

numtrace_cache_path() {
  key=$1
  mkdir -p -- "$NUMTRACE_CACHE_DIR"
  printf '%s/%s.cache' "$NUMTRACE_CACHE_DIR" "$(numtrace_cache_key "$key")"
}

numtrace_cache_get() {
  key=$1
  path=$(numtrace_cache_path "$key")
  if [ ! -f "$path" ]; then
    return 1
  fi
  now=$(date +%s)
  stamp=$(head -n 1 "$path")
  age=$((now - stamp))
  if [ "$age" -gt "$NUMTRACE_CACHE_TTL" ]; then
    return 1
  fi
  tail -n +2 "$path"
}

numtrace_cache_set() {
  key=$1
  content=$2
  path=$(numtrace_cache_path "$key")
  umask 077
  {
    date +%s
    printf '%s\n' "$content"
  } > "$path"
}

numtrace_cache_clear() {
  if [ -d "$NUMTRACE_CACHE_DIR" ]; then
    find "$NUMTRACE_CACHE_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  fi
}
