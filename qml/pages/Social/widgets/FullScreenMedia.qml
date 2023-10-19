import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtMultimedia
import Qaterial as Qaterial

import "../components_generic/"
import "../components_themed/"

Popup {
    id: control

    signal swithMode

    function displayImage(source) {
        vid.source = ""
        img.source = source
        console.log("DISPLAY IMG ", source)
        open()
    }


    function displayVideo(type, source) {
        img.source = source
        vid.source = source
        vid.play()
        open()
    }


    parent: root
    width: root.width
    height: root.height

    padding: 0
    background: Rectangle {
        color: "black"
    }

    onClosed: {
        vid.source = ""
    }

    Item {
        anchors.fill: parent
        BusyIndicator {
            anchors.centerIn: parent

        }

        Image {
            id: img
            anchors.fill: parent
            clip: true
            fillMode: Image.PreserveAspectFit
        }

        MediaPlayer {
            id: vid
            videoOutput: videoOutput
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: header.visible = !header.visible //swithMode()
        }
    }

    RowLayout {
        id: header
        width: parent.width
        anchors {
            top: parent.top
            topMargin: Qt.platform.os === "ios" ? 30 : 0
        }

        IconImage {
            Layout.preferredHeight: 60
            Layout.preferredWidth: height
            source: Qaterial.Icons.close
            color: Qaterial.Colors.green500

            MouseArea {
                anchors.fill: parent
                onClicked: control.close()
            }
        }
    }
}
