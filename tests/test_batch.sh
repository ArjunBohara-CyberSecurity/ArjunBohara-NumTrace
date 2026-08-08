#!/usr/bin/env bash
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cat > "$TMP_DIR/numbers.txt" <<EOF
+919876543210
abcd
+14155551234
EOF

mkdir -p "$TMP_DIR/reports"

if ! "$ROOT_DIR/numtrace.sh" --offline --report "$TMP_DIR/reports" --batch "$TMP_DIR/numbers.txt" >/dev/null 2>&1; then
  printf 'FAIL: batch mode returned non-zero\n' >&2
  exit 1
fi

count=$(find "$TMP_DIR/reports" -name '*.json' | wc -l)
if [ "$count" -lt 2 ]; then
  printf 'FAIL: batch mode did not produce enough reports\n' >&2
  exit 1
fi

printf 'PASS: batch mode works\n'
