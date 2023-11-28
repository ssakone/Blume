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

        color: $Colors.colorSecondary
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: imageSource
        asynchronous: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
