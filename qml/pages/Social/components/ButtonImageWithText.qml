import QtQuick
import QtQuick.Controls

MouseArea {
    id: control
    height: 50
    width: 50
    property string text: ""
    property string icon: ""
    property real iconSize: 32
    property font textFont: _insideText.font

    Row {
        anchors.centerIn: parent
        spacing: 5
        ColorImage {
            width: control.iconSize
            height: control.iconSize
            anchors.verticalCenter: parent.verticalCenter
            source: control.icon
        }
        Text {
            id: _insideText
            anchors.verticalCenter: parent.verticalCenter
            text: control.text
        }
    }
}
