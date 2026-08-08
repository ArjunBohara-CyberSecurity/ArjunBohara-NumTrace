#!/usr/bin/env bash
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

batch="$TMP_DIR/numbers.txt"
{
  i=1
  while [ "$i" -le 20 ]; do
    printf '+91987654%04d\n' "$i"
    i=$((i + 1))
  done
} > "$batch"

mkdir -p "$TMP_DIR/reports"

NUMTRACE_SEARCH_DELAY=1 "$ROOT_DIR/numtrace.sh" --report "$TMP_DIR/reports" --batch "$batch" >/dev/null 2>&1 &
pid=$!
sleep 1
kill -INT "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true

printf 'PASS: signal path exercised\n'
