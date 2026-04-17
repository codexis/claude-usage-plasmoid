import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

QtObject {
    id: root

    property string mode: plasmoid.configuration.colorTheme || "plasma"

    // System colors from Kirigami Theme
    property color sysBg: Kirigami.Theme.backgroundColor
    property color sysRing: Kirigami.Theme.alternateBackgroundColor
    property color sysGreen: Kirigami.Theme.positiveTextColor
    property color sysYellow: Kirigami.Theme.warningTextColor
    property color sysOrange: Kirigami.Theme.neutralTextColor
    property color sysRed: Kirigami.Theme.negativeTextColor
    property color sysText: Kirigami.Theme.textColor
    property color sysSubText: Kirigami.Theme.disabledTextColor

    // Original dark aesthetic colors
    readonly property color origBg: "#0d1117"
    readonly property color origRing: "#1e2535"
    readonly property color origGreen: "#22c55e"
    readonly property color origYellow: "#f8da19"
    readonly property color origOrange: "#ff7700"
    readonly property color origRed: "#e40000"
    readonly property color origText: "#e2e8f0"
    readonly property color origSubText: "#64748b"

    // Effective Palette
    property color bg:      mode === "plasma" ? sysBg      : origBg
    property color ring:    mode === "plasma" ? sysRing    : origRing
    property color green:   mode === "plasma" ? sysGreen   : origGreen
    property color yellow:  mode === "plasma" ? sysYellow  : origYellow
    property color orange:  mode === "plasma" ? sysOrange  : origOrange
    property color red:     mode === "plasma" ? sysRed     : origRed
    property color text:    mode === "plasma" ? sysText    : origText
    property color subText: mode === "plasma" ? sysSubText : origSubText

    readonly property string monoFamily: (Kirigami.Theme.fixedWidthFont && Kirigami.Theme.fixedWidthFont.family) ? Kirigami.Theme.fixedWidthFont.family : "monospace"
}
