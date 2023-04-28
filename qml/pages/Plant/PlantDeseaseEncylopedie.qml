import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import ImagePicker
import Qt.labs.platform
import QtAndroidTools
import QtPositioning
import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import MaterialIcons

import "../"
import "../Insect/"
import "../../"
import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    property bool isLoading: true
    header: AppBar {
        title: "Encyclopedie des plantes"
    }

    Item {
        id: itemListAllDeseases
        anchors.fill: parent
        property variant fetched_deseases: []

        Component.onCompleted: {
            Http.fetch({
                           "method": 'GET',
                           "url": "https://blume.mahoudev.com/items/Maladies?fields[]=*.*"
                       }).then(response => {
                                   let data = JSON.parse(response).data
                                   fetched_deseases = data
                                   isLoading = false
                               })
        }

        ListModel {
            id: maladiesModel

            ListElement {
                nom: "Oïdium"
                sousDescription: "Champignon blanc sur les feuilles"
                dangerosite: 0.5
            }
            ListElement {
                nom: "Mildiou"
                sousDescription: "Taches jaunes ou brunes sur les feuilles"
                dangerosite: 0.6
            }
            ListElement {
                nom: "Tavelure"
                sousDescription: "Taches brunes sur les fruits et les feuilles"
                dangerosite: 0.5
            }
            ListElement {
                nom: "Rouille"
                sousDescription: "Pustules orangées sur les feuilles"
                dangerosite: 0.6
            }
            ListElement {
                nom: "Pourriture grise"
                sousDescription: "Moisissure grise sur les fruits"
                dangerosite: 0.7
            }
            ListElement {
                nom: "Anthracnose"
                sousDescription: "Lésions noires sur les feuilles"
                dangerosite: 0.4
            }
            ListElement {
                nom: "Chancre"
                sousDescription: "Lésions sur les branches et troncs"
                dangerosite: 0.7
            }
            ListElement {
                nom: "Fusariose"
                sousDescription: "Pourriture des racines et du collet"
                dangerosite: 0.8
            }
            ListElement {
                nom: "Nécrose"
                sousDescription: "Mort des tissus végétaux"
                dangerosite: 0.6
            }
            ListElement {
                nom: "Verticilliose"
                sousDescription: "Flétrissement et décoloration des feuilles"
                dangerosite: 0.7
            }
            ListElement {
                nom: "Bactériose"
                sousDescription: "Pourriture bactérienne des tissus"
                dangerosite: 0.8
            }
            ListElement {
                nom: "Virose"
                sousDescription: "Infection virale des plantes"
                dangerosite: 0.7
            }
            ListElement {
                nom: "Jaunisse"
                sousDescription: "Décoloration jaune des feuilles"
                dangerosite: 0.5
            }
            ListElement {
                nom: "Sclérotiniose"
                sousDescription: "Pourriture des tiges et des racines"
                dangerosite: 0.6
            }
            ListElement {
                nom: "Phytophthora"
                sousDescription: "Pourriture des racines"
                dangerosite: 0.8
            }
            ListElement {
                nom: "Rhizoctone"
                sousDescription: "Pourriture des racines et du collet"
                dangerosite: 0.7
            }
        }

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 10
            model: itemListAllDeseases.fetched_deseases
            clip: true
            delegate: ItemDelegate {
                required property variant modelData
                required property int index

                height: 100
                width: listView.width
                onClicked: {
                    let formated = {}
                    let desease_details = {
                        "common_names": modelData.noms_communs,
                        "treatment": {
                            "prevention": modelData.traitement_preventif || "",
                            "chemical": modelData.traitement_chimique || "",
                            "biological": modelData.traitement_biologique || ""
                        },
                        "description": modelData.description,
                        "cause": modelData.cause
                    }

                    formated['name'] = modelData.nom_scientifique
                    formated['similar_images'] = modelData.images.map(item => ({
                                                                                   "url": "https://blume.mahoudev.com/assets/" + item.directus_files_id
                                                                               }))
                    formated['disease_details'] = desease_details

                    page_view.push(resultDeseaseDetailPage, {
                                       "desease_data": formated
                                   })
                }

                ClipRRect {
                    id: imgCircle
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    height: 80
                    width: height
                    radius: height / 2
                    Rectangle {
                        color: "#e5e5e5"
                        anchors.fill: parent
                        Image {
                            anchors.fill: parent
                            source: modelData['images'].length
                                    === 0 ? "" : ("https://blume.mahoudev.com/assets/"
                                                  + modelData['images'][0].directus_files_id)
                        }
                    }

                }

                Label {
                    id: titleLabel
                    anchors.top: parent.top
                    anchors.topMargin: 15
                    anchors.left: imgCircle.right
                    anchors.leftMargin: 10
                    font.pixelSize: 21
                    font.weight: Font.Medium
                    width: parent.width - imgCircle.width - 30
                    elide: Text.ElideRight
                    text: modelData['nom_scientifique']
                }

                Label {
                    anchors.top: titleLabel.bottom
                    anchors.left: imgCircle.right
                    anchors.leftMargin: 10
                    font.pixelSize: 12
                    color: "gray"
                    elide: Text.ElideRight
                    width: parent.width - imgCircle.width - 30
                    text: modelData['noms_communs'] ? modelData['noms_communs'][0] : ""
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    height: 1
                    color: "#ccc"
                    width: parent.width - 20
                    opacity: .4
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: index !== maladiesModel.count - 1
                }

            }
        }
    }

    BusyIndicator {
        running: isLoading
        anchors.centerIn: parent
    }
}
