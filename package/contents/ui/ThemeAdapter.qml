import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

QtObject {
    id: root

    readonly property bool isCustom: (plasmoid.configuration.colorTheme || "plasma") !== "plasma"

    // Always system colors
    property color bg:        Kirigami.Theme.backgroundColor
    property color ring:      Kirigami.Theme.alternateBackgroundColor
    property color text:      Kirigami.Theme.textColor
    property color subText:   Kirigami.Theme.disabledTextColor
    property color error:     Kirigami.Theme.negativeTextColor
    property color separator: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
    readonly property string monoFamily: (Kirigami.Theme.fixedWidthFont && Kirigami.Theme.fixedWidthFont.family) ? Kirigami.Theme.fixedWidthFont.family : "monospace"

    // Arc colors: system semantic or user config with defaults
    property color green:  isCustom ? (plasmoid.configuration.customGreen  || "#22c55e") : Kirigami.Theme.positiveTextColor
    property color yellow: isCustom ? (plasmoid.configuration.customYellow || "#f8da19") : "#f8da19"
    property color orange: isCustom ? (plasmoid.configuration.customOrange || "#ff7700") : Kirigami.Theme.neutralTextColor
    property color red:    isCustom ? (plasmoid.configuration.customRed    || "#e40000") : Kirigami.Theme.negativeTextColor
}
