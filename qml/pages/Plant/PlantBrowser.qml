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
    header: Item {}

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
            bottomMargin: -200
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
//            plantSearchBox.text = ""
//            plantSearchBox.focus = false
//            itemPlantBrowser.visible = true
//            itemPlantBrowser.enabled = true
        }

        function focusSearchBox() {
            // Search focus is set on desktop
//            if (isDesktop) {
//                plantSearchBox.focus = true
//            }
        }

        Component.onCompleted: focusSearchBox()
        anchors.fill: parent

        ////////////////
        Item {
            id: itemPlantBrowser
            anchors.fill: parent

            Item {
                anchors.fill: parent
                anchors.margins: 0
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
                    anchors.topMargin: 30
                    contentHeight: _insideColumn.height
                    clip: true
                    Column {
                        id: _insideColumn
                        width: parent.width
                        spacing: 20

                        Column {
                            width: parent.width - 30
                            leftPadding: 15
                            rightPadding: 15
                            spacing: 20

                            RowLayout {
                                width: parent.width
                                anchors.topMargin: 5

                                Rectangle {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: Layout.preferredWidth
                                    radius: Layout.preferredHeight / 2
                                    color: $Colors.white


                                    IconSvg {
                                        width: parent.width - 4
                                        height: width
                                        anchors.centerIn: parent
                                        source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                                        color: $Colors.colorPrimary
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: appDrawer.open()
                                        }
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    Label {
                                        text: qsTr("Plants menu")
                                        font {
                                            pixelSize: 36
                                            family: "Courrier"
                                            weight: Font.Bold
                                        }
                                        color: $Colors.white
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    Label {
                                        text: qsTr("Gérez les plantes de manière efficace")
                                        opacity: .5
                                        color: $Colors.white
                                        font {
                                            pixelSize: 14
                                            family: "Courrier"
                                            weight: Font.Bold
                                        }
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                Rectangle {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: Layout.preferredWidth
                                    radius: Layout.preferredHeight / 2
                                    color: $Colors.white


                                    IconSvg {
                                        width: parent.width - 4
                                        height: width
                                        anchors.centerIn: parent
                                        source: Components.Icons.bell
                                        color: $Colors.colorPrimary
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: page_view.push(navigator.loginPage)
                                        }
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: 60
                                MouseArea {
                                    id: plantSearchBoxMS
                                    anchors.fill: parent
                                    anchors.rightMargin: 70
                                    onClicked: {
                                        page_view.push(navigator.plantSearchPage)
                                    }
                                }
                                RowLayout {
                                    anchors.top: parent.top
                                    anchors.topMargin: 14
                                    anchors.left: parent.left
                                    anchors.leftMargin: 25
                                    anchors.right: parent.right
                                    anchors.rightMargin: 25
                                    spacing: 15

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        id: plantSearchBox
                                        z: 5
                                        color: "#BBFEEA"
                                        radius: height/2
                                        Text {
                                            text: qsTr("Search for plants")
                                            color: $Colors.gray600
                                            leftPadding: 15
                                            font.pixelSize: 14
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                leftMargin: 25
                                            }
                                        }
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

                            }

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
                                            text: name
                                        }
                                    }

                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                            }
                        }

                        Column {
                            width: parent.width
                            leftPadding: 10
                            topPadding: 20
                            spacing: 7
                            Label {
                                text: qsTr("Mes favoris")
                                color: $Colors.colorPrimary
                                font {
                                    pixelSize: 16
                                    weight: Font.Bold
                                }
                            }

                            Flickable {
                                height: 140
                                width: parent.width
                                contentWidth: _insideRow.width
                                clip: true
                                anchors.topMargin: 20

                                Row {
                                    id: _insideRow
                                    spacing: 10

                                    BusyIndicator {
                                        running: favorisRepeater.model?.length === 0
                                        visible: running
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Repeater {
                                        id: favorisRepeater
                                        Component.onCompleted: {
                                            const url = `https://blume.mahoudev.com/items/Plantes?offset=${Math.ceil(Math.random() * 1000)}&limit=5&fields=*.*`

                                            Http.fetch({
                                                    method: "GET",
                                                    url: url,
                                                    headers: {
                                                       "Accept": 'application/json',
                                                       "Content-Type": 'application/json'                                                    },
                                                }).then(function(response) {
//                                                    console.log("Got favoris ", response)
                                                const parsedResponse = JSON.parse(response) ?? []
                                                console.log("Favoris ", parsedResponse?.data?.length)
                                                favorisRepeater.model = parsedResponse.data ?? parsedResponse
                                            })
                                        }

                                        model: []
                                        delegate: Components.GardenPlantLineWide {
                                            required property variant modelData
                                            property var plant: modelData
                                            width: 300
                                            height: 140
                                            title: plant.name_scientific
                                            subtitle: "Margérite"
                                            moreDetailsList: [{
                                                iconSource: Components.Icons.water,
                                                text: "Toxique"
                                                }, {
                                                    iconSource: Components.Icons.food,
                                                    text: "Commestible"
                                                    }]
                                            roomName: ""
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

            //boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
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
