import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtSensors
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import "../"
import "../../"
import "../../components" as Components
import "../../components_generic"
import "../../components_js/Http.js" as Http

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

BPage {
    id: plantBrowser
    objectName: "Plants"

    backgroundColor: $Colors.colorTertiary
    header: Item {}

    property string entryPoint: "DeviceList"

    ////////////////////////////////////////////////////////////////////////////
    Rectangle {
        anchors {
            bottom: parent.top
            bottomMargin: -260
            horizontalCenter: parent.horizontalCenter
        }

        height: 1200
        width: height / 1.5
        radius: height

        color: $Colors.primary
    }


    ListModel {
        id: plantOptionModel

        Component.onCompleted: {
            let data = [{
                            "name": qsTr("Suggested plants"),
                            "icon": "qrc:/assets/icons_custom/thumbs.png",
                            "image": "",
                            "action": "",
                            "bg": $Colors.colorPrimary
                        }, {
                            "name": qsTr("Identify plant"),
                            "icon": "qrc:/assets/icons_custom/scan_plant.svg",
                            "image": "",
                            "action": "identify",
                            "bg": $Colors.colorSecondary
                        }, {
                            "name": qsTr("Light sensor"),
                            "icon": Components.Icons.thermometer,
                            "image": "",
                            "action": "posometre",
                            "bg": $Colors.colorPrimary
                        }]
            data.forEach((plant => append(plant)))
        }
    }

    Flickable {
        id: optionsFlickable
        anchors.fill: parent
        contentHeight: _insideColumn.height
        clip: true
        Column {
            id: _insideColumn
            width: parent.width
            spacing: 20
            topPadding: 30

            Column {
                width: parent.width - 30
                leftPadding: 15
                rightPadding: 15
                spacing: 30

                RowLayout {
                    width: parent.width
                    height: 30
                    anchors.topMargin: 5

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 15
                        color: $Colors.white

                        IconSvg {
                            width: parent.width - 4
                            height: width
                            anchors.centerIn: parent
                            source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                            color: $Colors.colorPrimary
                            MouseArea {
                                anchors.fill: parent
                                onClicked: appDrawer.open()
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        Label {
                            text: qsTr("Plants menu")
                            font {
                                pixelSize: 36
                                family: "Courrier"
                                weight: Font.Bold
                            }
                            color: $Colors.white
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: qsTr("Gérez les plantes de manière efficace")
                            opacity: .5
                            color: $Colors.white
                            font {
                                pixelSize: 14
                                family: "Courrier"
                                weight: Font.Bold
                            }
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 15
                        color: $Colors.white

                        IconSvg {
                            width: parent.width - 4
                            height: width
                            anchors.centerIn: parent
                            source: Components.Icons.bell
                            color: $Colors.colorPrimary
                            MouseArea {
                                anchors.fill: parent
                                onClicked: page_view.push(
                                               navigator.loginPage)
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 60
                    MouseArea {
                        id: plantSearchBoxMS
                        anchors.fill: parent
                        anchors.rightMargin: 70
                        onClicked: {
                            page_view.push(navigator.plantSearchPage)
                        }
                    }
                    RowLayout {
                        anchors.top: parent.top
                        anchors.topMargin: 14
                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.right: parent.right
                        anchors.rightMargin: 25
                        spacing: 15

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            id: plantSearchBox
                            color: "#BBFEEA"
                            radius: height / 2
                            Text {
                                text: qsTr("Search for plants")
                                color: $Colors.gray600
                                leftPadding: 15
                                font.pixelSize: 14
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 25
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            color: $Colors.white
                            radius: 25

                            IconSvg {
                                anchors.centerIn: parent
                                source: Components.Icons.camera
                                color: $Colors.colorPrimary
                            }
                        }
                    }
                }

                RowLayout {
                    height: 120
//                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    width: parent.width
                    Item {
                        Layout.fillWidth: true
                    }

                    Repeater {
                        model: plantOptionModel
                        delegate: Components.ItemMenuLine {
                            required property int index
                            required property var model
                            property var modelData: plantOptionModel.get(index)

                                width: index === 1 ? 120 : 90
                                height: width + 20
                                title: modelData.name
                                iconSource: modelData.icon
                                onClicked: {

                                    console.log("CLick")
                                    if (modelData.action === "posometre") {
                                        page_view.push(
                                                    navigator.posometrePage)
                                    } else if (modelData.action === "identify") {
                                        page_view.push(
                                                    navigator.plantIdentifierPage)
                                    }
                                }
                            }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                }
            }

            Column {
                width: parent.width
                leftPadding: 10
                topPadding: 20
                spacing: 7
                Label {
                    text: qsTr("Mes favoris")
                    color: $Colors.colorPrimary
                    font {
                        pixelSize: 16
                        weight: Font.Bold
                    }
                }

                Flickable {
                    height: 140
                    width: parent.width
                    contentWidth: _insideRow.width
                    clip: true
                    anchors.topMargin: 20

                    Row {
                        id: _insideRow
                        spacing: 10

                        BusyIndicator {
                            running: favorisRepeater.model?.length === 0
                            visible: running
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Repeater {
                            id: favorisRepeater
                            Component.onCompleted: {
                                const url = `https://blume.mahoudev.com/items/Plantes?offset=${Math.ceil(
                                              Math.random(
                                                  ) * 1000)}&limit=5&fields=*.*`

                                Http.fetch({
                                               "method": "GET",
                                               "url": url,
                                               "headers": {
                                                   "Accept": 'application/json',
                                                   "Content-Type": 'application/json'
                                               }
                                           }).then(function (response) {
                                               //                                                    console.log("Got favoris ", response)
                                               const parsedResponse = JSON.parse(
                                                                        response)
                                                                    ?? []
                                               console.log("Favoris ",
                                                           parsedResponse?.data?.length)
                                               favorisRepeater.model = parsedResponse.data
                                                       ?? parsedResponse
                                           })
                            }

                            model: []
                            delegate: Components.GardenPlantLineWide {
                                required property variant modelData
                                property var plant: modelData
                                width: 300
                                height: 140
                                title: plant.name_scientific
                                subtitle: plant.noms_communs[0]?.name ?? ""
                                moreDetailsList: [{
                                        "iconSource": plant.toxicity
                                                      === null ? "" : Components.Icons.water,
                                        "text": plant.toxicity === null ? "" : plant.toxicity === true ? "Toxique" : "Non toxique"
                                    }, {
                                        "iconSource": Components.Icons.food,
                                        "text": plant.commestible ? "Commestible" : "Non commestible"
                                    }]
                                roomName: ""
                                imageSource: plant.images_plantes.length > 0 ? "https://blume.mahoudev.com/assets/" + plant.images_plantes[0].directus_files_id : ""
                                onClicked: $Signaler.showPlant(plant)
                            }
                        }
                    }
                }

            }

            Column {
                width: parent.width
                leftPadding: 10
                rightPadding: 10
                topPadding: 20
                spacing: 7
                Label {
                    text: qsTr("Some plants")
                    color: $Colors.colorPrimary
                    font {
                        pixelSize: 16
                        weight: Font.Bold
                    }
                }

                Components.SearchPlants {
                    width: parent.width - 20
                    height: plantBrowser.height
                    hideSearchBar: true
                }
            }
        }
    }


}
