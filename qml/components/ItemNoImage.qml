import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../components_generic"

import "../components_generic/"
import "../components_themed/"

Column {
    id: root
    property var onClicked: function () {}
    property string title: ""
    property string subtitle

    visible: image.source.toString() === ""
    spacing: 10
    padding: 25

    Label {
        width: parent.width - (2 * parent.padding)
        wrapMode: Label.Wrap
        font.pixelSize: 24
        font.weight: Font.Bold
        text: title
        horizontalAlignment: Text.horizontalCenter
    }

    Label {
        width: parent.width - (2 * parent.padding)
        wrapMode: Label.Wrap
        font.pixelSize: 14
        text: qsTr(subtitle)
        opacity: .6
        horizontalAlignment: Text.horizontalCenter
    }

    ClipRRect {
        width: Math.min(parent.width, parent.height) - (2 * parent.padding) - 20
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 10

        Rectangle {
            anchors.fill: parent
            color: "#E7F9F1"

            IconSvg {
                width: parent.width / 1.5
                height: width
                anchors.centerIn: parent
                source: "qrc:/assets/icons_custom/pictures-group.svg"
                color: $Colors.colorPrimary
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.onClicked()
        }
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - (2 * parent.padding)
        wrapMode: Label.Wrap
        font.pixelSize: 16
        horizontalAlignment: Label.AlignHCenter
        text: qsTr("Click to load image")
        opacity: .6
    }
}
