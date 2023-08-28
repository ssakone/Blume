import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine

import Qt5Compat.GraphicalEffects as QGE

import "../components_generic"

ClipRRect {
    id: root
    property string title: ""
    property string subtitle: ""
    property string iconSource: ""
    property bool isOutdoor: false

    signal clicked

    radius: 15

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: parent.radius

        color: $Colors.colorTertiary

        border {
            color: $Colors.gray50
            width: 1
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
            topMargin: 2
            bottomMargin: 2
        }
        spacing: 10

        IconSvg {
            id: mask
            source: iconSource
            color: $Colors.colorPrimary
            Layout.margins: 15
            Layout.preferredHeight: 35
            Layout.preferredWidth: 35
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            Label {
                text: title
                font.pixelSize: 18
            }
            Label {
                text: subtitle
                font.pixelSize: 12
                Layout.fillWidth: true
                elide: Text.ElideRight
                opacity: .7
                visible: subtitle !== ""
            }
            Label {
                text: isOutdoor ? qsTr("Outdoor") : qsTr("Indoor")
                color: $Colors.white
                padding: 3
                font {
                    capitalization: Font.AllUppercase
                    pixelSize: 11
                }

                background: Rectangle {
                    color: $Colors.colorPrimary
                    radius: 5
                }
                leftPadding: 7
                rightPadding: 7
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
