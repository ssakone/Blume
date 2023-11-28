import QtQuick
import QtQuick.Controls
import "../components_generic"

Item {
    id: control
    signal clicked
    property int index: 1
    property string iconSource: ""
    property int iconSize: 50
    property alias icon: _icon
    property string title: ""
    property alias background: _bg
    property alias labelItem: bottomOptionTextItem

    Column {
        width: parent.width
        Rectangle {
            id: _bg
            width: parent.width
            height: width
            radius: 15
            opacity: mArea.containsMouse ? .8 : 1
            color: $Colors.colorSecondary
            border {
                width: 1
                color: $Colors.green200
            }

            IconSvg {
                id: _icon
                height: iconSize
                width: height
                visible: iconSource !== ""
                anchors.centerIn: parent

                source: iconSource
                color: 'white'
            }

            MouseArea {
                id: mArea
                anchors.fill: parent
                hoverEnabled: enabled
                onClicked: control.clicked()
            }
        }
        Label {
            id: bottomOptionTextItem
            width: parent.width
            height: 28
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Label.Wrap
            font.weight: Font.Medium
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            text: title
        }
    }

}
