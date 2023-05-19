import QtQuick
import QtQuick.Controls

Popup {
    id: control

    property string source: ""

    signal swithMode

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    padding: 0
    background: Rectangle {
        color: $Colors.black
    }


    Image {
        anchors.fill: parent
        source: control.source

        clip: true
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        anchors.fill: parent
        onClicked: swithMode()
    }
}

