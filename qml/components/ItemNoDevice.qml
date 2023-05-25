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
        } else console.warn("deviceManager.updating")
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
                    visible: (Qt.platform.os === "android" && !utilsApp.checkMobileBleLocationPermission())

                    text: qsTr("Authorization to use Location is required to connect to the sensors </b>.")
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

                    text: qsTr("The application is neither using nor storing your location")
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

            ButtonWireframe {
                id: btn2
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Launch detection") // qsTr("Launch detection")
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
