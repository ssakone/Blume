import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects as QGE

import ThemeEngine
import "../components_generic"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property alias icon: iconSvg

    property bool time_inline: true
    property string hours: "15"
    property string minutes: "00"

    signal clicked

    radius: 4

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 5
            rightMargin: 5
        }
        spacing: 10
        Rectangle {
            Layout.preferredHeight: 60
            Layout.preferredWidth: 60
            radius: 15
            color: "#fefefe"

            ColorImage {
                id: iconSvg
                color: $Colors.green300
                width: 48
                height: 48
                layer.enabled: true
                layer.effect: QGE.DropShadow {
                    radius: 2
                    color: $Colors.green700
                }

                anchors.centerIn: parent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                Layout.fillHeight: true
            }

            Column {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: title
                    font.pixelSize: 19
                    font.weight: Font.Medium
                    clip: true
                }

                Label {
                    text: subtitle
                    font.pixelSize: 14
                    opacity: .6
                    elide: Text.ElideRight
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: $Colors.gray100
        }

        Column {
            visible: !time_inline
            Layout.preferredWidth: 60
            spacing: -5
            Label {
                text: qsTr(hours)
                font.pixelSize: 32
                font.weight: Font.Bold
                font.family: 'Impact'
                color: Theme.colorPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: qsTr(minutes)
                font.pixelSize: 26
                font.weight: Font.Bold
                font.family: 'Impact'
                color: Theme.colorPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Label {
            visible: time_inline
            text: qsTr(hours + ":" + minutes)
            font.pixelSize: 24
            color: Theme.colorPrimary
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: "PointingHandCursor"
        onClicked: root.onClicked()
    }
}
