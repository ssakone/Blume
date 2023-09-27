import QtQuick
import QtQuick.Controls
import "../components_generic"

Item {
    id: control
    signal clicked
    property int index: 1
    property string iconSource: ""
    property string title: ""


    anchors.rightMargin: index === 1 ? 20 : 10
    anchors.leftMargin: index === 1 ? 20 : 10
    Column {
        width: parent.width
        Rectangle {
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
                width: index === 1 ? 64 : 50
                height: width
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
            font.pixelSize: index === 1 ? 12 : 10
            font.weight: Font.Medium
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            text: title
        }
    }

}
