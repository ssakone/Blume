import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Layouts 1.15

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "../components_js/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12 + (control.source.toString().length && control.text ? 2 : 0)
    spacing: 6

    font.pixelSize: Theme.fontSizeComponent
    font.bold: fullColor ? true : false

    focusPolicy: Qt.NoFocus

    // settings
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)
    property int layoutDirection: Qt.LeftToRight

    // colors
    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: $Colors.colorPrimary
    property string secondaryColor: Theme.colorComponentBackground
    property int backgroundBorderWidth: Theme.componentBorderWidth
    // animation
    property bool hoverAnimation: isDesktop

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mousearea
        anchors.fill: parent
        enabled: control.hoverAnimation

        hoverEnabled: control.hoverAnimation

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: {
            control.down = true
            mouseBackground.width = (control.width * 2)
        }
        onReleased: {
            control.down = false
            //mouseBackground.width = 0 // let the click expand the ripple
        }

        onEntered: {
            mouseBackground.width = 72
        }
        onExited: {
            control.down = false
            mouseBackground.width = 0
        }
        onCanceled: {
            control.down = false
            mouseBackground.width = 0
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: enabled ? (control.down && !control.hoverAnimation ? 0.8 : 1.0) : 0.4
        color: control.fullColor ? control.primaryColor : control.secondaryColor

        border.width: control.backgroundBorderWidth
        border.color: control.fullColor ? control.primaryColor : Theme.colorComponentBorder
        Rectangle { // mouseBackground
            id: mouseBackground
            width: 0; height: width; radius: width;
            x: mousearea.mouseX - (width / 2)
            y: mousearea.mouseY - (width / 2)

            visible: control.hoverAnimation
            color: "white"
            opacity: mousearea.containsMouse ? 0.16 : 0
            Behavior on opacity { NumberAnimation { duration: 333 } }
            Behavior on width { NumberAnimation { duration: 200 } }
        }

        layer.enabled: control.hoverAnimation
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: background.x
                y: background.y
                width: background.width
                height: background.height
                radius: background.radius
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: RowLayout {
        spacing: control.spacing
        layoutDirection: control.layoutDirection

        IconSvg {
            source: control.source
            width: control.sourceSize
            height: control.sourceSize

            visible: control.source.toString().length
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize
            Layout.alignment: Qt.AlignVCenter

            opacity: enabled ? 1.0 : 0.66
            color: control.fullColor ? control.fulltextColor : control.primaryColor
        }
        Text {
            text: control.text
            textFormat: Text.PlainText

            visible: control.text
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            font: control.font
            elide: Text.ElideMiddle
            //wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            opacity: enabled ? (control.down && !control.hoverAnimation ? 0.8 : 1.0) : 0.66
            color: control.fullColor ? control.fulltextColor : control.primaryColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
