import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine 1.0

import "../components_generic"

Column {
    id: root
    property var onClicked: function() {}
    property string title: ""
    property string subtitle

    visible: image.source.toString() === ""
    anchors.fill: parent
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
        text: subtitle || 'Assurez-vous de prendre une photo nette et lumineuse comprenant uniquement la plante que vous souhaitez identifier.'
        horizontalAlignment: Text.horizontalCenter
    }

    ClipRRect {
        width: parent.width - (2 * parent.padding) - 50
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        radius: height / 2

        Rectangle {
            anchors.fill: parent
            color: "#e5e5e5"

            IconSvg {
                width: parent.width / 1.5
                height: width
                anchors.centerIn: parent
                source: Icons.image
                opacity: .5
                color: Theme.colorPrimary
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.onClicked()
        }
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        wrapMode: Label.Wrap
        font.pixelSize: 16
        horizontalAlignment: Label.AlignHCenter
        text: 'Clickez pour importer une image'
        opacity: .6
    }
}
