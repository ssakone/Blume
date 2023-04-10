import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
//import PlantUtils 1.0
import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase
import "components"

Popup {
    id: plantScreenDetailsPopup

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    padding: 0

    property variant plant: ({})

    background: Rectangle {}

    ListModel {
        id: modelImagesPlantes
        Component.onCompleted: {
            console.log("----------", plant["images_plantes"], JSON.stringify(plant["images_plantes"]), typeof plant["images_plantes"])
        }
    }

    onOpened: {
        console.log("----------", plant["images_plantes"], JSON.stringify(plant["images_plantes"]), typeof plant["images_plantes"])
    }

    ColumnLayout {
        anchors.fill: parent


        Rectangle {
            id: header
            color: "#00c395"
            height: 65
            width: plantScreenDetailsPopup.width
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    id: buttonBackBg
                    Layout.alignment: Qt.AlignVCenter
                    width: 65
                    height: 65
                    radius: height
                    color: "transparent" //Theme.colorHeaderHighlight
                    opacity: 1
                    IconSvg {
                        id: buttonBack
                        width: 24
                        height: width
                        anchors.centerIn: parent

                        source: "qrc:/assets/menus/menu_back.svg"
                        color: Theme.colorHeaderContent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            plantScreenDetailsPopup.close()
                        }
                    }

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 333
                        }
                    }
                }
                Label {
                    text: "Retour"
                    font.pixelSize: 21
                    font.bold: true
                    font.weight: Font.Medium
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        Flickable {
            y: header.height
            contentHeight: mainContent.height
            contentWidth: plantScreenDetailsPopup.width - 20
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            boundsBehavior: Flickable.StopAtBounds
            clip: true

            ColumnLayout {
                id: mainContent
                width: plantScreenDetailsPopup.width - 20
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 110

                    Layout.leftMargin: 10
                    Layout.rightMargin: 10


                    color: Theme.colorPrimary
                    radius: 15
                    ColumnLayout {
                        id: col_header
                        anchors.fill: parent
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Label {
                            text: plant.name_scientific
                            font.pixelSize: 24
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 15
                            color: Qt.rgba(0, 0, 0, 0) // '#72dae8'
                            Layout.leftMargin: 10
                            RowLayout {
                                Layout.preferredHeight: 40
                                Label {
                                    text: "Nom botanique: "
                                    font.pixelSize: 14
                                    color: "white"
                                }
                                Label {
                                    text: "Caldiusm"
                                    font.pixelSize: 18
                                    font.weight: Font.DemiBold
                                    color: "white"
                                }

                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            Layout.leftMargin: 10
                            radius: 15
                            color: Qt.rgba(0, 0, 0, 0)
                            RowLayout {
                                Layout.preferredHeight: 40
                                Label {
                                    text: "Nom commun: "
                                    font.pixelSize: 14
                                    color: "white"
                                }
                                Label {
                                    text: "Caldiusm"
                                    font.pixelSize: 18
                                    font.weight: Font.DemiBold
                                    color: "white"
                                }

                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    TableLine {
                        title: "Type de plante"
                        description: plant['taill_adulte'] || ""
                    }

                    TableLine {
                        color: "#e4f0ea"
                        title: "Exposition au soleil"
                        description:  plant['exposition_au_soleil'] || ""
                    }

                    TableLine {
                        title: "Type de sol"
                        description: plant['type_de_sol'] || ""
                    }

                    TableLine {
                        color: "#e4f0ea"
                        title: "Couleur"
                        description: plant['couleur'] || ""
                    }

                    TableLine {
                        title: "Période de floraison"
                        description: plant['periode_de_floraison'] || ""
                    }

                    TableLine {
                        color: "#e4f0ea"
                        title: "Zone de rusticité"
                        description: plant['zone_de_rusticite'] || ""
                    }

                    TableLine {
                        title: "PH"
                        description: plant['ph'] || ""
                    }

                    TableLine {
                        color: "#e4f0ea"
                        title: "Toxicité"
                        description: plant['toxicity'] ? 'Plante toxique' : 'Non toxique'
                    }

                }



                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250

                    color: "#edeff2"
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 5

                        Label {
                            text: "Galerie de photos"
                            color: Theme.colorPrimary
                            font.pixelSize: 24
                            Layout.leftMargin: 20
                        }

                        SwipeView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

//                            Repeater {
//                                model: modelImagesPlantes
//                                delegate: Label {
//                                    text: model.directus_files_id
//                                    font.pixelSize: 24
//                                }
//                            }

//                            Image {
//                                source: "qrc:/assets/img/fleure.jpg"
//                            }
//                            Image {
//                                source: "qrc:/assets/img/cactus.jpg"
//                            }

                        }

                    }
                }



                Column {
                    Layout.fillWidth: true

                    spacing: 15


                    Accordion {
                        header: "Présentation des plantes"
                        content: plant['description'] || ""
                    }


                    Accordion {
                        header: "Comment cultiver"
                        content: plant['comment_cultiver'] || ""
                    }

                    Accordion {
                        header: "Luminosité"
                        content: plant['description_luminosite'] || ""
                    }

                    Accordion {
                        header: "Sol"
                        content: plant['description_sol'] || ""
                    }

                    Accordion {
                        header: "Luminosité"
                        content: plant['description_luminosite'] || ""
                    }

                    Accordion {
                        header: "Arrosage"
                        content: plant['description_arrosage'] || ""
                    }

                    Accordion {
                        header: "Température & humidité"
                        content: plant['description_temperature_humidite'] || ""
                    }

                    Accordion {
                        header: "Mise en pot et rampotage"
                        content: plant['description_mise_en_pot_et_rampotage'] || ""
                    }
                    Accordion {
                        header: "Température & humidité"
                        content: plant['description_temperature_humidite'] || ""
                    }
                    Accordion {
                        header: "Multiplication"
                        content: plant['description_multiplication'] || ""
                    }
                    Accordion {
                        header: "Parasites et maladies"
                        content: plant['description_parasites_maladies'] || ""
                    }


                }

            }

        }
    }


}
