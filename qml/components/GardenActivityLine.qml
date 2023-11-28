import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects as QGE

import ThemeEngine
import "../components_generic/"
import "../components_themed/"

Rectangle {
    id: control

    property string title: ""
    property string plant_name: ""
    property string subtitle: ""
    property alias icon: iconSvg
    property alias image: image
    property string frequency: ""

    property bool isDone: false
    property bool hideDelete: false
    property bool hideCheckbox: false

    signal clicked
    signal deleteClicked
    signal checked(bool newStatus)

    radius: 7
    height: 120
    color: $Colors.colorTertiary

    layer.enabled: true
    layer.effect: QGE.DropShadow {
        radius: 2
        verticalOffset: 1
        color: "#ccc"
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 5
            rightMargin: 5
        }
        spacing: 6

        ClipRRect {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.margins: 10
            radius: height / 2

            Rectangle {
                anchors.fill: parent
                color: '#e5e5e5'
                radius: height / 2
            }

            Image {
                id: image
                anchors.fill: parent
            }
        }

        Item {
            id: content
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                Item {
                    Layout.fillHeight: true
                }

                Column {
                    padding: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 3

                    Row {
                        width: parent.width
                        padding: 0
                        spacing: 5

                        ColorImage {
                            id: iconSvg
                            color: $Colors.colorPrimary
                            width: 20
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: title
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            font.strikeout: control.isDone
                            width: parent.width - iconSvg.width - 5
                            elide: Label.ElideRight
                            wrapMode: Label.Wrap
                            clip: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        width: parent.width
                        padding: 0
                        spacing: 5

                        ColorImage {
                            color: $Colors.colorPrimary
                            source: "qrc:/assets/icons_custom/menubottom_plants.svg"
                            width: 20
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: plant_name
                            font.pixelSize: 14
                            opacity: .6
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        width: parent.width
                        padding: 0
                        spacing: 5

                        ColorImage {
                            color: $Colors.colorPrimary
                            source: Icons.home
                            width: 20
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: subtitle
                            font.pixelSize: 14
                            opacity: .6
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Label {
                        visible: frequency != ""
                        text: frequency
                        font.pixelSize: 14
                        opacity: .6
                        elide: Text.ElideRight
                        padding: 5
                        leftPadding: 10
                        rightPadding: 10
                        background: Rectangle {
                            color: $Colors.colorSecondary
                            radius: 5
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: $Colors.gray100
        }

        Item {
            visible: !control.hideDelete
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30

            ColorImage {
                color: $Colors.red400
                anchors.fill: parent
                layer.enabled: true
                source: "qrc:/assets/icons_material/baseline-delete-24px.svg"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"
                onClicked: control.deleteClicked()
            }
        }

        Item {
            visible: !control.hideCheckbox
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            Rectangle {
                anchors.fill: parent
                radius: 5
                color: control.isDone ? $Colors.colorPrimary : $Colors.gray50
                border.color: control.isDone ? $Colors.colorPrimary : $Colors.gray600
                border.width: 1
                IconSvg {
                    visible: control.isDone
                    source: Icons.check
                    anchors.fill: parent
                    color: 'white'
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        control.isDone = !control.isDone
                        control.checked(control.isDone)
                    }
                }
            }
        }
    }

    MouseArea {
        parent: content
        anchors.fill: parent
        cursorShape: "PointingHandCursor"
        onClicked: control.clicked()
    }
}
