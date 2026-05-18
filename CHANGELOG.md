# Changelog

## [1.0.0-alpha.3] - 2026-05-18
### Added
- **Claude Design ring** — fourth ring tracking the `seven_day_omelette` weekly usage window; independently toggleable from Settings → General with the same remaining-time / exact-date display options as the weekly ring; defaults to hidden

### Changed
- **Time remaining format** — unified across all rings: `Xd Yh` (days + hours), `Xh Ym` (hours + minutes), or `X min` (minutes only). Previously the weekly/omelette rings showed days without hours (e.g. `3d`), and minutes used a shorter `Xm` suffix.

---

## [1.0.0-alpha.2] - 2026-04-23
### Added
- **Extra usage ring** — third ring tracking spending against a user-defined monthly budget for Claude usage beyond the subscription plan; automatically hidden when extra usage is not configured, grayed out when disabled
  - Display format is configurable: **Amount spent** (e.g. `€8.77 / €17.00`) or **Amount remaining** (e.g. `€8.23 / €17.00`)
- **Per-ring visibility** — each ring (session, weekly, extra) can be independently toggled in Settings → General; settings page redesigned with a reusable section component: each ring has its own show/hide toggle and display-format selector

### Fixed
- Adapted to the updated Anthropic API utilization response format
- Corrected extra usage amount calculation (centi-currency division)

---

## [1.0.0-alpha.1] - 2026-04-18
### Added
- Two animated ring gauges showing Claude AI usage: 5-hour session and 7-day weekly window
- Percentage label inside each ring, color-coded green → yellow → orange → red as usage climbs
- Countdown label below each ring: remaining time or exact reset time/date (configurable)
- Auto-refresh every 5 minutes; backs off to 30 min on HTTP 429
- Settings → General: choose a time-remaining or exact-time display for each ring
- Settings → Appearance: **Follow System Theme** (default, follows KDE Plasma Light/Dark theme) or **Custom Colors** mode with per-threshold color pickers (Low / Medium / High / Critical)
- Reads auth token automatically from `~/.claude/.credentials.json` (Claude Code install)
