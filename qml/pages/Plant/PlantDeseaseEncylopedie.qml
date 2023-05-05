import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ThemeEngine 1.0

import SortFilterProxyModel

import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

import "../.."

BPage {
    id: diseaseListView

    property int currentPage: 0
    property int pageLimit: 20

    property bool isLoading: true
    property string previousDisplayText: ""

    header: AppBar {
        title: "Liste des maladies"
        noAutoPop: true
        leading.onClicked: page_view.pop()
    }

    Component.onCompleted: {
        fetchMore()
        diseaseSearchBox.forceActiveFocus()
    }

    function fetchMore() {
        console.log("Gonna fetch_more...")
        isLoading = true
        let query = `https://blume.mahoudev.com/items/Maladies?fields[]=*.*&limit=${diseaseSearchBox.displayText !== "" ? 70 : pageLimit}&offset=${currentPage
            * pageLimit}${diseaseSearchBox.displayText
            === "" ? '' : "&filter[nom_scientifique][_contains]=" + diseaseSearchBox.displayText}`

        Http.fetch({
                       "method": 'GET',
                       "url": query
                   }).then(response => {
                               let data = JSON.parse(response).data

                               // Remove null value
                               if (diseaseSearchBox.displayText !== "") {
                                   diseasesModel.clear()
                                }
                               for (var i = 0; i < data.length; i++) {
                                   let item = data[i]
                                   let itemKeys = Object.keys(item)
                                   for(let j=0; j < itemKeys.length; j++){
                                       let key = itemKeys[j]
                                       let value = item[key]
                                       if ( value === null) {
                                           if('noms_communs' === key) item[key] = []
                                           else item[key] = ""
                                       }
                                   }
                                   diseasesModel.append(item)
                               }

                               isLoading = false
                           })
    }


    ListModel {
        id: diseasesModel
    }

    Timer {
        id: searchTimer
        interval: 1500
        repeat: true
        running: diseaseSearchBox.displayText !== "" && diseaseListView.previousDisplayText !== diseaseSearchBox.text
        onTriggered: {
            fetchMore()
            diseaseListView.previousDisplayText = diseaseSearchBox.text
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Layout.margins: 15

            TextFieldThemed {
                id: diseaseSearchBox
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                selectByMouse: true
                colorSelectedText: "white"

                onAccepted: {
                    diseaseListView.currentPage = 0
                    diseaseListView.fetchMore()
                }
                onTextChanged: {

                    diseaseListView.isLoading = true
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: 70
                    onClicked: {
                        parent.forceActiveFocus()
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    RoundButtonIcon {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        visible: diseaseSearchBox.text.length
                        highlightMode: "color"
                        source: "qrc:/assets/icons_material/baseline-backspace-24px.svg"

                        onClicked: diseaseSearchBox.text = ""
                    }

                    RoundButtonIcon {
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter

                        visible: diseaseSearchBox.text.length
                        highlightMode: "color"
                        source: "qrc:/assets/icons_material/baseline-search-24px.svg"

                        onClicked: {
                            diseaseListView.currentPage = 0
                            diseaseListView.fetchMore()
                        }
                    }
                }
            }

        }


        ListView {
            id: diseaseList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            clip: true
            model: diseasesModel

            ScrollBar.vertical: ScrollBar {
                property bool isLoading: false
                id: searchScrollBar
                onPositionChanged: {
                    if (diseaseListView.isLoading === false
                            && (searchScrollBar.size + searchScrollBar.position > 0.99)
                            && diseaseSearchBox.displayText === "") {
                        currentPage++
                        fetchMore()
                    }
                }
            }

            delegate: ItemDelegate {
                required property variant model
                required property int index

                property variant modelData: model

                width: ListView.view.width
                height: 100

                background: Rectangle {
                    color: (index % 2) ? "white" : "#f0f0f0"
                }

                ClipRRect {
                    id: leftImg
                    height: 80
                    width: height
                    radius: width / 2
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    SwipeView {
                        anchors.fill: parent

                        Repeater {
                            model: modelData.images
                            delegate: Image {
                                required property variant model
                                source: "https://blume.mahoudev.com/assets/"
                                        + model['directus_files_id']
                            }
                        }
                    }
                    Rectangle {
                        color: "#e5e5e5"
                        anchors.fill: parent
                        visible: modelData['images'].count === 0
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: leftImg.width + 20
                    width: parent.width - leftPadding - 20

                    Text {
                        text: modelData.nom_scientifique
                        color: Theme.colorText
                        fontSizeMode: Text.Fit
                        font.pixelSize: 18
                        width: parent.width - 10
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"

                    onClicked: {
                        let formated = {}

                        let desease_details = {
                            "common_names": [],
                            "treatment": {
                                "prevention": modelData.traitement_preventif || "",
                                "chemical": modelData.traitement_chimique || "",
                                "biological": modelData.traitement_biologique || ""
                            },
                            "description": modelData.description,
                            "cause": modelData.cause
                        }

                        formated['name'] = modelData.nom_scientifique
                        formated['similar_images'] = []

//                        for(let i=0; i<modelData.noms_communs.count; i++ ) {
//                            desease_details["common_names"].push(modelData.noms_communs.get(i))
//                        }

                        for(let j=0; j<modelData.images.count; j++ ) {
                            formated['similar_images'].push({"url": "https://blume.mahoudev.com/assets/" + modelData.images.get(j).directus_files_id})
                        }

                        formated['disease_details'] = desease_details

                        page_view.push(resultDeseaseDetailPage, {
                                           "desease_data": formated
                                       })
                    }
                }
            }

            ItemNoPlants {
                visible: diseaseList.count === 0 && !isLoading
            }
        }
    }

    BusyIndicator {
        running: isLoading
        anchors.centerIn: parent
    }
}
