import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qaterial as Qaterial

Rectangle {
    id: control
    height: 34

    anchors.left: parent.left
    anchors.leftMargin: 5
    anchors.right: parent.right
    anchors.rightMargin: 5

    radius: 0
    color: "transparent"

    // actions
    signal clicked()
    signal pressAndHold()

    // settings
    property int index
    property string text
    property url source
    property int sourceSize: 20
    property int layoutDirection: Qt.RightToLeft

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: (isDesktop && enabled)

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onEntered: control.state = "hovered"
        onExited: control.state = "normal"
        onCanceled: control.state = "normal"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        spacing: 6
        layoutDirection: control.layoutDirection

        IconImage {
            id: iButton
            width: control.sourceSize
            height: control.sourceSize
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize

            source: control.source
            color: Qaterial.Colors.gray600
        }

        Text {
            id: tButton

            Layout.fillWidth: true

            text: control.text
            font.bold: false
            font.pixelSize: 13
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: Qaterial.Colors.gray600
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    states: [
        State {
            name: "normal";
            PropertyChanges { target: control; color: "transparent"; }
        },
        State {
            name: "hovered";
            PropertyChanges { target: control; color: Qaterial.Colors.gray100; }
        }
    ]

    ////////////////////////////////////////////////////////////////////////////
}
