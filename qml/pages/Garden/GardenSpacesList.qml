import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../../components"
import "../../components_generic"

BPage {
    id: control
    header: AppBar {
        title: qsTr("Rooms")
    }

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        clip: true
        model: $Model.space
        spacing: 10
        delegate: GardenSpaceLine {
            width: control.width
            height: 85
            title: (libelle[0] === "'" ? libelle.slice(1, -1) : libelle)
            subtitle: description[0] === "'" ? description.slice(1, -1) : description
            iconSource: type === 1 ? Icons.homeOutline : Icons.landFields
            onClicked: {
                let data = {
                    "name": libelle,
                    "type": type,
                    "description": description,
                    "status": model.status ?? 0,
                    "space_id": id
                }
                page_view.push(navigator.gardenSpaceDetails, data)
            }
        }
    }

    ButtonWireframe {
        height: 60
        width: 60
        fullColor: Theme.colorPrimary
        componentRadius: 30
        anchors {
            bottom: parent.bottom
            bottomMargin: 30

            right: parent.right
            rightMargin: 20
        }

        Text {
            text: "+"
            color: "white"
            font.pixelSize: 32
            anchors.centerIn: parent
        }

        onClicked: page_view.push(navigator.gardenEditSpace)
    }
}
