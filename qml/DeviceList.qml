import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtSensors
import SortFilterProxyModel
import QtMultimedia
import ImageTools
import "components"

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
            popupLocationNotification.open()
            // utilsApp.getMobileBleLocationPermission()
        }

        if (deviceManager.hasDevices) {
            // The sensor list is shown
            loaderStatus.source = ""
            loaderStatus.visible = false
            loaderDeviceList.visible = true

            if (!deviceManager.bluetooth) {
                rectangleBluetoothStatus.setBluetoothWarning()
            } else if (!deviceManager.bluetoothPermissions) {
                rectangleBluetoothStatus.setPermissionWarning()
            } else {
                rectangleBluetoothStatus.hide()
            }
        } else {
            // The sensor list is not populated
            loaderStatus.visible = true
            loaderDeviceList.visible = false
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

    PopupLocationNotification {
        id: popupLocationNotification
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

    Timer {
        id: retryScan
        interval: 333
        running: false
        repeat: false
        onTriggered: scan()
    }

    RoundButton {
        visible: deviceManager.hasDevices
        icon.source: Icons.plusThick
        icon.width: 32
        icon.height: 32
        width: Qt.platform.os === "android" ? 90 : 70
        height: Qt.platform.os === "android" ? 90 : 70
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 90
        palette.button: Theme.colorPrimary
        palette.buttonText: "white"
        Material.elevation: 0
        Material.background: Theme.colorPrimary
        Material.foreground: Material.color(Material.Grey, Material.Shade50)
        onClicked: {
            if (utilsApp.checkMobileBleLocationPermission()) {
                scan()
            } else {
                utilsApp.getMobileBleLocationPermission()
                retryScan.start()
            }
        }
        enabled: (deviceManager.bluetooth && deviceManager.bluetoothPermissions)
    }

    Loader {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: parent.width

        asynchronous: true

        sourceComponent: RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter

            ButtonWireframe {
                Layout.preferredHeight: 70
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                Column {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    ColorImage {
                        source: "qrc:/assets/icons_material/outline-local_florist-24px.svg"
                        width: 32
                        height: 32
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        text: qsTr("Plantes")
                    }
                }

                componentRadius: 0
                fullColor: true
                primaryColor: Theme.colorPrimary
                onClicked: screenPlantBrowser.loadScreenFrom("DeviceList")
            }

//            ButtonWireframe {
//                Layout.preferredHeight: 70
//                Layout.alignment: Qt.AlignVCenter
//                Layout.fillWidth: true
//                Layout.preferredWidth: screenDeviceList.width / 3

//                Rectangle {
//                    y: 0.8
//                    width: parent.width
//                    height: 4
//                    radius: 2
//                }

//                Column {
//                    width: parent.width
//                    anchors.verticalCenter: parent.verticalCenter
//                    ColorImage {
//                        source: Icons.devices
//                        width: 32
//                        height: 32
//                        color: "white"
//                        anchors.horizontalCenter: parent.horizontalCenter
//                    }
//                }

//                componentRadius: 0
//                fullColor: true
//                primaryColor: Theme.colorPrimary
//                onClicked: screenDeviceBrowser.loadScreen()
//                enabled: (deviceManager.bluetooth && deviceManager.bluetoothPermissions)
//            }

            ButtonWireframe {
                Layout.preferredHeight: 70
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                Column {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    ColorImage {
                        source: Icons.sproutOutline
                        width: 32
                        height: 32
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Santé")
                        color: "white"
                    }
                }

                componentRadius: 0
                fullColor: true
                primaryColor: Theme.colorPrimary
                onClicked: desease.open()
            }
        }
    }

    PlantDesease {
        id: desease
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

    function scan() {
        if (!deviceManager.updating) {
            if (deviceManager.scanning) {
                deviceManager.scanDevices_stop()
            } else {
                deviceManager.scanDevices_start()
            }
        } else console.warn("deviceManager.updating")
    }
}
