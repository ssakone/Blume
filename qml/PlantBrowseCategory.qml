import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtSensors
import SortFilterProxyModel
import QtQuick.Dialogs
import Qt.labs.platform

import "components" as Components

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Popup {
    id: listCategoryPlants
    width: parent.width
    height: parent.height
    x: -10

    property string title: "Catégorie"
    property int category_id
    onOpened: {
        if(listCategoryPlants.category_id) {
            Components.Http.fetch({
                method: 'GET',
                url: "https://blume.mahoudev.com/items/Plantes?filter[categorie][id][_eq]=" + category_id,
            }).then(response => {
                        let data = JSON.parse(response).data
                        console.log("Fetched data")
//                        console.log(data, Object.keys(data).slice(0, 10), JSON.stringify(data))
                data.forEach(item => categoryModel.append(item))
            })
        }

//        categoryModel.filter('')
//        categoryModel.plants.forEach(i => independant.append(i))
    }

    onClosed: {
        listCategoryPlants.title = ""
        listCategoryPlants.category_id = 0
        categoryModel.clear()
    }


    background: Rectangle {
        radius: 18
    }

    closePolicy: Popup.NoAutoClose

    ListModel {
        id: categoryModel
    }

    Rectangle {
        color: "#00c395"
        height: 65
//        Layout.fillWidth: true
        width: listCategoryPlants.width
        y: -70
        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                id: buttonBackBg
                anchors.verticalCenter: parent.verticalCenter
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

    Label {
        text: title
        font.pixelSize: 35
        font.weight: Font.Light
    }

    ListView {
        id: plantList
        bottomMargin: 32
        spacing: 0
        clip: true
        anchors.fill: parent
        model: categoryModel

        delegate: Rectangle {
            width: ListView.view.width
            height: 40

            color: (index % 2) ? Theme.colorForeground : Theme.colorBackground

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                Text {
                    text: model.name_scientific
                    color: Theme.colorText
                    fontSizeMode: Text.Fit
                    font.pixelSize: 14
                    minimumPixelSize: Theme.fontSizeContentSmall
                }
                Text {
                    visible: model.noms_communs !== null
                    text: "« " + (model.noms_communs ? model.noms_communs[0] : "" ) + " »"
                    color: Theme.colorSubText
                    fontSizeMode: Text.Fit
                    font.pixelSize: Theme.fontSizeContent
                    minimumPixelSize: Theme.fontSizeContentSmall
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    plantScreenDetailsPopup.plant = model
                    plantScreenDetailsPopup.open()
                }
            }
        }

        ItemNoPlants {
            visible: (categoryModel.count <= 0)
        }
    }

    PlantScreenDetails {
        id: plantScreenDetailsPopup
    }
}

