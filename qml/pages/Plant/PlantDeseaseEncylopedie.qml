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
import "../../components_js/Http.js" as Http

Page {
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

                height: 70
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

                Rectangle {
                    anchors.bottom: parent.bottom
                    height: 1
                    color: "#ccc"
                    width: parent.width - 20
                    opacity: .4
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: index !== maladiesModel.count - 1
                }

                Label {
                    id: titleLabel
                    anchors.top: parent.top
                    anchors.topMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.pixelSize: 21
                    font.weight: Font.Medium
                    width: parent.width - 20
                    wrapMode: Label.Wrap
                    text: modelData['nom_scientifique']
                }

                Label {
                    anchors.top: titleLabel.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.pixelSize: 12
                    color: "gray"
                    width: parent.width - 20
                    wrapMode: Label.Wrap
                    text: modelData['noms_communs'] ? modelData['noms_communs'][0] : ""
                }

                ClipRRect {
                    id: dangerositeCercle
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    height: 50
                    width: 50
                    radius: 25
                    Image {
                        source: modelData['images'].length
                                === 0 ? "" : ("https://blume.mahoudev.com/assets/"
                                              + modelData['images'][0].directus_files_id)
                    }
                }
            }
        }
    }
}
