import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    // Plasma automatically reads/writes Plasmoid.configuration.session5hResetMode
    property string cfg_session5hResetMode: "timeLeft"

    ColumnLayout {
        Kirigami.FormData.label: "Session (5h) — label below %:"
        spacing: 6

        RadioButton {
            id: rbTimeLeft
            text: "Remaining time  (e.g. \"1h 23m\")"
            checked: cfg_session5hResetMode === "timeLeft"
            onCheckedChanged: if (checked) cfg_session5hResetMode = "timeLeft"
        }

        RadioButton {
            id: rbExactTime
            text: "Exact reset time  (e.g. \"14:30\")"
            checked: cfg_session5hResetMode === "exactTime"
            onCheckedChanged: if (checked) cfg_session5hResetMode = "exactTime"
        }
    }
}
