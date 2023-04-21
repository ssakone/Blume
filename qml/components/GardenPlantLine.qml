import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Container {
    property string title: ""
    property string subtitle: ""
    property string roomName: ""
    property string imageSource: ""


    background: ClipRRect {
        radius: 15

        Rectangle {
            anchors.fill: parent
            radius: parent.radius

            border {
                color: "#e5e5e5"
                width: 1
            }

        }
    }

    contentItem: RowLayout {
        width: parent.width
    }

    Image {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumHeight: appWindow.width / 4
        Layout.maximumWidth: appWindow.width / 3.5
        Layout.alignment: Qt.AlignCenter
        source: imageSource
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Label {
            text: title
            font.pixelSize: 18
        }
        Label {
            text: subtitle
            font.pixelSize: 12
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }
        Label {
            text: roomName || ""
            color: "white"
            padding: 5
            font.capitalization: Font.AllUppercase
            background: Rectangle{
                color: Theme.colorPrimary
                radius: 5
            }
        }
    }

}

