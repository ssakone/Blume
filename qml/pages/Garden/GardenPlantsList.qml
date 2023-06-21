import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import SortFilterProxyModel

import "../../components"
import "../../components_generic"
import '../../components_js/'

BPage {
    id: control
    header: AppBar {
        title: qsTr("My plants")
    }

    ListView {
        id: plantListView
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
            roomName: ""
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
