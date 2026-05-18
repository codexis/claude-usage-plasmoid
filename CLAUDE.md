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

package/
  contents/
    code/
      fetch_usage.py       — Python 3 script; fetches usage from Anthropic API, prints JSON to stdout
      timeUtils.js         — shared JS helpers: time formatting, color calculation
    config/
      main.xml             — typed settings schema (KConfig XT)
      config.qml           — declares config pages (General, Appearance)
    ui/
      main.qml             — root PlasmoidItem; all state, timers, data parsing live here
      RingGauge.qml        — reusable Canvas-based animated ring component
      RingConfigSection.qml — reusable settings section: show/hide toggle + display-format radio buttons for one ring
      ThemeAdapter.qml     — resolves colors for Custom Colors vs Follow System Theme; text/subText/error always system, arc colors from plasmoid.configuration in custom mode
      configGeneral.qml    — settings dialog: General tab; per-ring show/hide + display format (reset mode for session/weekly, spent vs remaining for extra)
      configAppearance.qml — settings dialog: Appearance tab (theme selector + color pickers for Custom mode)
  metadata.json            — package identity, ID, version, author
tests/
  js/                      — Jest unit tests for JS business logic (timeUtils.js)
  python/                  — unittest tests for fetch_usage.py
  qml/                     — QtTest/qmltestrunner tests for QML/JS components
```

### Data flow

1. `main.qml` spawns `fetch_usage.py` via `PlasmaCore.DataSource` (engine: `"executable"`).
2. The Python script calls `https://api.anthropic.com/api/oauth/usage`, reads the OAuth token from `~/.claude/.credentials.json` (Claude Code) or `~/.config/claude-usage-widget/config.json` (manual).
3. On success it prints a JSON object; `main.qml` parses `five_hour`, `seven_day`, and `extra_usage` fields. Example response shape:

```json
{
    "five_hour":          { "utilization": 80.0, "resets_at": "2026-04-23T22:00:00+00:00" },
    "seven_day":          { "utilization": 9.0,  "resets_at": "2026-04-23T22:00:00+00:00" },
    "seven_day_oauth_apps": null,
    "seven_day_opus":       null,
    "seven_day_sonnet":     null,
    "seven_day_cowork":     null,
    "seven_day_omelette": { "utilization": 23.0, "resets_at": "2026-04-23T22:00:00+00:00" },
    "iguana_necktie":       null,
    "omelette_promotional": null,
    "extra_usage": {
        "is_enabled": true,
        "monthly_limit": 1700,
        "used_credits": 877.0,
        "utilization": 51.59,
        "currency": "EUR"
    }
}
```
4. `main.qml` holds all state (`usage5h`, `usage7d`, `reset5h`, `reset7d`, `usageExtra`, `extraLimit`, `extraUsed`, `extraCurrency`, `extraPresent`, `extraEnabled`) and passes computed props down to `RingGauge` instances.
   - `extra_usage` is a monthly credits bucket: `monthly_limit` and `used_credits` are in centi-currency (÷100 to get real amount, e.g. `1700` → €17.00). Ring is hidden when `extra_usage === null`; shown gray when `is_enabled === false`.
5. A `pollTimer` re-fetches every 5 minutes (doubles on HTTP 429, capped at 30 min). A second 1-minute timer increments `_tick` to force reactive re-evaluation of time-remaining labels without a full fetch.

### Configuration

- Settings are declared in `config/main.xml` and read in QML as `Plasmoid.configuration.<key>`.
- `configGeneral.qml` exposes properties named `cfg_<key>` — Plasma syncs these automatically to/from the config store.
- `showRing5h` / `showRing7d` / `showRingExtra` (Bool) — per-ring visibility toggles; extra ring defaults to `false`.
- `session5hResetMode` (`"timeLeft"` | `"exactTime"`) — label below the session ring.
- `session1wResetMode` (`"timeLeft"` | `"exactDate"`) — label below the weekly ring.
- `extraUsageDisplay` (`"spent"` | `"remaining"`) — label format for the extra usage ring.
- `colorTheme` (`"plasma"` default | `"original"`) selects Follow System Theme vs Custom Colors.
- `customGreen/Yellow/Orange/Red` — user-configurable arc colors for the Custom Colors theme (Low / Medium / High / Critical thresholds).
- `ThemeAdapter.qml` exposes an `isCustom` boolean; text/subText/error/separator always come from `Kirigami.Theme` regardless of mode — only arc colors (`green/yellow/orange/red`) and backgrounds (`bg/ring`) switch.

### RingGauge

Drawn on a `Canvas` element. Key geometry properties: `startAngle` (–220°, top-left), `sweepTotal` (260°), `strokeW` (8 px). The filled arc length is `sweepTotal * animValue`. Value changes animate via `Behavior on animValue`.

The `resetIn` string property is the only text the gauge displays below the percentage — formatting is entirely the caller's responsibility (`main.qml` switches between `formatTimeLeft` / `formatResetTime` / `formatResetDate`).

## Testing

The project has three test suites that run automatically in CI (GitHub Actions on every push/PR to `main`).

### JavaScript (Jest)

```bash
npm install
npm test
```

### Python (unittest)

```bash
python3 -m unittest discover tests/python
```

### QML (QtTest / qmltestrunner)

```bash
qmltestrunner tests/qml/tst_timeUtils.qml
```

Requires `qt6-declarative-dev` (or equivalent) with `qmltestrunner` available.
