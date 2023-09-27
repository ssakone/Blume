import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

import "../components_generic/"
import "../components_themed/"

Item {
    id: control
    signal clicked

    height: 48
    anchors.left: parent.left
    anchors.right: parent.right

    property alias text: _text.text
    property alias iconSource: _iconSvg.source
    property alias iconColor: _iconSvg.color
    property alias color: _text.color

    MouseArea {
        anchors.fill: parent

        onClicked: control.clicked()

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            radius: Theme.componentRadius
            color: Theme.colorForeground
            opacity: parent.containsPress
            Behavior on opacity {
                OpacityAnimator {
                    duration: 133
                }
            }
        }
    }

    IconSvg {
        id: _iconSvg
        width: 24
        height: 24
        anchors.left: parent.left
        anchors.leftMargin: screenPaddingLeft + 16
        anchors.verticalCenter: parent.verticalCenter

        color: _text.color

        SequentialAnimation on opacity {
            // scanAnimation (fade)
            loops: Animation.Infinite
            running: deviceManager.scanning
            alwaysRunToEnd: true

            PropertyAnimation {
                to: 0.33
                duration: 750
            }
            PropertyAnimation {
                to: 1
                duration: 750
            }
        }
    }
    Text {
        id: _text
        anchors.left: parent.left
        anchors.leftMargin: screenPaddingLeft + 56
        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: 13
        font.bold: true
        color: control.enabled ? Theme.colorText : Theme.colorSubText
    }
}
