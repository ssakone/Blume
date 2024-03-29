import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ThemeEngine 1.0

import SortFilterProxyModel

import "../../components"
import "../../components_generic"
import "../../components_themed/"
import "../../components_js/Http.js" as Http

import "../.."

BPage {
    id: diseaseListView

    property int currentPage: 0
    property int pageLimit: 20

    property bool isLoading: true
    property string previousDisplayText: ""
    property bool autoFocusSearchbar: false
    property bool hideSearchBar: false

    header: AppBar {
        title: qsTr("Search for diseases")
        noAutoPop: true
        leading.onClicked: page_view.pop()
    }

    Component.onCompleted: {
        fetchMore()
        if (autoFocusSearchbar) {
            diseaseSearchBox.forceActiveFocus()
        }
    }

    function fetchMore() {
        console.log("Gonna fetch_more...")
        let appLang = "en"
        for (var i = 0; i < $Constants.cbAppLanguage.count; i++) {
            if ($Constants.cbAppLanguage.get(
                        i).code === settingsManager.appLanguage)
                appLang = $Constants.cbAppLanguage.get(i).code
        }
        isLoading = true
        let query = `https://public.blume.mahoudev.com/diseases?fields[]=*.*&limit=${diseaseSearchBox.displayText
            !== "" ? 70 : pageLimit}&offset=${currentPage * pageLimit}${diseaseSearchBox.displayText
                     === "" ? '' : "&filter[nom_scientifique][_contains]="
                              + diseaseSearchBox.displayText}`

        Http.fetch({
                       "method": 'GET',
                       "url": query,
                       "headers": {
                           "Content-Lang": appLang
                       }
                   }).then(response => {
                               let data = JSON.parse(response).data

                               // Remove null value
                               if (diseaseSearchBox.displayText !== "") {
                                   diseasesModel.clear()
                               }
                               for (var i = 0; i < data.length; i++) {
                                   let item = data[i]
                                   let itemKeys = Object.keys(item)
                                   for (var j = 0; j < itemKeys.length; j++) {
                                       let key = itemKeys[j]
                                       let value = item[key]
                                       if (value === null) {
                                           if ('noms_communs' === key)
                                           item[key] = []
                                           else
                                           item[key] = ""
                                       } else if ('noms_communs' === key)
                                       item[key] = value?.map(_ => ({
                                                                        "name": _
                                                                    }))
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
        running: diseaseSearchBox.displayText !== ""
                 && diseaseListView.previousDisplayText !== diseaseSearchBox.text
        onTriggered: {
            fetchMore()
            diseaseListView.previousDisplayText = diseaseSearchBox.text
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        RowLayout {
            visible: !hideSearchBar
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

        GridView {
            id: diseaseList
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: diseasesModel

            cellWidth: diseaseList.width > 800 ? diseaseList.width / 5 : (diseaseList.width > 500 ? diseaseList.width / 3 : diseaseList.width / 2)
            cellHeight: cellWidth + 60

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

                width: diseaseList.cellWidth
                height: diseaseList.cellHeight

                Column {
                    width: parent.width - 10
                    leftPadding: 10

                    ClipRRect {
                        width: parent.width - 10
                        height: width
                        radius: 20

                        Rectangle {
                            anchors.fill: parent
                            color: $Colors.gray100
                        }

                        Image {
                            anchors.fill: parent
                            source: {
                                let fileID = modelData.images?.get(
                                        0)?.directus_files_id
                                    ?? modelData.images[0]?.directus_files_id
                                if (fileID) {
                                    return "https://blume.mahoudev.com/assets/" + fileID
                                }
                                return ""
                            }
                        }

                        Rectangle {
                            color: "#e5e5e5"
                            anchors.fill: parent
                            visible: modelData['images']?.count === 0
                                     || modelData['images'].length === 0
                        }
                    }

                    Column {
                        width: parent.width
                        Label {
                            text: modelData.nom_scientifique
                            color: $Colors.black
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            width: parent.width - 10
                            elide: Text.ElideRight
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Label {
                            text: modelData.noms_communs?.get(0)?.name
                                  ?? modelData.noms_communs[0]?.name ?? ""
                            color: $Colors.black
                            fontSizeMode: Text.Fit
                            font.pixelSize: 13
                            font.weight: Font.Light
                            width: parent.width - 10
                            elide: Text.ElideRight
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"

                    onClicked: {
                        diseaseSearchBox.focus = false

//                        page_view.push(navigator.deseaseDetailsPage, {
//                                           "desease_data": {
//                                               "id": modelData.id
//                                           },
//                                           "isBlumeDisease": true
//                                       })
                        let mainURL = ""
                        let fileID = modelData.images?.get(
                                0)?.directus_files_id
                            ?? modelData.images[0]?.directus_files_id
                        if (fileID) {
                            mainURL = "https://blume.mahoudev.com/assets/" + fileID
                        }

                        const otherURLs = []
                        for(let i = 0; i < modelData.images.count ; i++) {
                            console.log("\n\n Wanna otherURLs ", i)
                            const item = modelData.images.get(i)
                            console.log("-----> ", item?.directus_files_id)
                            otherURLs.push("https://blume.mahoudev.com/assets/" + item?.directus_files_id)
                        }

                        const payload = {
                            "diseaseName":  modelData.nom_scientifique,
                            "common_names": modelData["disease_details"]?.common_names,
                            "mainURL": mainURL,
                            "similarImages": otherURLs
                        }
                        console.log("\n PAYLOAD ",JSON.stringify(payload))
                        console.log("\n\n  modelData ", modelData.images)
                        page_view.push(navigator.deseaseDetailsPage, payload)
                    }
                }
            }

            ItemNoPlants {
                visible: diseaseList.count === 0 && !isLoading
                textItem.text: qsTr("No plants found. Please, try using camera !")
            }
        }
    }

    BusyIndicator {
        running: isLoading
        anchors.centerIn: parent
    }
}
