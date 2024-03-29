import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ThemeEngine 1.0

import SortFilterProxyModel

import ".."
import "../components_generic"
import "../components_themed/"
import "../components_js/Http.js" as Http

Item {
    id: root
    property int currentPage: 0
    property int pageLimit: 20

    property bool isLoading: true
    //    property variant plantsModel: []
    property string previousDisplayText: ""
    property bool preventDefaultOnClick: false
    property bool hideCameraSearch: false
    property bool hideSearchBar: false
    property bool autoFocusSearchbar: false

    signal itemClicked(var data)

    Component.onCompleted: {
        fetchMore()
        if (autoFocusSearchbar) {
            plantSearchBox.forceActiveFocus()
        }
    }

    function fetchMore() {
        console.log("Gonna fetch_more...")
        isLoading = true
        const q = plantSearchBox.displayText
        let query = `https://blume.mahoudev.com/items/Plantes?fields=*.*&limit=${plantSearchBox.displayText
            !== "" ? 70 : pageLimit}&offset=${currentPage * pageLimit}`

        if(q) {
            query +=
                    `&filter={
                        "_or":[
                           {
                              "name_scientific":{
                                 "_contains": "${q}"
                              }
                           }, {
                              "nom_botanique":{
                                 "_contains": "${q}"
                              }
                           }, {
                            "noms_communs_str":{
                               "_contains": "${q}"
                            }
                         }
                        ]
                     }`
        }


        console.log("\n\n QUeryPP ", query)

        Http.fetch({
                       "method": 'GET',
                       "url": query
                   }).then(response => {
                               console.log("Fetch success")
                               let data = JSON.parse(response).data

                               // Remove null value
                               if (plantSearchBox.displayText !== "") {
                                   plantsModel.clear()
                               }
                               for (var i = 0; i < data.length; i++) {
                                   let item = data[i]
                                   let itemKeys = Object.keys(item)
                                   for (var j = 0; j < itemKeys.length; j++) {
                                       let key = itemKeys[j]
                                       let value = item[key]
                                       if (value === null) {
                                           if ('categorie' === key)
                                           item[key] = {}
                                           else if (['sites', 'light_level', 'noms_communs'].includes(
                                                        key))
                                           item[key] = []
                                           else
                                           item[key] = ""
                                       } else if (key === 'noms_communs') {
                                           item[key] = item[key].map(
                                               common => ({
                                                              "name": common
                                                          }))
                                       }
                                   }
                                   plantsModel.append(item)
                               }

                               isLoading = false
                           })
        .catch(function(err) {
            console.log(err, err?.statusText)
            console.log(JSON.stringify(err))
        })
    }

    onItemClicked: data => {
                       plantSearchBox.focus = false
                       if (preventDefaultOnClick === false) {
                           page_view.push(navigator.plantPage, {
                                              "plant": data
                                          })
                       }
                   }

    ListModel {
        id: plantsModel
    }

    Timer {
        id: searchTimer
        interval: 1500
        repeat: true
        running: plantSearchBox.displayText !== ""
                 && root.previousDisplayText !== plantSearchBox.text
        onTriggered: {
            fetchMore()
            root.previousDisplayText = plantSearchBox.text
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Layout.margins: 15
            visible: !hideSearchBar

            TextFieldThemed {
                id: plantSearchBox
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                selectByMouse: true
                colorSelectedText: "white"

                onAccepted: {
                    root.currentPage = 0
                    root.fetchMore()
                }
                onTextChanged: {

                    root.isLoading = true
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
                            root.currentPage = 0
                            root.fetchMore()
                        }
                    }
                }
            }

            IconSvg {
                source: Icons.camera
                color: Theme.colorPrimary
                visible: !hideCameraSearch
                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"
                    onClicked: page_view.push(navigator.plantIdentifierPage)
                }
            }
        }

        GridView {
            id: plantList
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.leftMargin: 10
            Layout.rightMargin: 10

            clip: true
            model: plantsModel

            cellWidth: plantList.width > 800 ? plantList.width / 5 : (plantList.width > 500 ? plantList.width / 3 : plantList.width / 2)
            cellHeight: cellWidth + 60

            ScrollBar.vertical: ScrollBar {
                property bool isLoading: false
                id: searchScrollBar
                visible: isDesktop
                onPositionChanged: {
                    if (root.isLoading === false
                            && (searchScrollBar.size + searchScrollBar.position > 0.99)
                            && plantSearchBox.displayText === "") {
                        currentPage++
                        fetchMore()
                    }
                }
            }

            delegate: Item {
                id: itemDelegate
                required property variant model
                required property int index

                property variant modelData: model

                width: plantList.cellWidth
                height: plantList.cellHeight

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
                                let fileID = modelData.images_plantes?.get(
                                        0)?.directus_files_id
                                    ?? modelData.images_plantes[0]?.directus_files_id
                                if (fileID) {
                                    return "https://blume.mahoudev.com/assets/" + fileID
                                }
                                return ""
                            }
                        }

                        Rectangle {
                            color: "#e5e5e5"
                            anchors.fill: parent
                            visible: modelData['images_plantes']?.count === 0
                                     || modelData['images_plantes'].length === 0
                        }

                        function stringify(schema) {
                            let objectData = {}
                            for (let field in schema) {
                                const fieldType = schema[field].type
                                //                            console.log(field, " -> ", typeof modelData[field],
                                //                                        modelData[field])
                                if (fieldType === 'string') {
                                    objectData[field] = modelData[field]
                                } else if (fieldType === 'array') {
                                    objectData[field] = stringify()
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        Label {
                            text: modelData.name_scientific
                            color: $Colors.black
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            width: parent.width - 10
                            elide: Text.ElideRight
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Label {
                            text: modelData.noms_communs_str?.split(",")[0] ?? ""
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
                        const schema = {
                            "id": {
                                "type": "string"
                            },
                            "sort": {
                                "type": "string"
                            },
                            "user_created": {
                                "type": "string"
                            },
                            "date_created": {
                                "type": "string"
                            },
                            "user_updated": {
                                "type": "string"
                            },
                            "date_updated": {
                                "type": "string"
                            },
                            "name_scientific": {
                                "type": "string"
                            },
                            "description": {
                                "type": "string"
                            },
                            "care_level": {
                                "type": "string"
                            },
                            "temp_min": {
                                "type": "string"
                            },
                            "temp_max": {
                                "type": "string"
                            },
                            "sites": {
                                "type": "array"
                            },
                            "comment_cultiver": {
                                "type": "string"
                            },
                            "description_luminosite": {
                                "type": "string"
                            },
                            "description_sol": {
                                "type": "string"
                            },
                            "description_temperature_humidite": {
                                "type": "string"
                            },
                            "mise_en_pot_et_rampotage": {
                                "type": "string"
                            },
                            "description_multiplication": {
                                "type": "string"
                            },
                            "description_variete": {
                                "type": "string"
                            },
                            "description_parasites_maladies": {
                                "type": "string"
                            },
                            "taill_adulte": {
                                "type": "string"
                            },
                            "exposition_au_soleil": {
                                "type": "string"
                            },
                            "type_de_plante": {
                                "type": "string"
                            },
                            "cycle_de_vie": {
                                "type": "string"
                            },
                            "type_de_sol": {
                                "type": "string"
                            },
                            "ph": {
                                "type": "string"
                            },
                            "periode_de_floraison": {
                                "type": "string"
                            },
                            "couleur": {
                                "type": "string"
                            },
                            "zone_de_rusticite": {
                                "type": "string"
                            },
                            "region_origine": {
                                "type": "string"
                            },
                            "noms_communs": {
                                "type": "array"
                            },
                            "toxicity": {
                                "type": "string"
                            },
                            "metrique_humidite_minimale_du_sol": {
                                "type": "string"
                            },
                            "metrique_humidite_maximale_du_sol": {
                                "type": "string"
                            },
                            "metrique_conductivite_maximale_du_sol": {
                                "type": "string"
                            },
                            "metrique_conductivite_minimale_du_sol": {
                                "type": "string"
                            },
                            "metrique_ph_minimale": {
                                "type": "string"
                            },
                            "metrique_ph_maximale": {
                                "type": "string"
                            },
                            "metrique_temperature_minimale": {
                                "type": "string"
                            },
                            "metrique_temperature_maximale": {
                                "type": "string"
                            },
                            "metrique_luminosite_lux_maximale": {
                                "type": "string"
                            },
                            "metrique_luminosite_lux_minimale": {
                                "type": "string"
                            },
                            "metrique_humidite_plante_minimale": {
                                "type": "string"
                            },
                            "metrique_humidite_plante_maximale": {
                                "type": "string"
                            },
                            "metrique_luminosite_mmol_maximale": {
                                "type": "string"
                            },
                            "metrique_luminosite_mmol_minimale": {
                                "type": "string"
                            },
                            "a_jour": {
                                "type": "string"
                            },
                            "categorie": {
                                "type": "object"
                            },
                            "nom_botanique": {
                                "type": "string"
                            },
                            "frequence_arrosage": {
                                "type": "string"
                            },
                            "frequence_rampotage": {
                                "type": "string"
                            },
                            "frequence_fertilisation": {
                                "type": "string"
                            },
                            "frequence_nettoyage": {
                                "type": "string"
                            },
                            "frequence_vaporisation": {
                                "type": "string"
                            },
                            "images_plantes": {
                                "type": "array"
                            },
                            "images_maladies": {
                                "type": "array"
                            }
                        }

                        let objectData = {}
                        for (let field in schema) {
                            const fieldType = schema[field].type
                            if (fieldType === 'string') {
                                objectData[field] = modelData[field]
                            } else if (fieldType === 'array') {
                                objectData[field] = []
                                const size = modelData[field].count
                                           ?? modelData[field].length
                                for (var i = 0; i < size; i++) {
                                    objectData[field].push(
                                                modelData[field].get(i))
                                }
                            }
                            //                            console.log(field, ' -> ', fieldType, ' -> ', modelData[field], ' -> ', objectData[field])
                        }

                        itemClicked(objectData)
                    }
                }
            }

            ItemNoPlants {
                visible: plantList.count === 0 && !isLoading
                textItem.text: qsTr("No plants found. Please, try using camera !")
            }
        }
    }

    BusyIndicator {
        running: isLoading
        anchors.centerIn: parent
    }
}
