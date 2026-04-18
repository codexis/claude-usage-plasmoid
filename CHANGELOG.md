# Changelog

## [1.0.0-alpha.1] - 2026-04-18
### Added
- Two animated ring gauges showing Claude AI usage: 5-hour session and 7-day weekly window
- Percentage label inside each ring, color-coded green → yellow → orange → red as usage climbs
- Countdown label below each ring: remaining time or exact reset time/date (configurable)
- Auto-refresh every 5 minutes; backs off to 30 min on HTTP 429
- Settings → General: choose a time-remaining or exact-time display for each ring
- Settings → Appearance: **Follow System Theme** (default, follows KDE Plasma Light/Dark theme) or **Custom Colors** mode with per-threshold color pickers (Low / Medium / High / Critical)
- Reads auth token automatically from `~/.claude/.credentials.json` (Claude Code install)
