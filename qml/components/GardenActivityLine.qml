import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects as QGE

import ThemeEngine
import "../components_generic"

Rectangle {
    id: control

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
                padding: 2
                Layout.fillWidth: true
                spacing: 1
                Label {
                    text: title
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    width: parent.width
                    height: 35
                    elide: Label.ElideRight
                    wrapMode: Label.Wrap
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
            Layout.preferredWidth: 80
            Layout.minimumWidth: 80
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
            Layout.minimumWidth: 80
            visible: time_inline
            text: qsTr(hours + " : " + minutes)
            font.pixelSize: 24
            font.weight: Font.Medium
            color: Theme.colorPrimary
            horizontalAlignment: Label.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: "PointingHandCursor"
        onClicked: control.clicked()
    }
}
