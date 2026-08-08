#!/usr/bin/env bash
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
. "$ROOT_DIR/lib/utils.sh"

fail=0

assert_eq() {
  got=$1
  want=$2
  label=$3
  if [ "$got" != "$want" ]; then
    printf 'FAIL: %s (got=%s want=%s)\n' "$label" "$got" "$want" >&2
    fail=1
  else
    printf 'PASS: %s\n' "$label"
  fi
}

assert_eq "$(numtrace_sanitize_filename '+91 98765 43210')" '+919876543210' 'sanitize filename'
assert_eq "$(numtrace_json_escape 'a"b\c')" 'a\"b\\c' 'json escape'
assert_eq "$(numtrace_urlencode 'a b')" 'a%20b' 'url encode'

if [ "$fail" -ne 0 ]; then
  exit 1
fi
