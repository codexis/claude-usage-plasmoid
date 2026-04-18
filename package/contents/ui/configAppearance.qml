import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
    id: page

    property string cfg_colorTheme
    property string cfg_customGreen
    property string cfg_customYellow
    property string cfg_customOrange
    property string cfg_customRed

    PlasmaComponents3.ComboBox {
        Kirigami.FormData.label: i18n("Color Theme:")
        id: colorModeBox
        textRole: "text"
        valueRole: "value"

        model: [
            { value: "plasma",   text: i18n("Follow System Theme") },
            { value: "original", text: i18n("Custom Colors") }
        ]

        currentIndex: {
            for (var i = 0; i < model.length; ++i) {
                if (model[i].value === cfg_colorTheme) return i;
            }
            return 0;
        }
        onActivated: function(index) { cfg_colorTheme = model[index].value }
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        text: cfg_colorTheme === "plasma"
              ? i18n("Follow System Theme uses your current KDE Plasma theme (Light or Dark).")
              : i18n("Customize the gauge colors for each usage level.")
        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        color: Kirigami.Theme.disabledTextColor
        wrapMode: Text.WordWrap
    }

    Kirigami.Separator {
        Layout.fillWidth: true
        visible: cfg_colorTheme === "original"
    }

    ColorDialog {
        id: colorDlg
        property string currentKey: ""
        onAccepted: page["cfg_custom" + currentKey] = selectedColor
    }

    Repeater {
        model: [
            { key: "Green",  label: i18n("Low:")      },
            { key: "Yellow", label: i18n("Medium:")   },
            { key: "Orange", label: i18n("High:")     },
            { key: "Red",    label: i18n("Critical:") }
        ]

        delegate: RowLayout {
            visible: cfg_colorTheme === "original"
            Kirigami.FormData.label: modelData.label
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                width: Kirigami.Units.gridUnit * 2
                height: Kirigami.Units.gridUnit
                color: page["cfg_custom" + modelData.key]
                radius: Kirigami.Units.smallSpacing
                border.color: Kirigami.Theme.textColor
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDlg.currentKey = modelData.key
                        colorDlg.selectedColor = page["cfg_custom" + modelData.key]
                        colorDlg.open()
                    }
                }
            }
        }
    }
}
