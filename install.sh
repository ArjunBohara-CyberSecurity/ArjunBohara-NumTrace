#!/usr/bin/env bash
set -u

SCRIPT_PATH=${BASH_SOURCE[0]}
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)
APP_NAME=ArjunBohara-NumTrace
BIN_NAME=numtrace

if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX" ]; then
  BIN_DIR="$PREFIX/bin"
  SHARE_DIR="$PREFIX/share/$APP_NAME"
else
  BIN_DIR="$HOME/.local/bin"
  SHARE_DIR="$HOME/.local/share/$APP_NAME"
fi

mkdir -p "$BIN_DIR" "$SHARE_DIR"
cp "$SCRIPT_DIR/numtrace.sh" "$SHARE_DIR/numtrace.sh"
cp "$SCRIPT_DIR/install.sh" "$SHARE_DIR/install.sh"
cp "$SCRIPT_DIR/uninstall.sh" "$SHARE_DIR/uninstall.sh"
cp -R "$SCRIPT_DIR/lib" "$SHARE_DIR/lib"
cp -R "$SCRIPT_DIR/providers" "$SHARE_DIR/providers"
cp -R "$SCRIPT_DIR/config" "$SHARE_DIR/config"
cp -R "$SCRIPT_DIR/docs" "$SHARE_DIR/docs"
mkdir -p "$SHARE_DIR/reports"
if [ -f "$SCRIPT_DIR/reports/.gitkeep" ]; then
  cp "$SCRIPT_DIR/reports/.gitkeep" "$SHARE_DIR/reports/.gitkeep"
fi
chmod +x "$SHARE_DIR/numtrace.sh" "$SHARE_DIR/install.sh" "$SHARE_DIR/uninstall.sh"

mkdir -p "$HOME/.config/numtrace"
if [ ! -f "$HOME/.config/numtrace/config" ]; then
  cp "$SHARE_DIR/config/config.example" "$HOME/.config/numtrace/config"
fi

mkdir -p "$HOME/.cache/numtrace"
mkdir -p "$HOME/.local/share/numtrace"

cat > "$BIN_DIR/$BIN_NAME" <<EOF
#!/usr/bin/env bash
exec "$SHARE_DIR/numtrace.sh" "\$@"
EOF
chmod +x "$BIN_DIR/$BIN_NAME"

cat > "$SHARE_DIR/.install_manifest" <<EOF
$BIN_DIR/$BIN_NAME
$SHARE_DIR
EOF

printf 'Installed %s to %s\n' "$APP_NAME" "$BIN_DIR/$BIN_NAME"
