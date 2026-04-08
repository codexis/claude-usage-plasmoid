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

- **Session ring** — usage % + time remaining until reset
- **Weekly ring** — usage % + date and time of the next reset
- Color changes green → yellow → orange → red as usage grows
- Auto-polls every **5 minutes**; backs off automatically on rate limit (429)

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
```

## Uninstalling

```bash
kpackagetool6 --type Plasma/Applet --remove io.github.codexis.claudeusage
```

## License

MIT
