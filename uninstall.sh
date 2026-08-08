#!/usr/bin/env bash
set -u

APP_NAME=ArjunBohara-NumTrace
BIN_NAME=numtrace

if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX" ]; then
  BIN_DIR="$PREFIX/bin"
  SHARE_DIR="$PREFIX/share/$APP_NAME"
else
  BIN_DIR="$HOME/.local/bin"
  SHARE_DIR="$HOME/.local/share/$APP_NAME"
fi

if [ -f "$SHARE_DIR/.install_manifest" ]; then
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    if [ -L "$path" ] || [ -f "$path" ]; then
      rm -f -- "$path"
    fi
  done < "$SHARE_DIR/.install_manifest"
fi

rm -f -- "$BIN_DIR/$BIN_NAME"
rm -rf -- "$SHARE_DIR"

printf 'Uninstalled %s\n' "$APP_NAME"
