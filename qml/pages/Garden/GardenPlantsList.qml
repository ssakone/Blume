import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import SortFilterProxyModel
import Qt5Compat.GraphicalEffects as QGE

import "../../components"
import "../../components_generic"
import '../../components_js/'

BPage {
    id: control
    header: AppBar {
        title: qsTr("My plants")
    }

    // Wizard
    ListView {
        visible: $Model.space.plantInSpace.count === 0
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10


        model: 3
        delegate: GardenPlantLine {
            layer.enabled: true
            layer.effect: QGE.ColorOverlay {
                color: Qt.rgba(100, 30, 89, 0.8)
            }
            width: parent.width
            height: 100
            title: qsTr("Abelia chinensis")
            subtitle: qsTr("Chinensis")
            roomName: ""
            imageSource: ""
        }

        Column {
            width: parent.width
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 50
            spacing: 10

            Label {
                text: qsTr("No plant ! \n\n You should first create a room and associate plants")
                color: Theme.colorSecondary
                opacity: 0.8
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font {
                    weight: Font.Bold
                    pixelSize: 18
                }
            }

            ButtonWireframe {
                text: "Go"
                fullColor: true
                fulltextColor: $Colors.white
                anchors.horizontalCenter: parent.horizontalCenter
                componentRadius: 10
                width: parent.width
                onClicked: page_view.push(navigator.gardenSpacesList)
            }


        }

    }

    // Real listview
    ListView {
        id: plantListView
        visible: $Model.space.plantInSpace.count !== 0
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        model: $Model.space.plantInSpace
        delegate: GardenPlantLine {
            property var plant: JSON.parse(plant_json)
            width: parent.width
            height: 100
            title: plant.name_scientific
            subtitle: plant.noms_communs[0]?.name ?? ""
            roomName: {
                console.log("\n\n created_attt ", created_at, "\n\n")
                return "Ajoutée le " + (new Date(created_at)).toLocaleDateString()
            }
            imageSource: plant.images_plantes.length
                         > 0 ? "https://blume.mahoudev.com/assets/"
                               + plant.images_plantes[0].directus_files_id : ""
            onClicked: $Signaler.showPlant(plant)
        }
    }

    ButtonWireframe {
        height: 60
        width: 60
        fullColor: Theme.colorPrimary
        componentRadius: 30
        visible: false
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
        onClicked: $Model.plantSelect.show(function (plant) {
            console.log(plant)
        })
    }
}
