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

        onClicked: page_view.push(navigator.gardenEditSpace)

        Text {
            text: "+"
            color: "white"
            font.pixelSize: 32
            anchors.centerIn: parent
        }


        Behavior on scale {
            NumberAnimation {
                duration: 50
                easing.type: Easing.InOutCubic
            }
        }

        Timer {
            id: animationTimer
            property double min: 1.0
            property double max: 1.15
            property bool up: true
            interval: 50
            repeat: true
            running: $Model.space.count === 0
            onTriggered: {
                if(up) {
                    if(parent.scale <= max) {
                        parent.scale += 0.01
                    } else {
                        up = false
                    }
                } else {
                    if(parent.scale >= min) {
                        parent.scale -= 0.01
                    } else {
                        up = true
                    }
                }

            }
        }

    }

}
