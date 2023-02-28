import QtQuick

import ThemeEngine 1.0

Item {
    id: itemNoDevice
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    Timer {
        id: retryScan
        interval: 333
        running: false
        repeat: false
        onTriggered: scan()
    }

    function scan() {
        if (!deviceManager.updating) {
            if (deviceManager.scanning) {
                deviceManager.scanDevices_stop()
            } else {
                deviceManager.scanDevices_start()
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: column
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -32

        IconSvg { // imageSearch
            width: (isDesktop || isTablet || (isPhone && appWindow.screenOrientation === Qt.LandscapeOrientation)) ? 256 : (parent.width*0.666)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            fillMode: Image.PreserveAspectFit
            color: Theme.colorIcon

            SequentialAnimation on opacity {
                id: scanAnimation
                loops: Animation.Infinite
                running: deviceManager.scanning
                alwaysRunToEnd: true

                PropertyAnimation { to: 0.33; duration: 750; }
                PropertyAnimation { to: 1; duration: 750; }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 24

            ////////

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")
                spacing: 4

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: (Qt.platform.os === "android")

                    text: qsTr("On Android 6+, scanning for Bluetooth Low Energy devices requires <b>location permission</b>.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: (Qt.platform.os === "android" && !utilsApp.isMobileGpsEnabled())

                    text: qsTr("Some Android devices also require the actual <b>GPS to be turned on</b>.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: (Qt.platform.os === "android")

                    text: qsTr("The application is neither using nor storing your location. Sorry for the inconvenience.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: (Qt.platform.os === "ios")

                    text: qsTr("Authorization to use Bluetooth is required to connect to the sensors.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ////////

            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                rows: 2
                columns: singleColumn ? 1 : 2

                Item {
                    width: singleColumn ? column.width : btn1.width
                    height: 40

                    ButtonWireframeIcon {
                        id: btn1
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                        text: qsTr("Official information")
                        primaryColor: Theme.colorSubText
                        sourceSize: 20
                        source: "qrc:/assets/icons_material/duotone-launch-24px.svg"

                        onClicked: {
                            if (Qt.platform.os === "android") {
                                Qt.openUrlExternally("https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower")
                            } else if (Qt.platform.os === "ios") {
                                Qt.openUrlExternally("https://support.apple.com/HT210578")
                            }
                        }
                    }
                }

                Item {
                    width: singleColumn ? column.width : btn2.width
                    height: 40

                    ButtonWireframe {
                        id: btn2
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: qsTr("Launch detection")
                        fullColor: true
                        primaryColor: Theme.colorPrimary

                        onClicked: {
                            if (utilsApp.checkMobileBleLocationPermission()) {
                                scan()
                            } else {
                                utilsApp.getMobileBleLocationPermission()
                                retryScan.start()
                            }
                        }
                    }
                }
            }

            ////////

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: settingsManager.bluetoothLimitScanningRange

                text: qsTr("Please keep your device close to the sensors you want to scan.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
            }

            ////////
        }
    }
}
