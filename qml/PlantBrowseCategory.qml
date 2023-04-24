import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtSensors
import SortFilterProxyModel
import QtQuick.Dialogs
import Qt.labs.platform
import "components" as Components
import "components_js/Http.js" as Http
import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Popup {
    id: listCategoryPlants

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height
    padding: 0

    property string title: "Catégorie"
    property int category_id
    property variant plants_list: []

    onOpened: {
        if(listCategoryPlants.category_id) {
            Http.fetch({
                method: 'GET',
                url: "https://blume.mahoudev.com/items/Plantes?fields[]=*.*&filter[categorie][id][_eq]=" + category_id,
            }).then(response => {
                let data = JSON.parse(response).data
                plants_list = data
            })
        }
    }

    onClosed: {
        listCategoryPlants.title = ""
        listCategoryPlants.category_id = 0
    }


    background: Rectangle {
    }

    closePolicy: Popup.NoAutoClose

    Rectangle {
        id: header
        color: "#00c395"
        height: 65
        width: listCategoryPlants.width
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
                        listCategoryPlants.close()
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



    ListView {
        id: plantList
        spacing: 0
        clip: true
        anchors.fill: parent
        anchors.topMargin: header.height
        model: plants_list

        header: Label {
            text: title
            font.pixelSize: 35
            font.weight: Font.Light
            anchors.leftMargin: 15
        }

        delegate: ItemDelegate {
            required property variant modelData
            required property int index

            width: ListView.view.width
            height: 80

            background: Rectangle {
                color: (index % 2 ) ? "white" : "#f0f0f0"
            }

            Components.ClipRRect {
                id: leftImg
                height: 60
                width: height
                radius: width / 2
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    source: modelData.images_plantes.length === 0 ? "" : "https://blume.mahoudev.com/assets/" + modelData.images_plantes[0].directus_files_id
                    anchors.fill: parent
                }
            }

            Column {
                anchors.left: leftImg.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: modelData.name_scientific
                    color: Theme.colorText
                    fontSizeMode: Text.Fit
                    font.pixelSize: 18
                    minimumPixelSize: Theme.fontSizeContentSmall
                }
                Text {
                    text: {
                        if(modelData.noms_communs) {
                            return modelData.noms_communs ? ( modelData.noms_communs[0] + (modelData.noms_communs[1] ? `, ${modelData.noms_communs[1]}` : "") ) : ""
                        }
                        return ""
                    }

                    color: Theme.colorSubText
                    fontSizeMode: Text.Fit
                    font.pixelSize: 14
                    minimumPixelSize: Theme.fontSizeContentSmall
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    console.log(JSON.stringify(modelData))
                    plantScreenDetailsPopup.plant = modelData
                    plantScreenDetailsPopup.open()
                }
            }

        }

        ItemNoPlants {
            visible: (plants_list.length <= 0)
        }
    }

    PlantScreenDetails {
        id: plantScreenDetailsPopup
    }
}

