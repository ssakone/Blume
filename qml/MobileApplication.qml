import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

import ThemeEngine 1.0
import MobileUI 1.0
import QtAndroidTools

import "pages/Plant/"
import "pages/Garden"
import "pages/Auth"
import "pages"
import "services/"
import "models/"
import "components/"
import "components_js/"
import "components_js/Http.js" as HTTP

ApplicationWindow {
    id: appWindow
    minimumWidth: 480
    minimumHeight: 960

    flags: (Qt.platform.os === "android") ? Qt.Window : Qt.Window
                                            | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true
    property alias $SqlClient: _relay._sqliClient
    property alias $Model: _relay
    property alias $Signaler: _signaler
    property alias $Colors: _relay._colors
    property var $Http: HTTP
    property alias $Constants: __constants__

    readonly property var permissionsNameList: ["android.permission.READ_MEDIA_IMAGES", "android.permission.READ_EXTERNAL_STORAGE", "android.permission.CAMERA", "android.permission.INTERNET", "android.permission.WRITE_EXTERNAL_STORAGE", "android.permission.BLUETOOTH_ADMIN", "android.permission.BLUETOOTH"]
    Loader {
        active: Qt.platform.os === "android"
        sourceComponent: Component {
            Item {
                Connections {
                    target: QtAndroidAppPermissions
                    function onRequestPermissionsResults(results) {
                        for (var i = 0; i < results.length; i++) {
                            if (results[i].granted === true) {
                                console.log(results[i].name, true)
                            } else {
                                if (QtAndroidAppPermissions.shouldShowRequestPermissionInfo(
                                            results[i].name) !== true) {
                                    console.log(results[i].name, false)
                                }
                            }
                        }
                    }
                }
                Component.onCompleted: QtAndroidAppPermissions.requestPermissions(
                                           permissionsNameList)
            }
        }
    }

    property bool isHdpi: (utilsScreen.screenDpi > 128)
    property bool isDesktop: (Qt.platform.os !== "ios"
                              && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios"
                             || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios"
                             || Qt.platform.os === "android")
                            && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios"
                              || Qt.platform.os === "android")
                             && (utilsScreen.screenSize >= 7.0))

    property var selectedDevice: null

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt.PortraitOrientation, 2 = Qt.LandscapeOrientation
    // 4 = Qt.InvertedPortraitOrientation, 8 = Qt.InvertedLandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation
    onScreenOrientationChanged: handleNotchesTimer.restart()

    property int screenPaddingStatusbar: 0
    property int screenPaddingNotch: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    ModelManager {
        id: _relay
    }

    Signaler {
        id: _signaler
    }

    Constants {
        id: __constants__
    }

    Timer {
        id: handleNotchesTimer
        interval: 33
        repeat: false
        onTriggered: handleNotches()
    }

    function handleNotches() {


        /*
        console.log("handleNotches()")
        console.log("screen width : " + Screen.width)
        console.log("screen width avail : " + Screen.desktopAvailableWidth)
        console.log("screen height: " + Screen.height)
        console.log("screen height avail: " + Screen.desktopAvailableHeight)
        console.log("screen orientation: " + Screen.orientation)
        console.log("screen orientation (primary): " + Screen.primaryOrientation)
*/
        if (Qt.platform.os !== "ios")
            return
        if (typeof quickWindow === "undefined" || !quickWindow) {
            handleNotchesTimer.restart()
            return
        }

        // Margins
        var safeMargins = utilsScreen.getSafeAreaMargins(quickWindow)
        if (safeMargins["total"] === safeMargins["top"]) {
            screenPaddingStatusbar = safeMargins["top"]
            screenPaddingNotch = 0
            screenPaddingLeft = 0
            screenPaddingRight = 0
            screenPaddingBottom = 0
        } else if (safeMargins["total"] > 0) {
            if (Screen.orientation === Qt.PortraitOrientation) {
                screenPaddingStatusbar = 20
                screenPaddingNotch = 12
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 6
            } else if (Screen.orientation === Qt.InvertedPortraitOrientation) {
                screenPaddingStatusbar = 12
                screenPaddingNotch = 20
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 6
            } else if (Screen.orientation === Qt.LandscapeOrientation) {
                screenPaddingStatusbar = 0
                screenPaddingNotch = 0
                screenPaddingLeft = 32
                screenPaddingRight = 0
                screenPaddingBottom = 0
            } else if (Screen.orientation === Qt.InvertedLandscapeOrientation) {
                screenPaddingStatusbar = 0
                screenPaddingNotch = 0
                screenPaddingLeft = 0
                screenPaddingRight = 32
                screenPaddingBottom = 0
            } else {
                screenPaddingStatusbar = 0
                screenPaddingNotch = 0
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 0
            }
        } else {
            screenPaddingStatusbar = 0
            screenPaddingNotch = 0
            screenPaddingLeft = 0
            screenPaddingRight = 0
            screenPaddingBottom = 0
        }


        /*
        console.log("total:" + safeMargins["total"])
        console.log("top:" + safeMargins["top"])
        console.log("left:" + safeMargins["left"])
        console.log("right:" + safeMargins["right"])
        console.log("bottom:" + safeMargins["bottom"])

        console.log("RECAP screenPaddingStatusbar:" + screenPaddingStatusbar)
        console.log("RECAP screenPaddingNotch:" + screenPaddingNotch)
        console.log("RECAP screenPaddingLeft:" + screenPaddingLeft)
        console.log("RECAP screenPaddingRight:" + screenPaddingRight)
        console.log("RECAP screenPaddingBottom:" + screenPaddingBottom)
*/
    }

    MobileUI {
        id: mobileUI
        property bool isLoading: true

        statusbarTheme: Theme.themeStatusbar
        statusbarColor: isLoading ? "white" : Theme.colorStatusbar
        navbarColor: {
            if (isLoading)
                return "white"
            if (appContent.state === "Tutorial"
                    || appContent.state === "DeviceList")
                return Theme.colorHeader
            return Theme.colorBackground
        }
    }

    MobileHeader {
        id: appHeader
        width: appWindow.width
        anchors.top: appWindow.top
    }

    MobileDrawer {
        id: appDrawer
        width: (appWindow.screenOrientation === Qt.PortraitOrientation
                || appWindow.width < 480) ? 0.8 * appWindow.width : 0.5 * appWindow.width
        height: appWindow.height
        interactive: (appContent.state !== "Tutorial")
    }

    // Events handling /////////////////////////////////////////////////////////
    Component.onCompleted: {
        handleNotchesTimer.restart()
        mobileUI.isLoading = false
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
            xhr.onerror = function () {
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

    Connections {
        target: ThemeEngine
        function onCurrentThemeChanged() {
            mobileUI.statusbarTheme = Theme.themeStatusbar
        }
    }

    Connections {
        target: appHeader
        function onLeftMenuClicked() {
            console.log("\n\n Menu clicked " + appContent.state + "\n\n")
            if (appContent.state === "DeviceList") {
                appDrawer.open()
            } else {
                if (appContent.state === "Tutorial")
                    appContent.state = screenTutorial.entryPoint
                else if (appContent.state === "PlantBrowser")
                    appContent.state = screenPlantBrowser.entryPoint
                else if (appContent.state === "About"
                         || appContent.state === "Settings") {
                    appContent.state = "Navigator"
                    appDrawer.open()
                } else {
                    appContent.state = "Navigator"
                }
            }
        }
        function onRightMenuClicked() {}

        function onDeviceLedButtonClicked() {
            if (selectedDevice) {
                selectedDevice.actionLedBlink()
            }
        }
        function onDeviceWateringButtonClicked() {
            if (selectedDevice) {
                selectedDevice.actionWatering()
            }
        }
        function onDeviceCalibrateButtonClicked() {
            if (selectedDevice) {
                popupCalibration.open()
            }
        }
        function onDeviceRebootButtonClicked() {
            if (selectedDevice) {
                selectedDevice.actionReboot()
            }
        }

        function onDeviceClearButtonClicked() {
            if (selectedDevice) {
                popupDeleteData.open()
            }
        }
        function onDeviceRefreshHistoryButtonClicked() {
            if (selectedDevice) {
                selectedDevice.refreshStartHistory()
            }
        }

        function onDeviceRefreshRealtimeButtonClicked() {
            if (selectedDevice) {
                selectedDevice.refreshStartRealtime()
            }
        }
        function onDeviceRefreshButtonClicked() {
            if (selectedDevice) {
                deviceManager.updateDevice(selectedDevice.deviceAddress)
            }
        }
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            switch (Qt.application.state) {
            case Qt.ApplicationSuspended:
                //console.log("Qt.ApplicationSuspended")
                deviceManager.refreshDevices_stop()
                break
            case Qt.ApplicationHidden:
                //console.log("Qt.ApplicationHidden")
                deviceManager.refreshDevices_stop()
                break
            case Qt.ApplicationInactive:
                //console.log("Qt.ApplicationInactive")
                break
            case Qt.ApplicationActive:
                //console.log("Qt.ApplicationActive")

                // Check if we need an 'automatic' theme change
                Theme.loadTheme(settingsManager.appTheme)

                if (appContent.state === "DeviceBrowser") {
                    // Restart the device browser
                    deviceManager.scanNearby_start()
                } else {
                    // Listen for nearby devices
                    deviceManager.refreshDevices_listen()
                }

                break
            }
        }
    }

    Timer {
        id: exitTimer
        interval: 3333
        running: false
        repeat: false
        onRunningChanged: exitWarning.opacity = running
    }

    // UI sizes ////////////////////////////////////////////////////////////////
    property bool headerUnicolor: (Theme.colorHeader === Theme.colorBackground)

    property bool singleColumn: {
        if (isMobile) {
            if ((isPhone && screenOrientation === Qt.PortraitOrientation)
                    || (isTablet && width < 512)) {
                // can be a 2/3 split screen on tablet
                return true
            } else {
                return false
            }
        } else {
            return (appWindow.width < appWindow.height)
        }
    }

    property bool wideMode: (isDesktop && width >= 560) || (isTablet
                                                            && width >= 480)
    property bool wideWideMode: (width >= 640)

    // QML /////////////////////////////////////////////////////////////////////
    PopupCalibration {
        id: popupCalibration
    }
    PopupDeleteData {
        id: popupDeleteData
    }

    FocusScope {
        id: appContent
        anchors.top: appHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        focus: true
        Keys.onBackPressed: {
            console.log("CAPTURE BACK PRESS ", appContent.state)
            if (appContent.state === "Tutorial"
                    && screenTutorial.entryPoint === "DeviceList") {
                // do nothing
                return
            }

            if (appHeader.rightMenuIsOpen()) {
                appHeader.rightMenuClose()
                return
            }

            if (appContent.state === "DeviceList") {
                if (screenDeviceList.isSelected()) {
                    console.log()
                    //                    screenDeviceList.exitSelectionMode()
                } else {
                    if (exitTimer.running)
                        Qt.quit()
                    else
                        exitTimer.start()
                }
            } else if (appContent.state === "DevicePlantSensor") {
                screenDevicePlantSensor.backAction()
            } else if (appContent.state === "DeviceThermometer") {
                screenDeviceThermometer.backAction()
            } else if (appContent.state === "DeviceEnvironmental") {
                screenDeviceEnvironmental.backAction()
            } else if (appContent.state === "Permissions") {
                appContent.state = screenPermissions.entryPoint
            } else if (appContent.state === "Tutorial") {
                appContent.state = screenTutorial.entryPoint
            } else if (appContent.state === "PlantBrowser") {
                screenPlantBrowser.backAction()
            } else if (appContent.state === "Navigator") {
                if (page_view.depth === 1) {
                    if (exitTimer.running)
                        Qt.quit()
                    else
                        exitTimer.start()
                } else
                    page_view.pop()
            } else
                appHeader.leftMenuClicked()
        }

        function openStackView(page) {
            //            if (state !== "Navigator")
            //                page_view.previousState = state
            state = "Navigator"
            page_view.push(page, {}, StackView.Immediate)
        }

        NavigationPage {
            id: navigator
        }

        Component {
            id: plantIdentifier
            PlantIdentifier {}
        }

        Component {
            id: desease
            PlantDesease {}
        }

        Component {
            id: plantBrowserPage
            PlantBrowser {}
        }

        Component {
            id: plantScreen
            PlantScreen {}
        }

        Component {
            id: loginPage
            Login {}
        }

        ColumnLayout {
            y: -appHeader.height
            width: parent.width
            height: parent.height + appHeader.height
            spacing: 0
            StackView {
                id: page_view
                property string previousState: ""

                Layout.fillHeight: true
                Layout.fillWidth: true
                initialItem: Component {
//                    GardenScreen {}
                    TutorialNew {}
                }

                onDepthChanged: {

                    //                if (depth === 1)
                    //                    parent.state = previousState
                }
            }
            BottomTabBar {
                Layout.fillWidth: true
                visible: appContent.state === "Navigator"
                         && ["Health", "Garden", "DeviceList", "Plants", "Feed"].indexOf(
                             activePage) !== -1
                activePage: page_view.currentItem.objectName
            }
        }

        Tutorial {
            anchors.fill: parent
            id: screenTutorial
        }

        //        DeviceList {
        //            id: screenDeviceList
        //        }
        DevicePlantSensor {
            id: screenDevicePlantSensor
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceThermometer {
            id: screenDeviceThermometer
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceEnvironmental {
            id: screenDeviceEnvironmental
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        Settings {
            id: screenSettings
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        MobilePermissions {
            id: screenPermissions
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        About {
            id: screenAbout
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }

        PlantBrowserOld {
            id: screenPlantBrowser
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }
        DeviceBrowser {
            id: screenDeviceBrowser
            anchors.fill: parent
            anchors.bottomMargin: mobileMenu.hhv
        }

        // Start on the tutorial?
        Component.onCompleted: {
            if (!deviceManager.areDevicesAvailable()) {

                //                screenTutorial.loadScreen()
            }
        }

        // Initial state
        state: "Navigator"

        onStateChanged: {

            //            screenDeviceList.exitSelectionMode()
            if (state === "DeviceList")
                appHeader.leftMenuMode = "drawer"
            else if (state === "Tutorial")
                appHeader.leftMenuMode = "close"
            else
                appHeader.leftMenuMode = "back"
        }

        states: [
            State {
                name: "Navigator"
                PropertyChanges {
                    target: appHeader
                    visible: false
                }
                PropertyChanges {
                    target: page_view
                    visible: true
                    enabled: true
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "Tutorial"
                PropertyChanges {
                    target: screenTutorial
                    visible: true
                    enabled: true
                    focus: true
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceList"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                    enabled: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: true
                //                    enabled: true
                //                    focus: true
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DevicePlantSensor"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: true
                    enabled: true
                    focus: true
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceThermometer"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: true
                    enabled: true
                    focus: true
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceEnvironmental"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: true
                    enabled: true
                    focus: true
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "Settings"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: true
                    enabled: true
                    focus: true
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "About"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: true
                    enabled: true
                    focus: true
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "PlantBrowser"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: true
                    enabled: true
                    focus: true
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: false
                    enabled: false
                }
            },
            State {
                name: "DeviceBrowser"
                PropertyChanges {
                    target: screenTutorial
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: appHeader
                    visible: true
                }
                PropertyChanges {
                    target: page_view
                    visible: false
                    enabled: false
                }
                //                PropertyChanges {
                //                    target: screenDeviceList
                //                    visible: false
                //                    enabled: false
                //                }
                PropertyChanges {
                    target: screenDevicePlantSensor
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceThermometer
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceEnvironmental
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenSettings
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPermissions
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenAbout
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenPlantBrowser
                    visible: false
                    enabled: false
                }
                PropertyChanges {
                    target: screenDeviceBrowser
                    visible: true
                    enabled: true
                    focus: true
                }
            }
        ]
    }

    ////////////////
    MobileMenu {
        id: mobileMenu
    }

    ////////////////
    Rectangle {
        id: exitWarning

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12

        height: 40
        radius: 4

        color: Theme.colorComponentBackground
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth

        opacity: 0
        Behavior on opacity {
            OpacityAnimator {
                duration: 233
            }
        }

        Text {
            anchors.centerIn: parent
            text: qsTr("Press one more time to exit...")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
        }
    }
}
