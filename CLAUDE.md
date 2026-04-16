# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Install / reinstall

```bash
bash install.sh
```

Removes the old installation, installs via `kpackagetool6`, and restarts `plasmashell` automatically.

Test without touching the desktop:

```bash
plasmawindowed io.github.codexis.claudeusage
```

Uninstall:

```bash
kpackagetool6 --type Plasma/Applet --remove io.github.codexis.claudeusage
```

## Architecture

This is a **KDE Plasma 6 plasmoid** (package ID `io.github.codexis.claudeusage`). The package layout follows the KDE Plasma standard:

```
metadata.json              — package identity, ID, version
config/main.xml            — typed settings schema (KConfig XT)
contents/
  ui/
    main.qml               — root PlasmoidItem; all state lives here
    RingGauge.qml          — reusable Canvas-based ring component
    configGeneral.qml      — settings dialog (General tab)
  code/
    fetch_usage.py         — Python 3 script; prints JSON to stdout
```

### Data flow

1. `main.qml` spawns `fetch_usage.py` via `PlasmaCore.DataSource` (engine: `"executable"`).
2. The Python script calls `https://api.anthropic.com/api/oauth/usage`, reads the OAuth token from `~/.claude/.credentials.json` (Claude Code) or `~/.config/claude-usage-widget/config.json` (manual).
3. On success it prints a JSON object; `main.qml` parses `five_hour` and `seven_day` fields.
4. `main.qml` holds all state (`usage5h`, `usage7d`, `reset5h`, `reset7d`) and passes computed props down to two `RingGauge` instances.
5. A `pollTimer` re-fetches every 5 minutes (doubles on HTTP 429, capped at 30 min). A second 1-minute timer increments `_tick` to force reactive re-evaluation of time-remaining labels without a full fetch.

### Configuration

- Settings are declared in `config/main.xml` and read in QML as `Plasmoid.configuration.<key>`.
- `configGeneral.qml` exposes properties named `cfg_<key>` — Plasma syncs these automatically to/from the config store.
- Currently: `session5hResetMode` (`"timeLeft"` | `"exactTime"`) controls the label shown below the session ring percentage.

### RingGauge

Drawn on a `Canvas` element. Key geometry properties: `startAngle` (–220°, top-left), `sweepTotal` (260°), `strokeW` (8 px). The filled arc length is `sweepTotal * animValue`. Value changes animate via `Behavior on animValue`.

The `resetIn` string property is the only text the gauge displays below the percentage — formatting is entirely the caller's responsibility (`main.qml` switches between `formatTimeLeft` / `formatResetTime` / `formatResetDate`).
