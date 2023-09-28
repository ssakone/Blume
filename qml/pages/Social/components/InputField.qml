import QtQuick
import QtQuick.Controls
import Qaterial as Qaterial

Rectangle {
    property alias font: inputField.font
    property alias field: inputField
    property alias padding: inputField.padding
    anchors.margins: 8
    radius: 24
    id: textArea
    color: Qt.rgba(0,0,0,0)
    TextField {
        id: inputField
        background: Rectangle {
            color: Qt.rgba(0,0,0,0)
            radius: 10
            border {
                width: 1
                color: $Colors.colorPrimary
            }
        }
        font.pixelSize: 22
        color: "black"
        placeholderTextColor: $Colors.colorPrimary
        anchors.fill: parent
        padding: 10
        topPadding: 11
        leftPadding: 14
        rightPadding: 14
    }
}
