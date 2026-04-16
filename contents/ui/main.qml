import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasma5support as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "./"

PlasmoidItem {
    id: root

    Kirigami.Theme.inherit: true
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    // ── Size ────────────────────────────────────────────────────────────────
    preferredRepresentation: fullRepresentation
    Layout.minimumWidth:  240
    Layout.minimumHeight: 160
    Layout.preferredWidth: 320
    Layout.preferredHeight: 200

    // ── State ────────────────────────────────────────────────────────────────
    property real usage5h:  0.0   // 0.0 – 1.0
    property real usage7d:  0.0
    property string reset5h: ""
    property string reset7d: ""
    property string errorMsg: ""
    property bool   loaded:   false

    property int  _pollInterval: 300000   // 5 min base
    property int  _tick: 0               // incremented every minute to refresh time labels
    property bool _fetching: false       // guard against concurrent fetches

    ThemeAdapter {
        id: themeAdapter
    }

    function colorFor(pct) {
        if (pct < 0.5)  return themeAdapter.green
        if (pct < 0.75) return themeAdapter.yellow
        if (pct < 0.9)  return themeAdapter.orange
        return themeAdapter.red
    }

    // Relative time remaining: "1h 23m", "45m", "now"
    function formatTimeLeft(iso) {
        if (!iso) return "–"
        var secs = Math.floor((new Date(iso) - new Date()) / 1000)
        if (secs <= 0) return "now"
        var d = Math.floor(secs / 86400); secs %= 86400
        var h = Math.floor(secs / 3600);  secs %= 3600
        var m = Math.floor(secs / 60)
        if (d > 0) return d + "d " + h + "h"
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }

    // Weekly version: show only days if > 24h, else hours + minutes
    function formatTimeLeftWeekly(iso) {
        if (!iso) return "–"
        var secs = Math.floor((new Date(iso) - new Date()) / 1000)
        if (secs <= 0) return "now"
        var d = Math.floor(secs / 86400)
        if (d >= 1) return d + "d"
        var h = Math.floor(secs / 3600); secs %= 3600
        var m = Math.floor(secs / 60)
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }

    // Absolute reset date: "Apr 15"
    function formatResetDate(iso) {
        if (!iso) return "–"
        var d = new Date(iso)
        var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        return months[d.getMonth()] + " " + d.getDate()
    }

    // Exact reset clock time: "14:30" (today) or "Apr 16 14:30" (another day)
    function formatResetTime(iso) {
        if (!iso) return "–"
        var d = new Date(iso)
        var hh = d.getHours();   var hStr = (hh < 10 ? "0" : "") + hh
        var mm = d.getMinutes(); var mStr = (mm < 10 ? "0" : "") + mm
        var timeStr = hStr + ":" + mStr
        var now = new Date()
        if (d.toDateString() === now.toDateString()) return timeStr
        var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        return months[d.getMonth()] + " " + d.getDate() + " " + timeStr
    }

    // ── DataSource — runs Python script via shell ─────────────────────────────
    PlasmaCore.DataSource {
        id: ds
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            var out = (data["stdout"] || "").trim()
            disconnectSource(source)
            root._fetching = false
            if (!out) return
            try {
                var obj = JSON.parse(out)
                if (obj.error === "http_429") {
                    // back off: double the interval, cap at 30 min
                    root._pollInterval = Math.min(root._pollInterval * 2, 1800000)
                    pollTimer.restart()
                    root.errorMsg = "rate limit — next retry in " + Math.round(root._pollInterval / 60000) + "m"
                    root.loaded   = false
                } else if (obj.error) {
                    root.errorMsg = obj.error
                    root.loaded   = false
                } else {
                    var u5 = obj.five_hour ? (obj.five_hour.utilization !== undefined ? obj.five_hour.utilization : 0) : 0
                    var u7 = obj.seven_day ? (obj.seven_day.utilization !== undefined ? obj.seven_day.utilization : 0) : 0
                    root.usage5h  = u5 > 1 ? u5 / 100 : u5
                    root.usage7d  = u7 > 1 ? u7 / 100 : u7
                    root.reset5h  = obj.five_hour ? obj.five_hour.resets_at : ""
                    root.reset7d  = obj.seven_day ? obj.seven_day.resets_at : ""
                    root.errorMsg     = ""
                    root.loaded       = true
                    root._pollInterval = 300000   // reset to 5 min on success
                    pollTimer.restart()
                }
            } catch(e) {
                root.errorMsg = "parse error"
                root.loaded   = false
            }
        }
    }

    function doFetch() {
        if (root._fetching) return
        root._fetching = true
        var script = Qt.resolvedUrl("../code/fetch_usage.py").toString().replace(/^file:\/\//, "")
        ds.connectSource("python3 \"" + script + "\"")
    }

    // ── Timers ───────────────────────────────────────────────────────────────
    Timer {
        id: pollTimer
        interval: root._pollInterval
        repeat:   true
        running:  true
        onTriggered: doFetch()
    }

    Timer {
        interval: 60000   // 1 min
        repeat:   true
        running:  root.loaded
        onTriggered: root._tick++
    }

    Component.onCompleted: doFetch()

    // ── Full representation ──────────────────────────────────────────────────
    fullRepresentation: Rectangle {
        id: card
        color:        themeAdapter.bg
        radius:       16
        anchors.fill: parent

        border.color: Qt.rgba(1,1,1,0.06)
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: Qt.rgba(56/255, 189/255, 248/255, 0.04)
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: root.loaded ? themeAdapter.green : themeAdapter.subText
                    Behavior on color { ColorAnimation { duration: 600 } }
                }

                PlasmaComponents3.Label {
                    text: "Claude AI Usage"
                    color: themeAdapter.text
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.family: "monospace"
                    Layout.fillWidth: true
                }

                PlasmaComponents3.Label {
                    text: "↻"
                    color: themeAdapter.subText
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: doFetch()
                        hoverEnabled: true
                        onEntered: parent.color = themeAdapter.text
                        onExited:  parent.color = themeAdapter.subText
                    }
                }
            }

            // ── Rings row ────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                spacing: 12

                RingGauge {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    label:    "session"
                    value:    root.usage5h
                    accent: {
                        var pct = root.usage5h
                        if (pct < 0.5)  return themeAdapter.green
                        if (pct < 0.75) return themeAdapter.yellow
                        if (pct < 0.9)  return themeAdapter.orange
                        return themeAdapter.red
                    }
                    ringBg:   themeAdapter.ring
                    resetIn:  (root._tick,
                              plasmoid.configuration.session5hResetMode === "exactTime"
                              ? root.formatResetTime(root.reset5h)
                              : root.formatTimeLeft(root.reset5h))
                    errMode:  !root.loaded
                    subColor: themeAdapter.subText
                    textColor: themeAdapter.text
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: Qt.rgba(1,1,1,0.07)
                }

                RingGauge {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    label:    "weekly"
                    value:    root.usage7d
                    accent: {
                        var pct = root.usage7d
                        if (pct < 0.5)  return themeAdapter.green
                        if (pct < 0.75) return themeAdapter.yellow
                        if (pct < 0.9)  return themeAdapter.orange
                        return themeAdapter.red
                    }
                    ringBg:   themeAdapter.ring
                    resetIn:  (root._tick,
                               plasmoid.configuration.session1wResetMode === "timeLeft"
                               ? root.formatTimeLeftWeekly(root.reset7d)
                               : root.formatResetDate(root.reset7d))
                    errMode:  !root.loaded
                    subColor: themeAdapter.subText
                    textColor: themeAdapter.text
                }
            }

            // ── Error / status strip ─────────────────────────────────────────
            PlasmaComponents3.Label {
                visible: root.errorMsg !== ""
                text: {
                    switch (root.errorMsg) {
                        case "no_token":   return "⚠  No token — install Claude Code or add token to config"
                        case "no network": return "⚠  No network connection"
                        case "timeout":    return "⚠  Request timed out"
                        default:           return "⚠  " + root.errorMsg
                    }
                }
                color: themeAdapter.orange
                font.pixelSize: 10
                font.family: "monospace"
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }
    }

    // ── Compact representation (panel icon) ──────────────────────────────────
    compactRepresentation: Item {
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
        PlasmaComponents3.Label {
            anchors.centerIn: parent
            text: root.loaded ? Math.round(root.usage5h * 100) + "%" : "…"
            color: root.loaded ? root.colorFor(root.usage5h) : themeAdapter.subText
            font.pixelSize: 11
            font.weight: Font.Bold
            font.family: "monospace"
        }
    }
}
