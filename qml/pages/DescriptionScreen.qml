import QtQuick
import QtQuick.Controls
import "../components"
import "../components_generic"

BPage {

    property string iconSource: icon.source
    property string text: titleItem.text
    property string description: descriptionItem.text

    header: AppBar {
        title: ""
    }

    Column {
        width: parent.width - 40
        leftPadding: 20
        rightPadding: 20
        anchors.verticalCenter: parent.verticalCenter

        Container {
            width: parent.width
            background: Rectangle {
                color: $Colors.colorSecondary
                radius: 15
            }

            contentItem: Column {
                width: parent.width
                spacing: 10
                padding: 10
            }

            Row {
                spacing: 10
                IconSvg {
                    id: icon
                    source: Icons.close
                    color: $Colors.red
                    MouseArea {
                        anchors.fill: parent
                        onClicked: page_view.pop()
                    }
                }
                Label {
                    id: titleItem
                    text: "Super"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }
            }

            Label {
                id: descriptionItem
                text: "Descirption"
                font.pixelSize: 14
                font.weight: Font.Light
            }
        }
    }


}
