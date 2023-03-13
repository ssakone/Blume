import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtSensors
import SortFilterProxyModel
import QtMultimedia
import ImageTools

import ThemeEngine 1.0

Item {
    id: screenDeviceList
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: {
        checkStatus()
        loadList()
    }

    function backAction() {
        if (isSelected()) exitSelectionMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    property bool splitView: settingsManager.splitView
    property bool deviceAvailable: deviceManager.hasDevices
    property bool bluetoothAvailable: deviceManager.bluetooth
    property bool bluetoothPermissionsAvailable: deviceManager.bluetoothPermissions

    onBluetoothAvailableChanged: checkStatus()
    onBluetoothPermissionsAvailableChanged: checkStatus()
    onDeviceAvailableChanged: { checkStatus(); exitSelectionMode(); }
    onSplitViewChanged: loadList()

    function loadList() {
        exitSelectionMode()

        if (splitView) {
            loaderDeviceList.source = "DeviceListSplit.qml"
        } else {
            loaderDeviceList.source = "DeviceListUnified.qml"
        }

        selectionCount = Qt.binding(function() { return loaderDeviceList.item.selectionCount })
    }

    function checkStatus() {
        if (!utilsApp.checkMobileBleLocationPermission()) {
            //utilsApp.getMobileBleLocationPermission()
        }

        if (deviceManager.hasDevices) {
            // The sensor list is shown
            loaderStatus.source = ""

            if (!deviceManager.bluetooth) {
                rectangleBluetoothStatus.setBluetoothWarning()
            } else if (!deviceManager.bluetoothPermissions) {
                rectangleBluetoothStatus.setPermissionWarning()
            } else {
                rectangleBluetoothStatus.hide()
            }
        } else {
            // The sensor list is not populated
            rectangleBluetoothStatus.hide()

            if (!deviceManager.bluetooth) {
                loaderStatus.source = "ItemNoBluetooth.qml"
            } else {
                loaderStatus.source = "ItemNoDevice.qml"
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    property int selectionCount: 0

    function isSelected() {
        if (loaderDeviceList.status !== Loader.Ready) return false
        return loaderDeviceList.item.isSelected()
    }
    function exitSelectionMode() {
        if (loaderDeviceList.status !== Loader.Ready) return
        loaderDeviceList.item.exitSelectionMode()
    }

    function updateSelectedDevice() {
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                deviceManager.updateDevice(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function syncSelectedDevice() {
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                deviceManager.syncDevice(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        exitSelectionMode()
    }
    function removeSelectedDevice() {
        var devicesAddr = []
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (deviceManager.getDeviceByProxyIndex(i).selected) {
                devicesAddr.push(deviceManager.getDeviceByProxyIndex(i).deviceAddress)
            }
        }
        for (var count = 0; count < devicesAddr.length; count++) {
            deviceManager.removeDevice(devicesAddr[count])
        }
        exitSelectionMode()
    }

    PopupDeleteDevice {
        id: confirmDeleteDevice
        onConfirmed: removeSelectedDevice()
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: rowbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 2

        ////////////////

        Rectangle {
            id: rectangleBluetoothStatus
            anchors.left: parent.left
            anchors.right: parent.right

            height: 0
            Behavior on height { NumberAnimation { duration: 133 } }

            clip: true
            visible: (height > 0)
            color: Theme.colorActionbar

            // prevent clicks below this area
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

            Text {
                id: textBluetoothStatus
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                color: Theme.colorActionbarContent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.bold: isDesktop ? true : false
                font.pixelSize: Theme.fontSizeComponent
            }

            ButtonWireframe {
                id: buttonBluetoothStatus
                height: 32
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                fullColor: true
                primaryColor: Theme.colorActionbarHighlight

                text: {
                    if (Qt.platform.os === "android") {
                        if (!deviceManager.bluetoothEnabled) return qsTr("Enable")
                        else if (!deviceManager.bluetoothPermissions) return qsTr("About")
                    }
                    return qsTr("Retry")
                }
                onClicked: {
                    if (Qt.platform.os === "android" && !deviceManager.bluetoothPermissions) {
                        //utilsApp.getMobileBleLocationPermission()
                        //deviceManager.checkBluetoothPermissions()

                        // someone clicked 'never ask again'?
                        screenPermissions.loadScreenFrom("DeviceList")
                    } else {
                        deviceManager.enableBluetooth(settingsManager.bluetoothControl)
                    }
                }
            }

            function hide() {
                rectangleBluetoothStatus.height = 0
            }
            function setBluetoothWarning() {
                textBluetoothStatus.text = qsTr("Bluetooth is disabled...")
                rectangleBluetoothStatus.height = 48
            }
            function setPermissionWarning() {
                textBluetoothStatus.text = qsTr("Bluetooth permission is missing...")
                rectangleBluetoothStatus.height = 48
            }
        }

        ////////////////

        Rectangle {
            id: rectangleActions
            anchors.left: parent.left
            anchors.right: parent.right

            height: (screenDeviceList.selectionCount) ? 48 : 0
            Behavior on height { NumberAnimation { duration: 133 } }

            clip: true
            visible: (height > 0)
            color: Theme.colorActionbar

            // prevent clicks below this area
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                RoundButtonIcon {
                    id: buttonClear
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-backspace-24px.svg"
                    rotation: 180
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: screenDeviceList.exitSelectionMode()
                }

                Text {
                    id: textActions
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("%n device(s) selected", "", screenDeviceList.selectionCount)
                    color: Theme.colorActionbarContent
                    font.bold: true
                    font.pixelSize: Theme.fontSizeComponent
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ButtonCompactable {
                    id: buttonDelete
                    height: compact ? 36 : 34
                    anchors.verticalCenter: parent.verticalCenter

                    compact: !wideMode
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: confirmDeleteDevice.open()

                    text: qsTr("Delete")
                    source: "qrc:/assets/icons_material/baseline-delete-24px.svg"
                }

                ButtonCompactable {
                    id: buttonSync
                    height: !wideMode ? 36 : 34
                    anchors.verticalCenter: parent.verticalCenter
                    visible: deviceManager.bluetooth

                    compact: !wideMode
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: screenDeviceList.syncSelectedDevice()

                    text: qsTr("Synchronize history")
                    source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                }

                ButtonCompactable {
                    id: buttonRefresh
                    height: !wideMode ? 36 : 34
                    anchors.verticalCenter: parent.verticalCenter
                    visible: deviceManager.bluetooth

                    compact: !wideMode
                    iconColor: Theme.colorActionbarContent
                    backgroundColor: Theme.colorActionbarHighlight
                    onClicked: screenDeviceList.updateSelectedDevice()

                    text: qsTr("Refresh")
                    source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: loaderStatus
        anchors.fill: parent
        asynchronous: true
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: loaderDeviceList
        anchors.fill: parent
        anchors.topMargin: rowbar.height
        asynchronous: false
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12

        active: isDesktop
        asynchronous: true

        sourceComponent: Row {
            spacing: 12

            ButtonWireframe {
                text: qsTr("devices")
                fullColor: true
                primaryColor: Theme.colorSecondary
                onClicked: screenDeviceBrowser.loadScreen()
                enabled: (deviceManager.bluetooth && deviceManager.bluetoothPermissions)
            }
            ButtonWireframe {
                text: qsTr("plants")
                fullColor: true
                primaryColor: Theme.colorPrimary
                onClicked: screenPlantBrowser.loadScreenFrom("DeviceList")
            }
            ButtonWireframe {
                text: qsTr("desease")
                fullColor: true
                primaryColor: Theme.colorPrimary
                onClicked: desease.open()
            }
        }
    }

    Popup {
        id: desease
        property variant analyseResults
        width: appWindow.width
        height: appWindow.height
        parent: appWindow.contentItem
        padding: 0
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            Rectangle {
                color: "#00c395"
                Layout.preferredHeight: 65
                Layout.fillWidth: true
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
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
                                if (identifierLayoutView.currentIndex === 0) {
                                    desease.close()
                                } else {
                                    identifierLayoutView.currentIndex--
                                }
                            }
                        }

                        Behavior on opacity { OpacityAnimator { duration: 333 } }
                    }
                    Label {
                        text: identifierLayoutView.currentIndex === 0 ? "Etat de la plante" : "Resultat"
                        font.pixelSize: 21
                        font.bold: true
                        font.weight: Font.Medium
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            StackLayout {
                id: identifierLayoutView
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 10
                currentIndex: 0
                Item {
                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.fill: parent
                        spacing: 10

                        Item {
                            id: imgAnalysisSurface
                            property bool loading: false
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Rectangle {
                                anchors.fill: parent
                                border.width: 1
                                border.color: '#ccc'
                                opacity: .3
                            }
                            Column {
                                visible: image.source.toString() === ""
                                anchors.centerIn: parent
                                spacing: 10
                                IconSvg {
                                    width: 64
                                    height: 64
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    source: "qrc:/assets/icons_custom/plant_scan.png"
                                    color: 'black'
                                }
                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 140
                                    wrapMode: Label.Wrap
                                    font.pixelSize: 16
                                    horizontalAlignment: Label.AlignHCenter
                                    text: 'Clickez pour importer une image'
                                    opacity: .6
                                }
                            }

                            Image {
                                 id: image
                                 anchors.fill: parent
                                 fillMode: Image.PreserveAspectFit
                             }

                            BusyIndicator {
                                running: parent.loading
                                anchors.centerIn: parent
                            }

                            FileDialog {
                                id: fileDialog
                                nameFilters: ["Image file (*.png *.jpg *.jpeg *.gif)"]
                                onAccepted: image.source = selectedFile
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: fileDialog.open()
                            }
                        }

                        ButtonWireframe {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Analyser"
                            Layout.preferredWidth: 180
                            Layout.preferredHeight: 45
                            visible: image.source.toString() !== ""
                            onClicked: {
                                imgAnalysisSurface.loading = true
                                let data = {
                                    "images": [
                                        imgTool.getBase64(image.source.toString().replace("file://", ""))
                                    ]
                                }
                                request("POST", "https://plant.id/api/v2/health_assessment", data).then(function (r) {
                                    let datas = JSON.parse(r)
                                    console.log(r)
                                    desease.analyseResults = datas
                                    imgAnalysisSurface.loading = false
                                    identifierLayoutView.currentIndex = 1
                                    if (datas.is_plant) {
                                        identifedPlantListView.model = datas.health_assessment.diseases
                                    }

                                }).catch(function (e) {
                                    imgAnalysisSurface.loading = false
                                    console.log(JSON.stringify(e))
                                })
                            }
                        }
                        Image2Base64 {
                            id: imgTool
                        }

                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10
                            ButtonWireframe {
                                text: "Charger une image"
                                width: 180
                                height: 45
                                onClicked: fileDialog.open()
                            }
                            ButtonWireframe {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Fermer"
                                width: 120
                                height: 45
                                onClicked: desease.close()
                            }
                        }
                    }
                }
                Item {
                    ListView {
                        id: identifedPlantListView
                        anchors.fill: parent
                        model: 0
                        spacing: 5
                        clip: true
                        header: Column {
                            width: identifedPlantListView.width
                            padding: 10
                            spacing: 3
                            Label {
                                font.pixelSize: 28
                                width: 300
                                wrapMode: Label.Wrap
                                horizontalAlignment: Label.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                verticalAlignment: Qt.AlignVCenter
                                visible: desease.analyseResults?.is_plant
                                text: "Plante en bonne sante <b><font color='%1'>%2</font></b>".arg(desease.analyseResults?.health_assessment.is_healthy_probability > 0.8 ? "green" : "red").arg(desease.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "Oui" : "Non")
                            }
                            Label {
                                font.pixelSize: 28
                                width: 300
                                wrapMode: Label.Wrap
                                horizontalAlignment: Label.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                verticalAlignment: Qt.AlignVCenter
                                visible: !desease.analyseResults?.is_plant
                                text: "Ceci n'est pas une plante"
                            }
                        }

                        delegate: ItemDelegate {
                            text: modelData["name"]
                            height: 60
                            width: identifedPlantListView.width
                            Rectangle {
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                color: "teal"
                                radius: width / 2
                                width: 50
                                height: width
                                Label {
                                    anchors.centerIn: parent
                                    text: "%1%".arg((modelData["probability"]*100).toFixed(0))
                                    color: "white"
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    function fetch(opts) {
        return new Promise(function (resolve, reject) {
            var xhr = new XMLHttpRequest()
            xhr.onload = function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status == 200 || xhr.status == 201) {
                        var res = xhr.responseText.toString()
                        resolve(res)
                    } else {
                        let r = {
                            "status": xhr.status,
                            "statusText": xhr.statusText,
                            "content": xhr.responseText
                        }
                        reject(r)
                    }
                } else {
                    let r = {
                        "status": xhr.status,
                        "statusText": xhr.statusText,
                        "content": xhr.responseText
                    }
                    reject(r)
                }
            }
            xhr.onerror = function() {
                let r = {
                    "status": xhr.status,
                    "statusText": 'NO CONNECTION, ' + xhr.statusText
                }
                reject(r)
            }

            xhr.open(opts.method ? opts.method : 'GET', opts.url, true)

            if (opts.headers) {
                Object.keys(opts.headers).forEach(function (key) {
                    xhr.setRequestHeader(key, opts.headers[key])
                })
            }

            let obj = opts.params

            var data = obj ? JSON.stringify(obj) : ''

            xhr.send(data)
        })
    }

    function request(method, url, params) {
        let query = {
            "method": method,
            "url": url,
            "headers": {
                "Accept": 'application/json',
                "Api-Key": "aryQrOSbo6YrsMQGRx5VRpc1dOazmjDxO23jeitWxX43V7b3Xq",
                "Content-Type": 'application/json'
            },
            "params": params ?? null
        }
        return fetch(query)
    }
    ////////////////////////////////////////////////////////////////////////////
}
