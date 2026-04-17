# Claude AI Usage — KDE Plasma Widget

A KDE Plasma 6 plasmoid that displays your Claude AI usage as animated circular progress rings for the **session** (5-hour) and **weekly** (7-day) rate-limit windows.

```
┌─────────────────────────────────┐
│ • Claude AI Usage         ↻     │
│                                 │
│   ╭───────╮       ╭───────╮     │
│   │  73%  │       │  41%  │     │
│   │1h 33m │       │ Oct 7 │     │
│   ╰───────╯       ╰───────╯     │
│    session          weekly      │
└─────────────────────────────────┘
```

- **Session ring** — usage % + time remaining/exact reset time
- **Weekly ring** — usage % + refined remaining time (days or hours/mins) or exact reset date
- **Dynamic colors** — green → yellow → orange → red based on utilization
- **Customizable Appearance** — choose between the **Claude Dark** (Original) aesthetic or a **System Native** theme that follows your Plasma colors (Light or Dark)
- **Automatic polling** — updates every **5 minutes** with automatic back-off on rate limits

## Requirements

- KDE Plasma 6
- Python 3
- `kpackagetool6`
- `plasma5support` QML module (`org.kde.plasma.plasma5support`)
- A Claude account (Claude Code CLI or manual OAuth token)

## Installation

```bash
git clone https://github.com/codexis/claude-usage-plasmoid
cd claude-usage-plasmoid
bash install.sh
```

The script installs the plasmoid and restarts `plasmashell` automatically so the updated widget is applied immediately — no need to remove and re-add it.

After installation, add the widget to your desktop or panel:

> Right-click desktop → **Add Widgets** → search **Claude AI Usage**

Or test in a window without touching the desktop:

```bash
plasmawindowed io.github.codexis.claudeusage
```

### Reinstalling / updating

```bash
bash install.sh
```

The old installation is removed and replaced cleanly on every run.

## Authentication

The widget reads your Claude OAuth token automatically — no manual setup needed if you use **Claude Code CLI**.

### Automatic (Claude Code)

If Claude Code is installed, the token is read from:

```
~/.claude/.credentials.json
```

### Manual token

If you don't use Claude Code, create the config file:

```bash
mkdir -p ~/.config/claude-usage-widget
cat > ~/.config/claude-usage-widget/config.json << 'EOF'
{
  "oauth_token": "YOUR_TOKEN_HERE"
}
EOF
chmod 600 ~/.config/claude-usage-widget
```

## Testing

The project includes three test suites that run automatically in CI on every push and pull request to `main`.

| Suite | Runner | Command |
|-------|--------|---------|
| JavaScript | Jest | `npm install && npm test` |
| Python | unittest | `python3 -m unittest discover tests/python` |
| QML | QtTest | `qmltestrunner tests/qml/tst_timeUtils.qml` |

QML tests require `qt6-declarative-dev` (or equivalent) with `qmltestrunner` available.

## Uninstalling

```bash
kpackagetool6 --type Plasma/Applet --remove io.github.codexis.claudeusage
```

## License

MIT
