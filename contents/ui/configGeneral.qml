import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    // Plasma automatically reads/writes Plasmoid.configuration.session5hResetMode.
    // No initializer — property starts as "" so Plasma's load always triggers a
    // change signal, allowing Apply/OK change-detection to work from first open.
    property string cfg_session5hResetMode
    property string cfg_session1wResetMode

    ColumnLayout {
        Kirigami.FormData.label: "Session (5h) — label below %:"
        spacing: 6

        RadioButton {
            id: rbTimeLeft
            text: "Remaining time  (e.g. \"1h 23m\")"
            checked: cfg_session5hResetMode === "timeLeft"
            onClicked: cfg_session5hResetMode = "timeLeft"
        }

        RadioButton {
            id: rbExactTime
            text: "Exact reset time  (e.g. \"14:30\")"
            checked: cfg_session5hResetMode === "exactTime"
            onClicked: cfg_session5hResetMode = "exactTime"
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    ColumnLayout {
        Kirigami.FormData.label: "Weekly (7d) — label below %:"
        spacing: 6

        RadioButton {
            id: rbWeeklyTimeLeft
            text: "Remaining time  (e.g. \"3d\" or \"12h 30m\")"
            checked: cfg_session1wResetMode === "timeLeft"
            onClicked: cfg_session1wResetMode = "timeLeft"
        }

        RadioButton {
            id: rbWeeklyExactDate
            text: "Exact reset date  (e.g. \"Apr 15\")"
            checked: cfg_session1wResetMode === "exactDate"
            onClicked: cfg_session1wResetMode = "exactDate"
        }
    }
}
