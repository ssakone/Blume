import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects as QGE
import ThemeEngine

import "../components_generic/"
import "../components_themed/"

ClipRRect {
    id: control
    property string title: ""
    property string subtitle: ""
    property string roomName: ""
    property string imageSource: ""
    property alias background: _background
    property var moreDetailsList: []

    signal clicked
    radius: 15

    Rectangle {
        id: _background
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius

        color: "white"
    }

    RowLayout {
        anchors.fill: parent

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 90
            Rectangle {
                anchors.fill: parent
                color: $Colors.colorSecondary
            }
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: imageSource
                asynchronous: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            spacing: 5

            Label {
                text: title
                font.pixelSize: 16
                font.weight: Font.Medium
                Layout.fillWidth: true
                rightPadding: 10
                elide: Text.ElideRight
                color: $Colors.colorPrimary
            }
            Label {
                text: subtitle
                font.pixelSize: 14
                font.weight: Font.Light
                opacity: .8
                Layout.fillWidth: true
                elide: Text.ElideRight
                rightPadding: 20
                color: "black"
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Flow {
                visible: moreDetailsList.length > 0
                Layout.fillWidth: true
                spacing: 7
                Repeater {
                    model: moreDetailsList
                    delegate: Row {
                        required property var modelData
                        IconSvg {
                            source: modelData.iconSource
                            width: 15
                            height: width
                            color: $Colors.colorPrimary
                        }

                        Label {
                            text: modelData.text
                            color: "black"
                            padding: 2
                            leftPadding: 7
                            rightPadding: 7
                            background: Rectangle {
                                color: $Colors.gray100
                                radius: 5
                            }
                        }
                    }
                }
            }

            Label {
                text: control.roomName || ""
                visible: control.roomName
                color: "white"
                padding: 2
                leftPadding: 7
                rightPadding: 7
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
