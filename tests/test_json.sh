#!/usr/bin/env bash
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
OUTPUT=$("$ROOT_DIR/numtrace.sh" --json --offline --report "$ROOT_DIR/reports" +919876543210 2>/dev/null || true)

case "$OUTPUT" in
  *'"tool":"ArjunBohara-NumTrace"'* ) ;;
  *)
    printf 'FAIL: JSON output missing tool field\n' >&2
    exit 1
    ;;
esac

case "$OUTPUT" in
  *'"normalized":"+919876543210"'* ) ;;
  *)
    printf 'FAIL: JSON output missing normalized number\n' >&2
    exit 1
    ;;
esac

printf 'PASS: JSON output looks valid\n'
