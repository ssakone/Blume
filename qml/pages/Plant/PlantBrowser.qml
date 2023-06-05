import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtSensors
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import "../"
import "../../"
import "../../components" as Components
import "../../components_generic"
import "../../components_js/Http.js" as Http

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

BPage {
    id: plantBrowser
    objectName: "Plants"
    header: Components.AppBar {
        title: "Plants menu"
        noAutoPop: true
        isHomeScreen: true
        leading.onClicked: plantBrowser.StackView.view.pop()
    }

    property string entryPoint: "DeviceList"

    ////////////////////////////////////////////////////////////////////////////
    function loadScreen() {
        // Load the data
        plantDatabase.load()
        plantDatabase.filter("")

        item.resetPlantClicked()
        item.focusSearchBox()

        // Change screen
        //appContent.state = "PlantBrowser"
    }

    Component.onCompleted: loadScreen()

    ////////////////////////////////////////////////////////////////////////////
    Item {
        id: item
        function resetPlantClicked() {
            plantSearchBox.text = ""
            plantSearchBox.focus = false
            itemPlantBrowser.visible = true
            itemPlantBrowser.enabled = true
        }

        function focusSearchBox() {
            // Search focus is set on desktop
            if (isDesktop) {
                plantSearchBox.focus = true
            }
        }

        Component.onCompleted: focusSearchBox()
        anchors.fill: parent

        ////////////////
        Item {
            id: itemPlantBrowser
            anchors.fill: parent

            //            Rectangle {
            //                anchors.fill: plantSearchBox
            //                anchors.margins: -12
            //                z: 4
            //                color: Theme.colorBackground
            //            }
            Image {
                y: 20
                x: 16
                source: Components.Icons.close
                //                visible: plantListView.visible
                MouseArea {
                    anchors.fill: parent
                    onClicked: plantListView.close()
                }
            }

            TextFieldThemed {
                id: plantSearchBox
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                z: 5
                height: 40
                placeholderText: qsTr("Search for plants")
                selectByMouse: true
                colorSelectedText: "white"

                onFocusChanged: {
                    if (focus) {
                        plantSearchBoxMS.clicked()
                        focus = false
                    }
                }

                //onDisplayTextChanged: plantDatabase.filter(displayText)
                MouseArea {
                    id: plantSearchBoxMS
                    anchors.fill: parent
                    anchors.rightMargin: 70
                    onClicked: {
                        page_view.push(navigator.plantSearchPage)
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

                    IconSvg {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                        color: Theme.colorText
                    }
                }
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: 64
                anchors.leftMargin: 0
                anchors.rightMargin: 0

                ListModel {
                    id: plantOptionModel

                    Component.onCompleted: {
                        let data = [{
                                        "name": qsTr("Suggested plants"),
                                        "icon": "qrc:/assets/icons_custom/thumbs.png",
                                        "image": "",
                                        "action": "",
                                        "style": "darkblue"
                                    }, {
                                        "name": qsTr("Identify plant"),
                                        "icon": "qrc:/assets/icons_custom/plant_scan.png",
                                        "image": "",
                                        "action": "identify",
                                        "style": "lightenYellow"
                                    }, {
                                        "name": qsTr("Light sensor"),
                                        "icon": "qrc:/assets/icons_custom/posometre.svg",
                                        "image": "",
                                        "action": "posometre",
                                        "style": "sunrise"
                                    }, {
                                        "name": qsTr("Floral plants"),
                                        "icon": "",
                                        "image": "qrc:/assets/img/fleure.jpg",
                                        "action": "categorie_plantes_fleuries",
                                        "style": ""
                                    }, {
                                        "name": qsTr("Orchids"),
                                        "icon": "",
                                        "image": "qrc:/assets/img/orchidee.jpg",
                                        "action": "categorie_plantes_orchidee",
                                        "style": ""
                                    }, {
                                        "name": qsTr("Cactus and succulents"),
                                        "icon": "",
                                        "image": "qrc:/assets/img/cactus.jpg",
                                        "action": "categorie_plantes_cactus_succulentes",
                                        "style": ""
                                    }, {
                                        "name": qsTr("Vegetables"),
                                        "icon": "",
                                        "image": "qrc:/assets/img/legume.jpg",
                                        "action": "categorie_plantes_legumes",
                                        "style": ""
                                    }, {
                                        "name": qsTr("Herbal"),
                                        "icon": "",
                                        "image": "qrc:/assets/img/herbe.jpeg",
                                        "action": "categorie_plantes_herbes",
                                        "style": ""
                                    }, {
                                        "name": qsTr("Foliage plants"),
                                        "icon": "",
                                        "image": "qrc:/assets/img/feuillage.jpg",
                                        "action": "categorie_plantes_feuillage",
                                        "style": ""
                                    }]
                        data.forEach((plant => append(plant)))
                    }
                }

                Flickable {
                    anchors.fill: parent
                    contentHeight: _insideColumn.height
                    clip: true
                    Column {
                        id: _insideColumn
                        width: parent.width
                        Item {
                            width: parent.width
                            height: (3 * ((parent.width - (20)) / 3)) + 30
                            GridView {
                                id: gr
                                y: 10
                                interactive: false
                                width: parent.width
                                height: parent.height - 20
                                cellWidth: gr.width > 800 ? gr.width / 5 : (gr.width > 500 ? gr.width / 4 : gr.width / 3)
                                cellHeight: cellWidth
                                model: plantOptionModel
                                delegate: Item {
                                    width: gr.cellWidth
                                    height: width
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.bottomMargin: 35
                                        anchors.rightMargin: 15
                                        anchors.leftMargin: 15
                                        radius: 10
                                        opacity: mArea.containsMouse ? .8 : 1
                                        gradient: Gradient {
                                            orientation: Qt.Horizontal
                                            GradientStop {
                                                position: 0.04
                                                color: {
                                                    switch (style) {
                                                    case "darkblue":
                                                        return "#2c718a"
                                                    case "lightenYellow":
                                                        return "#93d1be"
                                                    case "sunrise":
                                                        return "#ffc6a4"
                                                    default:
                                                        return "#ccc"
                                                    }
                                                }
                                            }
                                            GradientStop {
                                                position: 1.00
                                                color: {
                                                    switch (style) {
                                                    case "darkblue":
                                                        return "#143e44"
                                                    case "lightenYellow":
                                                        return "#0ca780"
                                                    case "sunrise":
                                                        return "#fc9185"
                                                    default:
                                                        return "#ccc"
                                                    }
                                                }
                                            }
                                        }
                                        IconSvg {
                                            width: 64
                                            height: 64
                                            visible: icon !== ""
                                            anchors.centerIn: parent

                                            source: icon
                                            color: 'white'
                                        }
                                        Components.ClipRRect {
                                            anchors.fill: parent
                                            visible: image.toString() !== ""
                                            Image {
                                                id: img
                                                source: image
                                                anchors.fill: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mArea
                                            anchors.fill: parent
                                            enabled: action !== ""
                                            hoverEnabled: enabled
                                            onClicked: {
                                                if (action === "posometre") {
                                                    page_view.push(
                                                                navigator.posometrePage)
                                                } else if (action === "identify") {
                                                    page_view.push(
                                                                navigator.plantIdentifierPage)
                                                } else {
                                                    let title = ""
                                                    let pk = 0
                                                    if (action === "categorie_plantes_herbes") {
                                                        title = qsTr("Herbal")
                                                        pk = 1
                                                    } else if (action
                                                               === "categorie_plantes_legumes") {
                                                        title = qsTr("Vegetables")
                                                        pk = 2
                                                    } else if (action
                                                               === "categorie_plantes_orchidee") {
                                                        title = qsTr("Orchids")
                                                        pk = 3
                                                    } else if (action
                                                               === "categorie_plantes_fleuries") {
                                                        title = qsTr("Floral plants")
                                                        pk = 4
                                                    } else if (action === "categorie_plantes_cactus_succulentes") {
                                                        title = qsTr("Les cactus & succculents")
                                                        pk = 5
                                                    } else if (action
                                                               === "categorie_plantes_feuillage") {
                                                        title = qsTr("Foiliage plantes")
                                                        pk = 6
                                                    }

                                                    page_view.push(
                                                                navigator.plantCategoriesBrowserPage, {category_id: pk, title})
                                                }
                                            }
                                        }
                                    }
                                    Label {
                                        width: parent.width - 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 3
                                        height: 28
                                        wrapMode: Label.Wrap
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        horizontalAlignment: Label.AlignHCenter
                                        verticalAlignment: Label.AlignVCenter
                                        text: name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////
        Flickable {
            id: itemPlantViewer
            anchors.fill: parent
            anchors.topMargin: plantSelector_desktop.visible ? plantSelector_desktop.height : 0
            anchors.bottomMargin: plantSelector_mobile.visible ? plantSelector_mobile.height : 0

            visible: false

            // 1: single column (single column view or portrait tablet)
            // 2: wide mode (wide view)
            property int uiMode: (singleColumn
                                  || (isTablet
                                      && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

            contentWidth: (uiMode === 1) ? -1 : plantScreen.width
            contentHeight: (uiMode === 1) ? plantScreen.height : -1

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar {
                visible: false
            }

            function setPlant() {
                page_view.push(plantScreen, {
                                   "currentPlant": currentDevice.plant
                               })
            }

            Component {
                id: plantScreen
                PlantScreen {}
            }
        }

        ////////////////////////////////////////////////////////////////////
        Rectangle {
            id: plantSelector_desktop
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            z: 5
            height: 52
            color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

            visible: (!singleColumn && appContent.state === "PlantBrowser"
                      && screenPlantBrowser.entryPoint === "DevicePlantSensor"
                      && isPlantClicked())

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: "You are previewing a plant."
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: 22
            }

            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                ButtonWireframeIcon {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorPrimary
                    Layout.fillWidth: true
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 320

                    text: qsTr("Choose this plant")
                    source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"

                    onClicked: {
                        selectedDevice.setPlantName(
                                    plantScreen.currentPlant.name)
                        appContent.state = "DevicePlantSensor"
                    }
                }
                ButtonWireframe {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorSubText
                    Layout.fillWidth: false

                    text: qsTr("Cancel")

                    onClicked: {
                        appContent.state = "DevicePlantSensor"
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: (isDesktop && !headerUnicolor)
                height: 2
                opacity: 0.5
                color: Theme.colorSeparator
            }
        }

        ////////
        Rectangle {
            id: plantSelector_mobile
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            z: 5
            height: 52
            color: Theme.colorForeground
            visible: (singleColumn && appContent.state === "PlantBrowser"
                      && screenPlantBrowser.entryPoint === "DevicePlantSensor"
                      && isPlantClicked())

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ButtonWireframeIcon {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorPrimary
                    Layout.fillWidth: true
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 999

                    text: qsTr("Choose this plant")
                    source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"

                    onClicked: {
                        selectedDevice.setPlantName(
                                    plantScreen.currentPlant.name)
                        appContent.state = "DevicePlantSensor"
                    }
                }
                ButtonWireframe {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorSubText
                    Layout.fillWidth: false

                    text: qsTr("Cancel")

                    onClicked: {
                        appContent.state = "DevicePlantSensor"
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////
    }
}
