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

    RingConfigSection {
        title: i18n("Session limit")
        Layout.topMargin: 0
        showEnabled: cfg_showRing5h
        mode: cfg_session5hResetMode
        subHeading: i18n("Show reset as")
        options: [
            { value: "timeLeft",  label: i18n("Remaining time"),   example: i18n("e.g. 1h 23m") },
            { value: "exactTime", label: i18n("Exact reset time"),  example: i18n("e.g. 14:30")  }
        ]
        onShowToggled: (val) => cfg_showRing5h = val
        onModeSelected: (val) => cfg_session5hResetMode = val
    }

    RingConfigSection {
        title: i18n("Weekly limit")
        showEnabled: cfg_showRing7d
        mode: cfg_session1wResetMode
        subHeading: i18n("Show reset as")
        options: [
            { value: "timeLeft",  label: i18n("Remaining time"),   example: i18n("e.g. 3d / 12h 30m") },
            { value: "exactDate", label: i18n("Exact reset date"),  example: i18n("e.g. Apr 15")        }
        ]
        onShowToggled: (val) => cfg_showRing7d = val
        onModeSelected: (val) => cfg_session1wResetMode = val
    }

    RingConfigSection {
        title: i18n("Extra usage")
        showEnabled: cfg_showRingExtra
        mode: cfg_extraUsageDisplay
        subHeading: i18n("Display format")
        options: [
            { value: "spent",     label: i18n("Amount spent"),     example: i18n("e.g. €42.77 / €150") },
            { value: "remaining", label: i18n("Amount remaining"),  example: i18n("e.g. €107 / €150")  }
        ]
        onShowToggled: (val) => cfg_showRingExtra = val
        onModeSelected: (val) => cfg_extraUsageDisplay = val
    }
}
