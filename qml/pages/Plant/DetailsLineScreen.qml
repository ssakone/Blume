import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../components"
import "../../components_generic"

BPage {
    header: AppBar {
        title: ""
        leading.icon: Icons.close
        color: Qt.rgba(12, 200, 25, 0)
        foregroundColor: $Colors.colorPrimary
    }

    property string iconSource: _icon.source
    property string  titleText: _title.text
    property string  description: _descriptionItem.text

    Container {
        width: parent.width - 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        background: Rectangle {
            color: $Colors.colorTertiary
            radius: 25
        }

        contentItem: Column {
            width: parent.width - 30
        }

        Row {
            IconSvg {
                id: _icon
            }
            Label {
                id: _title
                color: "black"
            }
        }

        Label {
            id: _descriptionItem
            width: parent.width
            wrapMode: Text.Wrap
            color: "black"
        }
    }
}
