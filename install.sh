#!/usr/bin/env bash
set -euo pipefail

PLASMOID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ID="io.github.codexis.claudeusage"

echo "╔════════════════════════════════════════════════╗"
echo "║  Claude Usage — KDE Plasma Widget              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Make fetch script executable
chmod +x "$PLASMOID_DIR/package/contents/code/fetch_usage.py"

# Remove stale installation so --install always works cleanly
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$APP_ID"
echo "▸ Removing old installation…"
if command -v kpackagetool6 &>/dev/null; then
    kpackagetool6 --type Plasma/Applet --remove "$APP_ID" 2>/dev/null || true
elif [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi

# Clear stale QML cache for this widget's files only.
# Qt names cache entries by SHA-1 of the installed file's absolute path.
echo "▸ Clearing widget QML cache…"
QML_UI_DIR="$HOME/.local/share/plasma/plasmoids/$APP_ID/contents/ui"
for CACHE_DIR in "$HOME/.cache/plasmashell/qmlcache" "$HOME/.cache/plasmawindowed/qmlcache"; do
    [ -d "$CACHE_DIR" ] || continue
    while IFS= read -r -d '' QML_PATH; do
        QML_FILE=$(basename "$QML_PATH")
        HASH=$(echo -n "$QML_UI_DIR/$QML_FILE" | sha1sum | cut -d' ' -f1)
        rm -f "$CACHE_DIR/$HASH.qmlc"
    done < <(find "$PLASMOID_DIR/package/contents/ui" -maxdepth 1 -name "*.qml" -print0)
done

echo "▸ Installing plasmoid…"

if command -v kpackagetool6 &>/dev/null; then
    echo "  using kpackagetool6 (Plasma 6)"
    kpackagetool6 --type Plasma/Applet --install "$PLASMOID_DIR/package"
elif command -v plasmapkg2 &>/dev/null; then
    echo "  using plasmapkg2 (Plasma 5)"
    plasmapkg2 --install "$PLASMOID_DIR/package"
elif command -v kpackagetool5 &>/dev/null; then
    echo "  using kpackagetool5 (Plasma 5)"
    kpackagetool5 --install "$PLASMOID_DIR/package"
else
    echo "ERROR: no plasma package tool found (kpackagetool6 / plasmapkg2 / kpackagetool5)" >&2
    exit 1
fi

echo ""
echo "▸ Reloading plasmashell…"
if command -v kquitapp6 &>/dev/null; then
    kquitapp6 plasmashell
    if command -v kstart6 &>/dev/null; then
        kstart6 plasmashell &
    else
        kstart plasmashell &
    fi
    echo "  plasmashell restarting in background"
else
    echo "  (restart plasmashell manually to apply changes)"
fi

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  ✓ Installed!                                  ║"
echo "║                                                ║"
echo "║  Add widget:                                   ║"
echo "║  Right-click desktop → Add Widgets             ║"
echo "║  Search: Claude AI Usage                       ║"
echo "║                                                ║"
echo "║  Or run to test immediately:                   ║"
echo "║  plasmawindowed io.github.codexis.claudeusage  ║"
echo "╚════════════════════════════════════════════════╝"
