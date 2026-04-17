import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
    id: page

    property string cfg_colorTheme

    PlasmaComponents3.ComboBox {
        Kirigami.FormData.label: i18n("Color Theme:")
        id: colorModeBox
        textRole: "text"
        valueRole: "value"

        model: [
            { value: "original", text: i18n("Claude Dark (Original)") },
            { value: "plasma", text: i18n("System Native") }
        ]

        currentIndex: {
            for (var i = 0; i < model.length; ++i) {
                if (model[i].value === cfg_colorTheme) return i;
            }
            return 0;
        }
        onActivated: (index) => { cfg_colorTheme = model[index].value; }
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        text: i18n("System Native follows your current KDE Plasma theme (Light or Dark).")
        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        color: Kirigami.Theme.disabledTextColor
        wrapMode: Text.WordWrap
    }
}
