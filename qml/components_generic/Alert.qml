import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../components"

Item {
    id: root

    property int time: 1500
    property string text: ""

    property alias textItem: _text
    property alias icon: _icon
    property alias background: _bg

    property var callback: function() {}

    visible: text !== ""

    Timer {
        id: tm
        interval: time
        repeat: false
        running: root.visible
        onTriggered: root.callback()
    }

    Container {
        anchors.fill: parent
        contentItem: RowLayout {
            width: parent.width
        }

        background: Rectangle {
            id: _bg
            radius: 10
            color: Material.color(Material.Red, Material.Shade500)
        }
        Label {
            id: _text
            Layout.fillWidth: true
            text: errorText
            font.pixelSize: 14
            font.weight: Font.Light
            padding: 7
            wrapMode: Text.Wrap
        }
        IconSvg {
            id: _icon
            source: Icons.bellCancel
            color: "white"
            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"
                onClicked: tm.stop()
            }
        }
    }
}


