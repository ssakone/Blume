import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtQuick.Controls.impl 2.15
//import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

Tumbler {
    id: control
    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight * 2

    model: [1, 2, 3]

    background: Item {
        //
    }

    delegate: Text {
        text: modelData
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: (control.currentIndex+1 === modelData) ? Theme.colorPrimary : Theme.colorText
        opacity: (control.enabled ? 1.0 : 0.8) - (Math.abs(Tumbler.displacement) / (control.visibleItemCount * 0.55))
        font.pixelSize: (control.currentIndex+1 === modelData) ? Theme.fontSizeComponent+4 : Theme.fontSizeComponent
        font.bold: false
    }
}
