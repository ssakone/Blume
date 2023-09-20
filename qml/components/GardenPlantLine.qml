import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects as QGE
import ThemeEngine

ClipRRect {
    id: control
    property string title: ""
    property string subtitle: ""
    property string roomName: ""
    property string imageSource: ""
    property alias background: _background

    signal clicked
    radius: 15

    Rectangle {
        id: _background
        anchors.fill: parent
        radius: parent.radius

        layer.enabled: true
        layer.effect: QGE.DropShadow {
            radius: 2
            verticalOffset: 1
            color: "#ccc"
        }
    }
    RowLayout {
        width: parent.width
        Column {
            Layout.preferredWidth: control.height
            Layout.alignment: Qt.AlignCenter
            padding: 3
            ClipRRect {
                width: parent.width - 20
                height: control.height - 7
                radius: 10
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
            Layout.topMargin: 10
            Layout.bottomMargin: 15
            spacing: 4

            Label {
                text: title
                font.pixelSize: 16
                font.weight: Font.Medium
                Layout.fillWidth: true
                rightPadding: 10
                elide: Text.ElideRight
                opacity: .8
            }
            Label {
                text: subtitle
                font.pixelSize: 14
                font.weight: Font.Light
                opacity: .6
                Layout.fillWidth: true
                elide: Text.ElideRight
                rightPadding: 20
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Label {
                text: control.roomName || ""
                color: "white"
                padding: 2
                leftPadding: 7
                rightPadding: 7
                visible: text.length > 0
                //font.capitalization: Font.AllUppercase
                background: Rectangle {
                    color: $Colors.colorPrimary
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
