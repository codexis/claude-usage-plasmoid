import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

QQC2.GroupBox {
    id: section

    property bool   showEnabled
    property string mode
    property string subHeading
    property var    options: []

    signal showToggled(bool val)
    signal modeSelected(string val)

    Layout.fillWidth: true

    QQC2.ButtonGroup { id: btnGroup }

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
                checked: section.showEnabled
                onToggled: section.showToggled(checked)
            }
        }

        ColumnLayout {
            enabled: section.showEnabled
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Label {
                text: section.subHeading
                font.weight: Font.Medium
            }

            Repeater {
                model: section.options
                delegate: ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing
                    PlasmaComponents3.RadioButton {
                        QQC2.ButtonGroup.group: btnGroup
                        text: modelData.label
                        checked: section.mode === modelData.value
                        onClicked: section.modeSelected(modelData.value)
                    }
                    PlasmaComponents3.Label {
                        text: modelData.example
                        color: Kirigami.Theme.disabledTextColor
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        leftPadding: Kirigami.Units.gridUnit * 2
                    }
                }
            }
        }
    }
}
