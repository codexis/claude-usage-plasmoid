#!/usr/bin/env bash
set -euo pipefail

PLASMOID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ID="io.github.codexis.claudeusage"

echo "╔════════════════════════════════════════════════╗"
echo "║  Claude Usage — KDE Plasma Widget              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Make fetch script executable
chmod +x "$PLASMOID_DIR/contents/code/fetch_usage.py"

# Remove stale installation so --install always works cleanly
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$APP_ID"
if [ -d "$INSTALL_DIR" ]; then
    echo "▸ Removing old installation…"
    rm -rf "$INSTALL_DIR"
fi

echo "▸ Installing plasmoid…"

if command -v kpackagetool6 &>/dev/null; then
    echo "  using kpackagetool6 (Plasma 6)"
    kpackagetool6 --type Plasma/Applet --install "$PLASMOID_DIR"
elif command -v plasmapkg2 &>/dev/null; then
    echo "  using plasmapkg2 (Plasma 5)"
    plasmapkg2 --install "$PLASMOID_DIR"
elif command -v kpackagetool5 &>/dev/null; then
    echo "  using kpackagetool5 (Plasma 5)"
    kpackagetool5 --install "$PLASMOID_DIR"
else
    echo "ERROR: no plasma package tool found (kpackagetool6 / plasmapkg2 / kpackagetool5)" >&2
    exit 1
fi

echo ""
echo "▸ Reloading plasmashell…"
if command -v kquitapp6 &>/dev/null && command -v kstart6 &>/dev/null; then
    kquitapp6 plasmashell
    kstart6 plasmashell &
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
