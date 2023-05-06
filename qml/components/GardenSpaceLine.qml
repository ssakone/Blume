import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine

import Qt5Compat.GraphicalEffects as QGE

import "../components_generic"

ItemDelegate {
    id: root
    property string title: ""
    property string subtitle: ""
    property string iconSource: ""

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
            topMargin: 2
            bottomMargin: 2
        }
        spacing: 10

        Rectangle {
            Layout.preferredHeight: 75
            Layout.preferredWidth: 75
            Layout.alignment: Qt.AlignCenter
            Rectangle {
                id: gradi
                visible: false
                width: 85
                height: 85
                radius: 18
                anchors.centerIn: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.00
                        color: Theme.colorPrimary
                    }
                    GradientStop {
                        position: 1.00
                        color: Qt.darker(Theme.colorPrimary)
                    }
                }
            }
            IconSvg {
                id: mask
                anchors.fill: parent
                anchors.margins: 15
                source: iconSource
                opacity: 1
                visible: false
                color: "black"
            }

            QGE.OpacityMask {
                anchors.fill: gradi
                anchors.margins: 10
                opacity: .6
                source: gradi
                maskSource: mask
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            Label {
                text: title
                font.pixelSize: 18
                font.family: 'Roboto'
                font.weight: Font.Medium
            }
            Label {
                text: subtitle
                font.pixelSize: 12
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                opacity: .7
            }
            Label {
                text: ""
                color: "white"
                padding: 5
                visible: false
                font.capitalization: Font.AllUppercase
                background: Rectangle {
                    color: Theme.colorPrimary
                    radius: 5
                }
            }
        }
    }
}
