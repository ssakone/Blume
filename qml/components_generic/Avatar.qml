import QtQuick
import "../components/"

MouseArea {
    height: 60
    width: 60
    property alias source: img.source

    property int avatarSize: 50
    Rectangle {
        width: avatarSize
        height: avatarSize
        anchors.centerIn: parent
        radius: avatarSize / 2
        clip: true
        color: "#ccc"

        ClipRRect {
            anchors.fill: parent
            radius: parent.radius
            Image {
                id: img
                width: avatarSize
                height: avatarSize
                asynchronous: false
                fillMode: Image.PreserveAspectCrop
            }
        }
    }
}
