# Claude AI Usage — KDE Plasma Widget

A KDE Plasma 6 plasmoid that displays your Claude AI usage as animated circular progress rings for the **session** (5-hour), **weekly** (7-day), **Claude Design** (7-day omelette), and optional **extra usage** (monthly credits) windows.

```
┌──────────────────────────────────────────────────┐
│ • Claude AI Usage                            ↻   │
│                                                  │
│  ╭───────╮   ╭───────╮   ╭───────╮   ╭───────╮   │
│  │  73%  │   │  41%  │   │  89%  │   │  €15  │   │
│  │1h 33m │   │ Oct 7 │   │ Oct 7 │   │ / €70 │   │
│  ╰───────╯   ╰───────╯   ╰───────╯   ╰───────╯   │
│   session      weekly      design       extra    │
└──────────────────────────────────────────────────┘
```

- **Session ring** — usage % + remaining time or exact reset time
- **Weekly ring** — usage % + remaining time (e.g. `3d 5h`, `12h 30m`, `45 min`) or exact reset date
- **Claude Design ring** — separate weekly `seven_day_omelette` usage window; same display options as the weekly ring; hidden by default
- **Extra usage ring** — monthly credits bucket: shows amount spent or remaining (e.g. `€8.77 / €17.00`); hidden when no extra plan, grayed out when disabled
- **Per-ring visibility** — each ring can be independently shown or hidden from the General settings
- **Dynamic colors** — green → yellow → orange → red based on utilization
- **Customizable Appearance** — **Follow System Theme** (default) or **Custom Colors** with per-threshold color pickers; text colors always follow the system theme
- **Automatic polling** — updates every **5 minutes** with automatic back-off on rate limits

## Requirements

- KDE Plasma 6
- Python 3
- `kpackagetool6`
- `plasma5support` QML module (`org.kde.plasma.plasma5support`)
- A Claude account (Claude Code CLI or manual OAuth token)

## Installation

```bash
git clone https://github.com/codexis/plasma-applet-claude-usage
cd plasma-applet-claude-usage
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

### Automatic (Claude Code)

If Claude Code is installed, the widget reads the access token directly from `~/.claude/.credentials.json` — no setup needed. When the token expires, run `claude` to trigger a re-login and the credentials file will be updated automatically.

### Manual token

If you don't use Claude Code, create the config file:

```bash
mkdir -p ~/.config/claude-usage-widget
cat > ~/.config/claude-usage-widget/config.json << 'EOF'
{
  "oauth_token": "YOUR_TOKEN_HERE"
}
EOF
chmod 600 ~/.config/claude-usage-widget/config.json
```

## Uninstalling

```bash
kpackagetool6 --type Plasma/Applet --remove io.github.codexis.claudeusage
```

## License

MIT
