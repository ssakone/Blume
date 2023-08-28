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

    backgroundColor: $Colors.colorTertiary
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
    Rectangle {
        anchors {
            bottom: parent.top
            bottomMargin: -150
            horizontalCenter: parent.horizontalCenter
        }

        height: 1200
        width: height / 1.5
        radius: height

        color: $Colors.primary
    }

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


            RowLayout {
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                spacing: 15

                MouseArea {
                    id: plantSearchBoxMS
                    anchors.fill: parent
                    anchors.rightMargin: 70
                    onClicked: {
                        page_view.push(navigator.plantSearchPage)
                    }
                }

                TextFieldThemed {
                    id: plantSearchBox
                    Layout.fillWidth: true
                    z: 5
                    height: 50
                    placeholderText: qsTr("Search for plants")
                    selectByMouse: true
                    colorSelectedText: "white"
                    enabled: false
//                    onFocusChanged: {
//                        if (focus) {
//                            plantSearchBoxMS.clicked()
//                            focus = false
//                        }
//                    }
                }

                Rectangle {
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: $Colors.white
                    radius: 25

                    IconSvg {
                        anchors.centerIn: parent
                        source: Components.Icons.camera
                        color: $Colors.colorPrimary
                    }
                }

            }


            Item {
                anchors.fill: parent
                anchors.topMargin: 80
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
                                        "bg": $Colors.colorPrimary
                                    }, {
                                        "name": qsTr("Identify plant"),
                                        "icon": "qrc:/assets/icons_custom/scan_plant.svg",
                                        "image": "",
                                        "action": "identify",
                                        "bg": $Colors.colorSecondary
                                    }, {
                                        "name": qsTr("Light sensor"),
                                        "icon": Components.Icons.thermometer,
                                        "image": "",
                                        "action": "posometre",
                                        "bg": $Colors.colorPrimary
                                    }]
                        data.forEach((plant => append(plant)))
                    }
                }

                Flickable {
                    id: optionsFlickable
                    anchors.fill: parent
                    contentHeight: _insideColumn.height
                    clip: true
                    Column {
                        id: _insideColumn
                        width: parent.width

                        RowLayout {
                            width: parent.width
                            anchors.topMargin: 30
                            Item {
                                Layout.fillWidth: true
                            }

                            Repeater {
                                model: plantOptionModel
                                Item {
                                    Layout.preferredWidth: index === 1 ? 150 : 100
                                    Layout.preferredHeight: Layout.preferredWidth
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.bottomMargin: 35
                                        anchors.rightMargin: 15
                                        anchors.leftMargin: 15
                                        radius: 15
                                        opacity: mArea.containsMouse ? .8 : 1
                                        color: bg
                                        border {
                                            width: 1
                                            color: $Colors.green200
                                        }

                                        IconSvg {
                                            width: 64
                                            height: 64
                                            visible: icon !== ""
                                            anchors.centerIn: parent

                                            source: icon
                                            color: 'white'
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
                                        text: qsTr("Suggested plants")
                                    }
                                }

                            }

                            Item {
                                Layout.fillWidth: true
                            }

                        }

                        Column {
                            width: parent.width
                            leftPadding: 10
                            topPadding: 20
                            spacing: 7
                            Label {
                                text: qsTr("Plants you recorded")
                                color: $Colors.colorPrimary
                                font {
                                    pixelSize: 16
                                    weight: Font.Bold
                                }
                            }

                            Flickable {
                                height: 120
                                width: parent.width
                                contentWidth: _insideRow.width
                                clip: true
                                anchors.topMargin: 20

                                Row {
                                    id: _insideRow
                                    spacing: 10

                                    Repeater {
                                        model: $Model.space.plantInSpace
                                        delegate: Components.GardenPlantLine {
                                            property var plant: JSON.parse(plant_json)
                                            width: 300
                                            height: 100
                                            title: plant.name_scientific
                                            subtitle: plant.noms_communs[0]?.name ?? ""
                                            roomName: ""
                                            background.color: $Colors.colorSecondary
                                            imageSource: plant.images_plantes.length
                                                         > 0 ? "https://blume.mahoudev.com/assets/"
                                                               + plant.images_plantes[0].directus_files_id : ""
                                            onClicked: $Signaler.showPlant(plant)
                                        }
                                    }


                                }


                            }

                        }

                        Column {
                            width: parent.width
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 20
                            spacing: 7
                            Label {
                                text: qsTr("Some plants")
                                color: $Colors.colorPrimary
                                font {
                                    pixelSize: 16
                                    weight: Font.Bold
                                }
                            }

                            Components.SearchPlants {
                                width: parent.width - 20
                                height: plantBrowser.height
                                hideSearchBar: true
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
