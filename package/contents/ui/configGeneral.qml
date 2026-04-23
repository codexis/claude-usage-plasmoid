import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

ColumnLayout {
    id: page
    spacing: Kirigami.Units.smallSpacing * 2

    property string cfg_session5hResetMode
    property string cfg_session1wResetMode
    property string cfg_extraUsageDisplay
    property bool   cfg_showRing5h
    property bool   cfg_showRing7d
    property bool   cfg_showRingExtra

    QQC2.ButtonGroup { id: group5h }
    QQC2.ButtonGroup { id: group1w }
    QQC2.ButtonGroup { id: groupExtra }

    // ── Session limit ─────────────────────────────────────────────────────────
    QQC2.GroupBox {
        title: i18n("Session limit")
        Layout.fillWidth: true
        Layout.topMargin: 0

        ColumnLayout {
            width: parent.width
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents3.Label {
                    text: i18n("Visible")
                    Layout.fillWidth: true
                }
                QQC2.Switch {
                    checked: cfg_showRing5h
                    onToggled: cfg_showRing5h = checked
                }
            }

            ColumnLayout {
                enabled: cfg_showRing5h
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    text: i18n("Show reset as")
                    font.weight: Font.Medium
                }

                PlasmaComponents3.RadioButton {
                    QQC2.ButtonGroup.group: group5h
                    text: i18n("Remaining time")
                    checked: cfg_session5hResetMode === "timeLeft"
                    onClicked: cfg_session5hResetMode = "timeLeft"
                }
                PlasmaComponents3.Label {
                    text: i18n("e.g. 1h 23m")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    leftPadding: Kirigami.Units.gridUnit * 2
                }

                PlasmaComponents3.RadioButton {
                    QQC2.ButtonGroup.group: group5h
                    text: i18n("Exact reset time")
                    checked: cfg_session5hResetMode === "exactTime"
                    onClicked: cfg_session5hResetMode = "exactTime"
                }
                PlasmaComponents3.Label {
                    text: i18n("e.g. 14:30")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    leftPadding: Kirigami.Units.gridUnit * 2
                }
            }
        }
    }

    // ── Weekly limit ──────────────────────────────────────────────────────────
    QQC2.GroupBox {
        title: i18n("Weekly limit")
        Layout.fillWidth: true

        ColumnLayout {
            width: parent.width
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents3.Label {
                    text: i18n("Visible")
                    Layout.fillWidth: true
                }
                QQC2.Switch {
                    checked: cfg_showRing7d
                    onToggled: cfg_showRing7d = checked
                }
            }

            ColumnLayout {
                enabled: cfg_showRing7d
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    text: i18n("Show reset as")
                    font.weight: Font.Medium
                }

                PlasmaComponents3.RadioButton {
                    QQC2.ButtonGroup.group: group1w
                    text: i18n("Remaining time")
                    checked: cfg_session1wResetMode === "timeLeft"
                    onClicked: cfg_session1wResetMode = "timeLeft"
                }
                PlasmaComponents3.Label {
                    text: i18n("e.g. 3d / 12h 30m")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    leftPadding: Kirigami.Units.gridUnit * 2
                }

                PlasmaComponents3.RadioButton {
                    QQC2.ButtonGroup.group: group1w
                    text: i18n("Exact reset date")
                    checked: cfg_session1wResetMode === "exactDate"
                    onClicked: cfg_session1wResetMode = "exactDate"
                }
                PlasmaComponents3.Label {
                    text: i18n("e.g. Apr 15")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    leftPadding: Kirigami.Units.gridUnit * 2
                }
            }
        }
    }

    // ── Extra usage ───────────────────────────────────────────────────────────
    QQC2.GroupBox {
        title: i18n("Extra usage")
        Layout.fillWidth: true

        ColumnLayout {
            width: parent.width
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents3.Label {
                    text: i18n("Visible")
                    Layout.fillWidth: true
                }
                QQC2.Switch {
                    checked: cfg_showRingExtra
                    onToggled: cfg_showRingExtra = checked
                }
            }

            ColumnLayout {
                enabled: cfg_showRingExtra
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    text: i18n("Display format")
                    font.weight: Font.Medium
                }

                PlasmaComponents3.RadioButton {
                    QQC2.ButtonGroup.group: groupExtra
                    text: i18n("Amount spent")
                    checked: cfg_extraUsageDisplay === "spent"
                    onClicked: cfg_extraUsageDisplay = "spent"
                }
                PlasmaComponents3.Label {
                    text: i18n("e.g. €42.77 / €150")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    leftPadding: Kirigami.Units.gridUnit * 2
                }

                PlasmaComponents3.RadioButton {
                    QQC2.ButtonGroup.group: groupExtra
                    text: i18n("Amount remaining")
                    checked: cfg_extraUsageDisplay === "remaining"
                    onClicked: cfg_extraUsageDisplay = "remaining"
                }
                PlasmaComponents3.Label {
                    text: i18n("e.g. €107 / €150")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    leftPadding: Kirigami.Units.gridUnit * 2
                }
            }
        }
    }
}
