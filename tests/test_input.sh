#!/usr/bin/env bash
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

help_out=$("$ROOT_DIR/numtrace.sh" --help 2>/dev/null || true)
case "$help_out" in
  *'Usage:'* ) ;;
  *)
    printf 'FAIL: help output missing Usage\n' >&2
    exit 1
    ;;
esac

version_out=$("$ROOT_DIR/numtrace.sh" --version 2>/dev/null || true)
case "$version_out" in
  *'ArjunBohara-NumTrace v1.0.0'* ) ;;
  *)
    printf 'FAIL: version output missing\n' >&2
    exit 1
    ;;
esac

deps_out=$("$ROOT_DIR/numtrace.sh" --check-deps 2>/dev/null || true)
case "$deps_out" in
  *'Dependency Check'* ) ;;
  *)
    printf 'FAIL: dependency checker output missing\n' >&2
    exit 1
    ;;
esac

invalid_out=$("$ROOT_DIR/numtrace.sh" --offline not-a-phone 2>&1 || true)
case "$invalid_out" in
  *'invalid'*|*'Ambiguous'*|*'Length does not match'* ) ;;
  *)
    printf 'FAIL: invalid input was not reported\n' >&2
    exit 1
    ;;
esac

printf 'PASS: CLI input handling looks sane\n'
