import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtSensors
import SortFilterProxyModel
import QtQuick.Dialogs
import Qt.labs.platform
import "components" as Components
import "components_generic"
import "components_js/Http.js" as Http
import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

BPage {
    id: listCategoryPlants

    required property int category_id
    property variant plants_list: []
    property bool isLoaded: false

    signal itemClicked(var data)

    header: Components.AppBar {
        title: listCategoryPlants.title
    }

    Component.onCompleted: {
        loadingIndicator.running = true
        if (listCategoryPlants.category_id) {
            Http.fetch({
                           "method": 'GET',
                           "url": "https://blume.mahoudev.com/items/Plantes?fields[]=*.*&filter[categorie][id][_eq]=" + category_id
                       }).then(response => {
                                   let data = JSON.parse(response).data
                                   plants_list = data
                                   loadingIndicator.running = false
                               })
        }


    }

    onItemClicked: data => {
                       page_view.push(navigator.plantPage, {plant: data})

                   }

    GridView {
        id: plantList
        clip: true
        anchors.fill: parent
        model: plants_list

        cellWidth: plantList.width > 800 ? plantList.width / 5 : (plantList.width > 500 ? plantList.width / 3 : plantList.width / 2)
        cellHeight: cellWidth + 60

        delegate: Item {
            id: itemDelegate
            required property variant modelData
            required property int index


            width: plantList.cellWidth
            height: plantList.cellHeight


            Column {
                width: parent.width - 10
                leftPadding: 10

                Components.ClipRRect {
                    width: parent.width - 10
                    height: width
                    radius: 20

                    Rectangle {
                        anchors.fill: parent
                        color: $Colors.gray100
                    }

                    SwipeView {
                        anchors.fill: parent

                        Repeater {
                            model: modelData.images_plantes
                            delegate: Image {
                                required property variant modelData
                                source: "https://blume.mahoudev.com/assets/"
                                        + modelData['directus_files_id']
                            }
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
                            if(fieldType === 'string') {
                                objectData[field] = modelData[field]
                            } else if(fieldType === 'array') {
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
                        text: modelData.noms_communs ? modelData.noms_communs[0] : ""
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

                    itemClicked(modelData)
                }
            }

        }

        ItemNoPlants {
            visible: (plants_list.length === 0
                      && loadingIndicator.running === false)
        }
    }

    BusyIndicator {
        id: loadingIndicator
        anchors.centerIn: parent
    }
}
