#!/usr/bin/env bash
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
. "$ROOT_DIR/lib/utils.sh"
. "$ROOT_DIR/lib/phone.sh"

fail=0

expect_phone() {
  input=$1
  country=$2
  want_norm=$3
  want_country=$4
  if numtrace_analyze_phone "$input" "$country"; then
    if [ "$NUMTRACE_NORMALIZED" != "$want_norm" ]; then
      printf 'FAIL normalize %s => %s (want %s)\n' "$input" "$NUMTRACE_NORMALIZED" "$want_norm" >&2
      fail=1
    fi
    if [ "$NUMTRACE_COUNTRY" != "$want_country" ]; then
      printf 'FAIL country %s => %s (want %s)\n' "$input" "$NUMTRACE_COUNTRY" "$want_country" >&2
      fail=1
    fi
    printf 'PASS: %s\n' "$input"
  else
    printf 'FAIL: analysis rejected %s\n' "$input" >&2
    fail=1
  fi
}

expect_phone '+919876543210' '' '+919876543210' 'IN'
expect_phone '919876543210' 'IN' '+919876543210' 'IN'
expect_phone '09876543210' 'IN' '+919876543210' 'IN'
expect_phone '9876543210' 'IN' '+919876543210' 'IN'
expect_phone '+14155551234' '' '+14155551234' 'US'

if numtrace_analyze_phone 'abcd' '' >/dev/null 2>&1; then
  printf 'FAIL: invalid input accepted\n' >&2
  fail=1
else
  printf 'PASS: invalid input rejected\n'
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
