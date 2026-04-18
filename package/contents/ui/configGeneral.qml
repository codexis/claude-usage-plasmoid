import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
    id: page

    // Plasma automatically reads/writes Plasmoid.configuration.session5hResetMode.
    // No initializer — property starts as "" so Plasma's load always triggers a
    // change signal, allowing Apply/OK change-detection to work from first open.
    property string cfg_session5hResetMode
    property string cfg_session1wResetMode

    QQC2.ButtonGroup { id: group5h }
    QQC2.ButtonGroup { id: group1w }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Session (5h) — reset time format:")
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.RadioButton {
            QQC2.ButtonGroup.group: group5h
            text: i18n("Remaining time (e.g. \"1h 23m\")")
            checked: cfg_session5hResetMode === "timeLeft"
            onClicked: cfg_session5hResetMode = "timeLeft"
        }

        PlasmaComponents3.RadioButton {
            QQC2.ButtonGroup.group: group5h
            text: i18n("Exact reset time (e.g. \"14:30\")")
            checked: cfg_session5hResetMode === "exactTime"
            onClicked: cfg_session5hResetMode = "exactTime"
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Weekly (7d) — reset time format:")
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.RadioButton {
            QQC2.ButtonGroup.group: group1w
            text: i18n("Remaining time (e.g. \"3d\" or \"12h 30m\")")
            checked: cfg_session1wResetMode === "timeLeft"
            onClicked: cfg_session1wResetMode = "timeLeft"
        }

        PlasmaComponents3.RadioButton {
            QQC2.ButtonGroup.group: group1w
            text: i18n("Exact reset date (e.g. \"Apr 15\")")
            checked: cfg_session1wResetMode === "exactDate"
            onClicked: cfg_session1wResetMode = "exactDate"
        }
    }
}
