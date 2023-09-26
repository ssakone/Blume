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
    TextField {
        id: inputField
        background: Rectangle {
            radius: 24
            color: "#e2e0dc"
        }
        font.pixelSize: 22
        color: "black"
        anchors.fill: parent
        padding: 10
        topPadding: 11
        leftPadding: 14
        rightPadding: 14
    }
}
