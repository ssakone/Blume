import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
import DeviceUtils 1.0

import "components"
import "components_generic"
import "components_themed"
import "popups"
import "components_js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "./pages/Plant"

Item {
    id: devicePlantSensorData

    // 1: single column (single column view or portrait tablet)
    // 2: wide mode, two main rows (wide view)
    // 3: wide mode, two main columns (wide view, phones)
    property int uiMode: (singleColumn
                          || (isTablet && screenOrientation
                              === Qt.PortraitOrientation)) ? 1 : (isPhone ? 3 : 2)

    property var dataIndicators: indicatorsLoader.item
    property var dataChart: graphLoader.item

    ////////////////////////////////////////////////////////////////////////////
    function loadData() {
        if (typeof currentDevice === "undefined" || !currentDevice)
            return
        if (!currentDevice.isPlantSensor)
            return
        //console.log("DevicePlantSensorData // loadData() >> " + currentDevice)

        // force graph reload
        graphLoader.source = ""
        graphLoader.opacity = 0
        noDataIndicator.visible = false

        loadIndicators()
        loadGraph()
        updateHeader()
        updateData()
    }

    function loadGraph() {
        if (graphLoader.status !== Loader.Ready) {
            graphLoader.source = "ChartPlantDataAio.qml"
        } else {
            dataChart.loadGraph()
            dataChart.updateGraph()
        }
    }

    function loadIndicators() {
        if (indicatorsLoader.status !== Loader.Ready) {
            if (settingsManager.bigIndicator)
                indicatorsLoader.source = "IndicatorsCompact.qml"
            else
                indicatorsLoader.source = "IndicatorsCompact.qml"
        } else {
            dataIndicators.loadIndicators()
        }
    }
    function reloadIndicators() {
        if (settingsManager.bigIndicator)
            indicatorsLoader.source = "IndicatorsCompact.qml"
        else
            indicatorsLoader.source = "IndicatorsCompact.qml"

        if (indicatorsLoader.status === Loader.Ready) {
            dataIndicators.loadIndicators()
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice)
            return
        if (!currentDevice.isPlantSensor)
            return
        //console.log("DevicePlantSensorData // updateHeader() >> " + currentDevice)

        // Status
        updateStatusText()
    }

    Timer {
        interval: 60000
        running: visible
        repeat: true
        onTriggered: updateStatusText()
    }

    function updateStatusText() {
        if (typeof currentDevice === "undefined" || !currentDevice)
            return
        if (!currentDevice.isPlantSensor)
            return

        //console.log("DevicePlantSensorData // updateStatusText() >> " + currentDevice)
        textStatus.text = UtilsDeviceSensors.getDeviceStatusText(
                    currentDevice.status)
        textStatus.color = Theme.colorHighContrast
        textStatus.font.bold = false

        if (currentDevice.status === DeviceUtils.DEVICE_OFFLINE) {
            if (currentDevice.isDataFresh_rt() || currentDevice.isDataToday()) {
                if (currentDevice.lastUpdateMin <= 1)
                    textStatus.text = qsTr("Synced")
                else
                    textStatus.text = qsTr("Synced %1 ago").arg(
                                currentDevice.lastUpdateStr)
            } else {
                textStatus.color = Theme.colorRed
            }
        }
    }

    function updateData() {
        if (typeof currentDevice === "undefined" || !currentDevice)
            return
        if (!currentDevice.isPlantSensor)
            return
        //console.log("DevicePlantSensorData // updateData() >> " + currentDevice)
    }

    function updateLegendSizes() {
        if (indicatorsLoader.status === Loader.Ready)
            dataIndicators.updateLegendSize()
    }

    function updateGraph() {
        if (graphLoader.status === Loader.Ready)
            dataChart.updateGraph()
    }

    function backAction() {
        if (textInputPlant.focus) {
            textInputPlant.focus = false
            return
        }
        if (textInputLocation.focus) {
            textInputLocation.focus = false
            return
        }
        if (isHistoryMode()) {
            resetHistoryMode()
            return
        }

        appContent.state = "Navigator"
    }

    function isHistoryMode() {
        if (graphLoader.status === Loader.Ready)
            return dataChart.isIndicator()
        return false
    }
    function resetHistoryMode() {
        if (graphLoader.status === Loader.Ready)
            dataChart.resetIndicator()
    }

    ////////////////////////////////////////////////////////////////////////////
    Rectangle {
        id: subHeaderBackground
        width: parent.width
        height: (uiMode === 1) ? itemHeader.height : contentGrid_lvl2.height

        //Behavior on height { NumberAnimation { duration: 133 } }
        visible: (uiMode !== 3)
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

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
    Grid {
        id: contentGrid_lvl1
        anchors.fill: parent
        columns: (uiMode === 3) ? 2 : 1
        rows: 2
        spacing: 0

        Grid {
            id: contentGrid_lvl2
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            columns: (uiMode === 2) ? 3 : 1
            rows: 3
            spacing: 0

            ////////
            Item {
                id: itemHeader
                width: parent.columns === 1 ? parent.width : (parent.width * 0.36)
                height: columnHeader.height + 12

                Column {
                    id: columnHeader
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 2
                    spacing: 2

                    Rectangle {
                        id: itemPlantPreview
                        height: 80
                        width: parent.width
                        radius: height / 2
                        color: $Colors.gray200

                        visible: !(linkedPlant === undefined
                                   || linkedPlant === null)

                        RowLayout {
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 10

                            ClipRRect {
                                height: itemPlantPreview.height - 10
                                width: height
                                radius: width / 2

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.colorPrimary

                                    Image {
                                        anchors.fill: parent
                                        source: !linkedPlant.images_plantes[0] ? "" : "https://blume.mahoudev.com/assets/" + linkedPlant.images_plantes[0].directus_files_id
                                    }
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 5
                                Label {
                                    text: linkedPlant?.name_scientific || ""
                                    font.pixelSize: 16
                                }
                                Label {
                                    text: linkedPlant?.noms_communs?.length
                                          > 0 ? linkedPlant?.noms_communs[0].name : ""
                                    font.pixelSize: 13
                                }
                            }

                            IconSvg {
                                Layout.preferredHeight: 30
                                Layout.preferredWidth: 30
                                source: Icons.chevronRight
                            }
                        }

                        PlantScreenDetails {
                            id: plantScreenDetails

                            RowLayout {
                                width: parent.width
                                anchors.bottom: parent.bottom

                                ButtonWireframe {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    text: "Remove"
                                    fullColor: true
                                    primaryColor: $Colors.red400
                                    fulltextColor: $Colors.white
                                    componentRadius: 0
                                    onClicked: {
                                        $Model.device.sqlDeleteByDeviceAddress(
                                                    currentDevice.deviceAddress).then(
                                                    function (rs) {
                                                        plantScreenDetails.close()
                                                    })
                                    }
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                plantScreenDetails.plant = linkedPlant
                                plantScreenDetails.open()
                            }
                        }
                    }

                    Item {
                        id: itemLocation
                        height: 28
                        width: parent.width
                        visible: linkedPlant !== undefined

                        Text {
                            id: labelLocation
                            width: (dataIndicators) ? dataIndicators.legendWidth : 80
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Location")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        TextInput {
                            id: textInputLocation
                            anchors.left: labelLocation.right
                            anchors.leftMargin: 8
                            anchors.baseline: labelLocation.baseline
                            padding: 4

                            font.pixelSize: Theme.fontSizeContentBig
                            font.bold: false
                            color: Theme.colorHighContrast

                            text: (linkedSpaceName && linkedSpaceName.slice(
                                       1, -1)) || ""
                        }

                        IconSvg {
                            id: imageEditLocation
                            width: 20
                            height: 20
                            anchors.left: textInputLocation.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: textInputLocation.verticalCenter

                            source: "qrc:/assets/icons_material/duotone-edit-24px.svg"
                            color: Theme.colorSubText

                            opacity: (isMobile || !textInputLocation.text
                                      || textInputLocation.focus) ? 0.9 : 0
                            Behavior on opacity {
                                OpacityAnimator {
                                    duration: 133
                                }
                            }
                        }
                    }

                    Item {
                        id: status
                        height: 28
                        width: parent.width

                        Text {
                            id: labelStatus
                            width: (dataIndicators) ? dataIndicators.legendWidth : 80
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Status")
                            font.bold: true
                            font.pixelSize: Theme.fontSizeContentVerySmall
                            font.capitalization: Font.AllUppercase
                            color: Theme.colorSubText
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            id: textStatus
                            anchors.left: labelStatus.right
                            anchors.leftMargin: 8
                            anchors.right: parent.right
                            anchors.rightMargin: -4
                            anchors.baseline: labelStatus.baseline
                            padding: 4

                            text: qsTr("Loading...")
                            color: Theme.colorHighContrast
                            font.pixelSize: Theme.fontSizeContentBig
                            font.bold: false
                            elide: Text.ElideRight
                        }
                    }

                    Connections {
                        target: $Model.device
                        function onUpdated() {
                            $Model.device.sqlGetByDeviceAddress(
                                        currentDevice.deviceAddress).then(
                                        function (rs) {
                                            linkedPlant = JSON.parse(
                                                        rs.plant_json)
                                            linkedSpaceName = rs?.space_name
                                            currentDevice.devicePlantName
                                                    = linkedPlant?.name_scientific
                                            currentDevice.deviceLocationName = linkedSpaceName
                                            console.log("\n\n\n Catch onUpdated()")
                                        })
                        }
                    }
                    Connections {
                        target: $Model.device
                        function onCreated() {
                            $Model.device.sqlGetByDeviceAddress(
                                        currentDevice.deviceAddress).then(
                                        function (rs) {
                                            linkedPlant = JSON.parse(
                                                        rs.plant_json)
                                            linkedSpaceName = rs?.space_name
                                            currentDevice.devicePlantName
                                                    = linkedPlant?.name_scientific
                                            currentDevice.deviceLocationName = linkedSpaceName
                                            console.log("\n\n\n Catch onCreated() ")
                                        })
                        }
                    }

                    Connections {
                        target: $Model.device
                        function onDeleted() {
                            $Model.device.sqlGetByDeviceAddress(
                                        currentDevice.deviceAddress).then(
                                        function (rs) {
                                            linkedPlant = undefined
                                            linkedSpaceName = ""
                                            currentDevice.devicePlantName = ""
                                            currentDevice.deviceLocationName = linkedSpaceName
                                            console.log("\n\n\n Catch onDeleted() ")
                                        })
                        }
                    }

                    Item {
                        width: parent.width
                        height: 70
                        visible: !itemPlantPreview.visible

                        Drawer {
                            id: plantBrowserPop
                            parent: appContent
                            width: appWindow.width
                            height: appWindow.height
                            padding: 0

                            AppBar {
                                id: plantBrowserAppBar
                                title: qsTr("Back")
                                onBackButtonClicked: plantBrowserPop.close()
                            }

                            TabBar {
                                id: tabBar
                                padding: 0
                                anchors.top: plantBrowserAppBar.bottom
                                width: parent.width
                                contentHeight: plantBrowserAppBar.height

                                TabButton {
                                    text: qsTr("Plants of my garden")
                                    background: Rectangle {
                                        color: tabBar.currentIndex
                                               === 0 ? Theme.colorPrimary : $Colors.white
                                    }
                                }
                                TabButton {
                                    text: qsTr("All plants")
                                    background: Rectangle {
                                        color: tabBar.currentIndex
                                               === 1 ? Theme.colorPrimary : $Colors.white
                                    }
                                }
                            }

                            StackLayout {
                                id: tabView
                                anchors {
                                    fill: parent
                                    topMargin: tabBar.height
                                }

                                currentIndex: tabBar.currentIndex

                                Item {
                                    ListView {
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        anchors.topMargin: plantBrowserAppBar.height + 10
                                        spacing: 10
                                        model: $Model.space.plantInSpace
                                        delegate: GardenPlantLine {
                                            property var plant: JSON.parse(
                                                                    plant_json)
                                            width: parent.width
                                            height: 100
                                            title: plant.name_scientific
                                            subtitle: plant.noms_communs[0]?.name
                                                      ?? ""
                                            roomName: {
                                                $Model.space.sqlGet(
                                                            space_id).then(
                                                            res => {
                                                                roomName = res.libelle
                                                            }).catch(
                                                            console.warn)
                                                return ""
                                            }
                                            imageSource: plant.images_plantes.length > 0 ? "https://blume.mahoudev.com/assets/" + plant.images_plantes[0].directus_files_id : ""
                                            onClicked: {
                                                plantScreenDetailsLoader.active = true
                                                plantScreenDetailsLoader.item.loadPlantDetails(
                                                            plant)
                                            }
                                        }
                                    }
                                }

                                Item {
                                    SearchPlants {
                                        anchors.fill: parent
                                        anchors.topMargin: plantBrowserAppBar.height
                                        preventDefaultOnClick: true
                                        hideCameraSearch: true
                                        onItemClicked: plantData => {
                                                           plantScreenDetailsLoader.active = true
                                                           plantScreenDetailsLoader.item.loadPlantDetails(
                                                               plantData)
                                                           console.log(
                                                               currentDevice.deviceAddress)
                                                       }
                                    }
                                }
                            }

                            Loader {
                                id: plantScreenDetailsLoader
                                active: false
                                sourceComponent: PlantScreenDetails {
                                    id: plantScreenDetailsPopup

                                    function loadPlantDetails(data) {
                                        plantScreenDetailsPopup.plant = data
                                        plantScreenDetailsPopup.open()
                                    }

                                    RowLayout {
                                        id: bottomSelector
                                        width: parent.width
                                        height: 60
                                        anchors.bottom: parent.bottom
                                        spacing: 0

                                        ButtonWireframe {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height
                                            text: qsTr("Cancel")
                                            componentRadius: 0
                                            onClicked: {
                                                plantScreenDetailsPopup.close()
                                                plantScreenDetailsPopup.plant = null
                                            }
                                        }

                                        ButtonWireframe {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height
                                            fullColor: true
                                            primaryColor: Theme.colorPrimary
                                            fulltextColor: "white"
                                            componentRadius: 0
                                            text: qsTr("Choose this plant")

                                            function save(plant, space) {
                                                console.log("\n\n\n function save ",
                                                            plant, space)
                                                $Model.device.sqlGetByDeviceAddress(
                                                            currentDevice.deviceAddress).then(
                                                            function (rs) {
                                                                if (rs) {
                                                                    console.log("\n\n IN update -------------------- ", plant.id, space.id)
                                                                    $Model.device.sqlUpdateByDeviceAddress(currentDevice.deviceAddress, {
                                                                                                               "plant_id": plant.id,
                                                                                                               "space_id": space.id,
                                                                                                               "space_name": space.libelle,
                                                                                                               "plant_name": plantScreenDetailsPopup.plant.name_scientific,
                                                                                                               "plant_json": JSON.stringify(plantScreenDetailsPopup.plant)
                                                                                                           }).then(function (res) {
                                                                                                               plantScreenDetailsPopup.close()
                                                                                                               plantBrowserPop.close()
                                                                                                           }).catch(err => console.warn(JSON.stringify(err)))
                                                                } else {
                                                                    console.log("\n\n IN create -------------------- ", plant.id, space.id)
                                                                    $Model.device.sqlCreate({
                                                                                                "device_address": currentDevice.deviceAddress,
                                                                                                "plant_id": plant.id,
                                                                                                "space_id": space.id,
                                                                                                "space_name": space.libelle,
                                                                                                "plant_name": plantScreenDetailsPopup.plant.name_scientific,
                                                                                                "plant_json": JSON.stringify(plantScreenDetailsPopup.plant)
                                                                                            }).then(
                                                                                function (res) {
                                                                                    plantScreenDetailsPopup.close()
                                                                                    plantBrowserPop.close()
                                                                                }).catch(
                                                                                err => console.warn(
                                                                                    JSON.stringify(
                                                                                        err)))
                                                                }
                                                            })
                                            }

                                            onClicked: {
                                                $Model.plant.sqlGetWhere({
                                                                             "remote_id": `${plantScreenDetailsPopup.plant.id}`
                                                                         }).then(
                                                            function (res) {
                                                                console.log("\n My RES ",
                                                                            res)
                                                                if (res?.length > 1) {
                                                                    console.log("\n\n // This plant already has one Room")
                                                                    plantScreenDetailsPopup.selectGardenSpace(save)
                                                                    console.log("\n end")
                                                                } else {
                                                                    console.log("\n gonna add to garden")
                                                                    plantScreenDetailsPopup.addToGarden(save)
                                                                }
                                                            }).catch(
                                                            function (err) {
                                                                console.warn(JSON.stringify(err))
                                                            })
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ButtonWireframe {
                            text: "Attach a plant"
                            anchors.centerIn: parent
                            fullColor: true
                            primaryColor: Theme.colorPrimary
                            fulltextColor: "white"
                            height: 45
                            componentRadius: height / 2

                            onClicked: {
                                plantBrowserPop.open()
                            }
                        }
                    }

                    Item {
                        height: 50
                    }
                }
            }

            ////////
            Item {
                id: itemIndicators
                height: Math.max(itemHeader.height, indicatorsLoader.height)
                width: (parent.columns === 1) ? parent.width : (parent.width * 0.64)
                visible: linkedPlant !== undefined

                Loader {
                    id: indicatorsLoader
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width

                    asynchronous: false
                    onLoaded: {
                        dataIndicators.loadIndicators()
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////
        Item {
            width: (contentGrid_lvl1.width / contentGrid_lvl1.columns)
            height: {
                if (contentGrid_lvl1.columns === 1)
                    return (contentGrid_lvl1.height - contentGrid_lvl1.spacing
                            - contentGrid_lvl2.height)
                else
                    return contentGrid_lvl1.height
            }
            clip: true
            visible: false

            ItemNoData {
                id: noDataIndicator
                visible: false
            }

            ItemLoadData {
                id: loadingIndicator
                visible: !noDataIndicator.visible
            }

            Loader {
                id: graphLoader
                anchors.fill: parent

                opacity: 0
                Behavior on opacity {
                    OpacityAnimator {
                        duration: (graphLoader.status === Loader.Ready) ? 200 : 0
                    }
                }

                asynchronous: true
                onLoaded: {
                    dataChart.loadGraph()
                    dataChart.updateGraph()

                    graphLoader.opacity = 1
                    noDataIndicator.visible = (currentDevice.countDataNamed(
                                                   "temperature",
                                                   dataChart.daysVisible) <= 1)
                }
            }
        }
    }
}
