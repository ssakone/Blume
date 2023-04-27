import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ThemeEngine 1.0

import SortFilterProxyModel

import "../../components"
import "../../components_generic"
//import "../../components_themed"
import "../../components_js/Http.js" as Http

import "../.."

BPage {
    id: plantListView

    property int currentPage: 0
    property int pageLimit: 20

    property bool isLoading: true
    property variant plantsModel: []
    property string previousDisplayText: ""

    header: AppBar {
        title: "Chercher une plante"
        noAutoPop: true
        leading.onClicked: page_view.pop()
    }

    Component.onCompleted: {
        fetchMore()
        plantSearchBox.forceActiveFocus()
    }

    function fetchMore() {
        console.log("Gonna fetch_more...")
        isLoading = true
        let query = `https://blume.mahoudev.com/items/Plantes?fields[]=*.*&limit=${plantSearchBox.displayText !== "" ? 70 : pageLimit}&offset=${currentPage
            * pageLimit}${plantSearchBox.displayText
            === "" ? '' : "&filter[name_scientific][_contains]=" + plantSearchBox.displayText}`

        Http.fetch({
                       "method": 'GET',
                       "url": query
                   }).then(response => {
                               let data = JSON.parse(response).data

                               // Remove null value
                               if (plantSearchBox.displayText !== "") {
                                   plantsModel.clear()
                                }
                               for (var i = 0; i < data.length; i++) {
                                   let item = data[i]
                                   let itemKeys = Object.keys(item)
                                   for(let j=0; j < itemKeys.length; j++){
                                       let key = itemKeys[j]
                                       let value = item[key]
                                       if ( value === null) {
                                           if('categorie' === key) item[key] = {}
                                           else if(['sites', 'light_level', 'noms_communs'].includes(key)) item[key] = []
                                           else item[key] = ""
                                       }
                                   }
                                   plantsModel.append(item)
                               }

                               isLoading = false
                           })
    }


    ListModel {
        id: plantsModel
    }

    PlantScreenDetails {
        id: plantScreenDetailsPopup
    }

    Timer {
        id: searchTimer
        interval: 1500
        repeat: true
        running: plantSearchBox.displayText !== "" && plantListView.previousDisplayText !== plantSearchBox.text
        onTriggered: {
            fetchMore()
            plantListView.previousDisplayText = plantSearchBox.text
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        TextFieldThemed {
            id: plantSearchBox
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.margins: 15

            placeholderText: qsTr("Search for plants")
            selectByMouse: true
            colorSelectedText: "white"

            onAccepted: {
                plantListView.currentPage = 0
                plantListView.fetchMore()
            }
            onTextChanged: {

                plantListView.isLoading = true
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

                    visible: plantSearchBox.text.length
                    highlightMode: "color"
                    source: "qrc:/assets/icons_material/baseline-backspace-24px.svg"

                    onClicked: plantSearchBox.text = ""
                }

                RoundButtonIcon {
                    width: 30
                    height: 30
                    anchors.verticalCenter: parent.verticalCenter

                    visible: plantSearchBox.text.length
                    highlightMode: "color"
                    source: "qrc:/assets/icons_material/baseline-search-24px.svg"

                    onClicked: {
                        plantListView.currentPage = 0
                        plantListView.fetchMore()
                    }
                }
            }
        }

        ListView {
            id: plantList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            clip: true
            model: plantsModel

            ScrollBar.vertical: ScrollBar {
                property bool isLoading: false
                id: searchScrollBar
                onPositionChanged: {
                    if (plantListView.isLoading === false
                            && (searchScrollBar.size + searchScrollBar.position > 0.99)
                            && plantSearchBox.displayText === "") {
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
                            model: modelData.images_plantes
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
                        visible: modelData['images_plantes'].count === 0
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: leftImg.width + 20
                    width: parent.width - leftPadding - 20

                    Text {
                        text: modelData.name_scientific
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
                        plantScreenDetailsPopup.plant = modelData
                        plantScreenDetailsPopup.open()
                    }
                }
            }

            ItemNoPlants {
                visible: plantList.count === 0 && !isLoading
            }
        }
    }

    BusyIndicator {
        running: isLoading
        anchors.centerIn: parent
    }
}
