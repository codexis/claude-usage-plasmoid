.pragma library

function formatTimeLeft(iso, now) {
    if (!iso) return "\u2013"
    let secs = Math.floor((new Date(iso) - (now || new Date())) / 1000)
    if (secs <= 0) return "now"
    const d = Math.floor(secs / 86400); secs %= 86400
    const h = Math.floor(secs / 3600);  secs %= 3600
    const m = Math.floor(secs / 60)
    if (d > 0) return d + "d " + h + "h"
    if (h > 0) return h + "h " + m + "m"
    return m + "m"
}

function formatTimeLeftWeekly(iso, now) {
    if (!iso) return "\u2013"
    let secs = Math.floor((new Date(iso) - (now || new Date())) / 1000)
    if (secs <= 0) return "now"
    const d = Math.floor(secs / 86400)
    if (d >= 1) return d + "d"
    let rem = secs % 86400
    const h = Math.floor(rem / 3600); rem %= 3600
    const m = Math.floor(rem / 60)
    if (h > 0) return h + "h " + m + "m"
    return m + "m"
}

// locale: pass Qt.locale() from the calling QML file (not available in .pragma library)
function formatResetDate(iso, locale) {
    if (!iso) return "\u2013"
    return new Date(iso).toLocaleDateString(locale, "MMM d")
}

function formatResetTime(iso, locale) {
    if (!iso) return "\u2013"
    const d = new Date(iso)
    const timeStr = d.toLocaleTimeString(locale, "hh:mm")
    if (d.toDateString() === new Date().toDateString()) return timeStr
    return d.toLocaleDateString(locale, "MMM d") + " " + timeStr
}
