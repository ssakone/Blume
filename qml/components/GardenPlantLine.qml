import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine

ClipRRect {
    id: control
    property string title: ""
    property string subtitle: ""
    property string roomName: ""
    property string imageSource: ""

    signal clicked
    radius: 15

    Rectangle {
        anchors.fill: parent
        radius: parent.radius

        border {
            color: "#e5e5e5"
            width: 1
        }
    }
    RowLayout {
        width: parent.width
        Column {
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            padding: 10
            ClipRRect {
                width: parent.width - 20
                height: width
                radius: 12
                Rectangle {
                    anchors.fill: parent
                    color: $Colors.gray100
                    ColorImage {
                        anchors.centerIn: parent
                        width: 60
                        height: 60
                        source: Icons.palmTree
                        opacity: .4
                    }
                }

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: imageSource
                    asynchronous: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 10
            Layout.bottomMargin: 15

            Label {
                text: title
                font.pixelSize: 21
                font.weight: Font.Medium
                Layout.fillWidth: true
                rightPadding: 10
                wrapMode: Label.Wrap
                opacity: .8
            }
            Label {
                text: subtitle
                font.pixelSize: 14
                opacity: .6
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Label {
                text: control.roomName || ""
                color: "white"
                padding: 5
                visible: text.length > 0
                font.capitalization: Font.AllUppercase
                background: Rectangle {
                    color: Theme.colorPrimary
                    radius: 5
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
