import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasma5support as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import "../code/timeUtils.js" as TimeUtils


PlasmoidItem {
    id: root

    Kirigami.Theme.inherit: true
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    toolTipMainText: i18n("Claude AI Usage")
    toolTipSubText: root.loaded
        ? i18n("Session: %1% · Weekly: %2%", Math.round(root.usage5h * 100), Math.round(root.usage7d * 100))
        : (root.errorMsg || i18n("Loading…"))

    // ── Size ────────────────────────────────────────────────────────────────
    preferredRepresentation: fullRepresentation
    Layout.minimumWidth: 400
    Layout.minimumHeight: 220
    Layout.preferredWidth: 500
    Layout.preferredHeight: 300

    // ── State ────────────────────────────────────────────────────────────────
    property real usage5h:  0.0   // 0.0 – 1.0
    property real usage7d:  0.0
    property string reset5h: ""
    property string reset7d: ""
    property string errorMsg: ""
    property bool   loaded:   false

    readonly property int kPollBase:     300000   // 5 min
    readonly property int kPollMax:     1800000   // 30 min
    readonly property int kTickInterval:  60000   // 1 min

    property int  _pollInterval: kPollBase
    property int  _tick: 0               // cycles 0–1439, triggers time-label re-eval each minute
    property bool _fetching: false       // guard against concurrent fetches
    property int  _rateLimitRetry: 0     // minutes until next retry after 429

    ThemeAdapter {
        id: themeAdapter
    }

    function colorFor(pct) {
        if (pct < 0.5)  return themeAdapter.green
        if (pct < 0.75) return themeAdapter.yellow
        if (pct < 0.9)  return themeAdapter.orange
        return themeAdapter.red
    }

    function computeResetIn5h() {
        root._tick  // read to establish reactive dependency; re-evaluates each minute
        const locale = Qt.locale()
        return plasmoid.configuration.session5hResetMode === "exactTime"
            ? TimeUtils.formatResetTime(root.reset5h, locale)
            : TimeUtils.formatTimeLeft(root.reset5h)
    }

    function computeResetIn7d() {
        root._tick  // read to establish reactive dependency; re-evaluates each minute
        const locale = Qt.locale()
        return plasmoid.configuration.session1wResetMode === "timeLeft"
            ? TimeUtils.formatTimeLeftWeekly(root.reset7d)
            : TimeUtils.formatResetDate(root.reset7d, locale)
    }

    // ── DataSource — runs Python script via shell ─────────────────────────────
    PlasmaCore.DataSource {
        id: ds
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            const out = (data["stdout"] || "").trim()
            disconnectSource(source)
            root._fetching = false
            if (!out) return
            try {
                const obj = JSON.parse(out)
                if (obj.error === "http_429") {
                    // back off: double the interval, cap at 30 min
                    root._pollInterval = Math.min(root._pollInterval * 2, root.kPollMax)
                    pollTimer.restart()
                    root._rateLimitRetry = Math.round(root._pollInterval / 60000)
                    root.errorMsg = "rate_limit"
                    root.loaded   = false
                } else if (obj.error) {
                    root.errorMsg = obj.error
                    root.loaded   = false
                } else {
                    const u5 = obj.five_hour ? (obj.five_hour.utilization !== undefined ? obj.five_hour.utilization : 0) : 0
                    const u7 = obj.seven_day ? (obj.seven_day.utilization !== undefined ? obj.seven_day.utilization : 0) : 0
                    root.usage5h  = u5 > 1 ? u5 / 100 : u5
                    root.usage7d  = u7 > 1 ? u7 / 100 : u7
                    root.reset5h  = obj.five_hour ? obj.five_hour.resets_at : ""
                    root.reset7d  = obj.seven_day ? obj.seven_day.resets_at : ""
                    root.errorMsg     = ""
                    root.loaded       = true
                    root._pollInterval = root.kPollBase
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
        const script  = Qt.resolvedUrl("../code/fetch_usage.py").toString().replace(/^file:\/\//, "")
        // Shell-safe: wrap in single quotes and escape any embedded single quotes.
        const escaped = script.replace(/'/g, "'\\''")
        ds.connectSource("python3 '" + escaped + "'")
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
        interval: root.kTickInterval
        repeat:   true
        running:  root.loaded
        onTriggered: root._tick = (root._tick + 1) % 1440
    }

    Component.onCompleted: doFetch()

    // ── Full representation ──────────────────────────────────────────────────
    fullRepresentation: Item {
        id: card
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin:    Kirigami.Units.smallSpacing
            anchors.leftMargin:   Kirigami.Units.gridUnit
            anchors.rightMargin:  Kirigami.Units.gridUnit
            anchors.bottomMargin: Kirigami.Units.gridUnit
            spacing: Kirigami.Units.smallSpacing

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    color: root.loaded ? themeAdapter.green : themeAdapter.subText
                    Behavior on color { ColorAnimation { duration: 600 } }
                    width: Kirigami.Units.smallSpacing; height: Kirigami.Units.smallSpacing; radius: width / 2
                }

                PlasmaComponents3.Label {
                    color: themeAdapter.text
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                    font.weight: Font.Medium
                    font.family: themeAdapter.monoFamily
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n("Claude AI Usage")
                }

                PlasmaComponents3.ToolButton {
                    icon.name: "view-refresh"
                    onClicked: doFetch()
                }
            }

            // ── Rings row ────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                spacing: Kirigami.Units.gridUnit

                RingGauge {
                    accent: root.colorFor(root.usage5h)
                    errMode:  !root.loaded
                    label:    i18n("Session")
                    Layout.fillHeight: true
                    Layout.fillWidth:  true
                    resetIn:  root.computeResetIn5h()
                    ringBg:   themeAdapter.ring
                    subColor: themeAdapter.subText
                    textColor: themeAdapter.text
                    value:    root.usage5h
                }

                Rectangle {
                    color: themeAdapter.separator
                    Layout.fillHeight: true
                    width: 1
                }

                RingGauge {
                    accent:    root.colorFor(root.usage7d)
                    errMode:   !root.loaded
                    label:     i18n("Weekly")
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    resetIn:   root.computeResetIn7d()
                    ringBg:    themeAdapter.ring
                    subColor:  themeAdapter.subText
                    textColor: themeAdapter.text
                    value:     root.usage7d
                }
            }

            // ── Error / status strip ─────────────────────────────────────────
            PlasmaComponents3.Label {
                color: themeAdapter.error
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                font.family: themeAdapter.monoFamily
                Layout.fillWidth: true
                text: {
                    switch (root.errorMsg) {
                        case "no_token":   return i18n("⚠  No token — install Claude Code or add token to config file")
                        case "no network": return i18n("⚠  No network connection")
                        case "timeout":    return i18n("⚠  Request timed out")
                        case "auth_error": return i18n("⚠  Token invalid or expired — re-login to Claude Code")
                        case "rate_limit": return i18n("⚠  Rate limited — retry in %1 min", root._rateLimitRetry)
                        default:           return i18n("⚠  %1", root.errorMsg)
                    }
                }
                visible: root.errorMsg !== ""
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
            color: root.loaded ? root.colorFor(root.usage5h) : themeAdapter.subText
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            font.weight: Font.Bold
            font.family: themeAdapter.monoFamily
            text: root.loaded ? Math.round(root.usage5h * 100) + "%" : "…"
        }
    }
}
