import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import ImagePicker
import Qt.labs.platform

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import MaterialIcons

Rectangle {
    id: buttonBackBg
    property color foregroundColor: Theme.colorHeaderContent
    width: 65
    height: 65
    radius: height
    color: "transparent" //Theme.colorHeaderHighlight
    opacity: 1
    property string icon
    property int iconSize: buttonBack.width
    signal clicked
    IconImage {
        id: buttonBack
        width: 24
        height: width
        anchors.centerIn: parent

        source: buttonBackBg.icon
        color: parent.foregroundColor
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            buttonBackBg.clicked()
        }
    }

    Behavior on opacity {
        OpacityAnimator {
            duration: 333
        }
    }
}
