import QtQuick
import QtQuick.Controls
import ThemeEngine 1.0
import QtQuick.Layouts

Item {
    id: itemNoDevice
    anchors.fill: parent
    property bool hasLaunchedScanOnce: false

    ////////////////////////////////////////////////////////////////////////////

    Timer {
        id: retryScan
        interval: 333
        running: false
        repeat: false
        onTriggered: scan()
    }

    function scan() {
        hasLaunchedScanOnce = true
        if (!deviceManager.updating) {
            if (deviceManager.scanning) {
                deviceManager.scanDevices_stop()
            } else {
                deviceManager.scanDevices_start()
            }
        } else console.warn("deviceManager.updating")
    }

    function stop() {
        deviceManager.scanDevices_stop()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: ellispis
        anchors {
            bottom: parent.top
            bottomMargin: -160
            horizontalCenter: parent.horizontalCenter
        }

        height: 1200
        width: height / 1.7
        radius: height

        gradient: $Colors.gradientPrimary
    }

    ColumnLayout {
        id: column
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 25
            Layout.leftMargin: 32
            Layout.rightMargin: 32

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Appareils connectés")
                    font {
                        pixelSize: 28
                        family: "Courrier"
                        weight: Font.Bold
                    }
                    color: $Colors.white
                }
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: Layout.preferredWidth
                    radius: Layout.preferredHeight / 2
                    color: $Colors.white


                    IconSvg {
                        anchors.centerIn: parent
                        source: "qrc:/assets/icons/svg/bell-alert.svg"
                        color: $Colors.colorPrimary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: page_view.push(navigator.loginPage)
                        }
                    }
                }

            }

            Column {
                Layout.fillWidth: true
                Text {
                    text: qsTr("Connectez-vous pour connaitre")
                    opacity: .5
                    color: $Colors.white
                    font {
                        pixelSize: 16
                        family: "Courrier"
                        weight: Font.Bold
                    }
                }
                Text {
                    text: qsTr("l'état de vos plantes")
                    opacity: .5
                    color: $Colors.white
                    font {
                        pixelSize: 16
                        family: "Courrier"
                        weight: Font.Bold
                    }
                    horizontalAlignment: Text.AlignHCenter
                }
            }

        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _insideCol.height
            Column {
                id: _insideCol
                width: parent.width

                IconSvg { // imageSearch
                    width: parent.width
                    height: width
                    anchors.leftMargin: 32
                    anchors.rightMargin: 32
                    anchors.topMargin: deviceManager.scanning ? 30 : 0

                    source: deviceManager.scanning ? "qrc:/assets/icons_custom/radar-sensors.svg" : "qrc:/assets/img/scan-in-salon.svg"
                    fillMode: Image.PreserveAspectFit
                    //color: $Colors.colorPrimary

                    SequentialAnimation on opacity {
                        id: scanAnimation
                        loops: Animation.Infinite
                        running: deviceManager.scanning
                        alwaysRunToEnd: true

                        PropertyAnimation { to: 0.33; duration: 750; }
                        PropertyAnimation { to: 1; duration: 750; }
                    }
                }

                Container {
                    width: parent.width

                    background: Rectangle {
                        color: screenDeviceList.backgroundColor
                    }

                    contentItem: Column {
                        leftPadding: 32
                        rightPadding: leftPadding
                        width: parent.width - 64

                    }
                    Column {
                        spacing: 24
                        width: parent.width - parent.leftPadding*2
                        ////////
                        Column {
                            width: parent.width
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

//                        Text {
//                            id: labelNoDeviceFound
//                            text: qsTr("Aucun capteurs détectés")
//                            color: $Colors.colorSecondary
//                            font.weight: Font.DemiBold
//                            font.pixelSize: 18
//                            anchors.horizontalCenter: parent.horizontalCenter
//                            visible: hasLaunchedScanOnce && deviceManager.scanning
//                            onVisibleChanged: {
//                                console.log("Visilituy cnahfes ", visible, " --* ",  hasLaunchedScanOnce, !deviceManager.scanning)
//                                if(visible) timerNoDeviceFound.start()
//                            }

//                            Timer {
//                                id: timerNoDeviceFound
//                                interval: 3000
//                                onTriggered: labelNoDeviceFound.visible = false
//                            }
//                        }

                        NiceButton {
                            id: btn2
                            width: parent.width
                            height: 60
                            visible: !deviceManager.scanning
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: qsTr("Launch detection") // qsTr("Launch detection")
                            bgGradient: $Colors.gradientPrimary
                            radius: 10
                            font.pixelSize: 18
                            padding: 10
                            leftPadding: 20
                            rightPadding: leftPadding
                            onClicked: {
                                if (utilsApp.checkMobileBleLocationPermission()) {
                                    scan()
                                } else {
                                    utilsApp.getMobileBleLocationPermission()
                                    retryScan.start()
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 60
                            visible: !deviceManager.scanning
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 10
                            color: "#FFEEE8"

                            Text {
                                text: qsTr("L'application n'utilise ni ne stocke votre position")
                                color: "#F28C1C"
                                font.pixelSize: 16
                                padding: 10
                                leftPadding: 20
                                rightPadding: leftPadding
                                width: parent.width - leftPadding*2
                                wrapMode: Text.Wrap
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }

                        NiceButton {
                            width: parent.width
                            height: 60
                            visible: deviceManager.scanning
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: qsTr("Arreter la détection")
                            backgroundColor: $Colors.red400
                            foregroundColor: $Colors.white
                            radius: 10
                            font.pixelSize: 18
                            padding: 10
                            leftPadding: 20
                            rightPadding: leftPadding
                            onClicked: stop()
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

                        Column {
                            width: parent.width
                            spacing: 10
                            visible: !deviceManager.scanning
                            Text {
                                text: qsTr("Les derniers capteurs connectés")
                                color: $Colors.colorPrimary
                                font.weight: Font.DemiBold
                                font.pixelSize: 18
                            }

                            Repeater {
                                model: 4
                                Rectangle {
                                    height: 60
                                    width: parent.width - 20
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    Row {
                                        spacing: 10
                                        Image {
                                            width: 25
                                            height: width
                                            source: "qrc:/assets/img/pots-group.png"
                                        }
                                        Column {
                                            spacing: 10
                                            Text {
                                                text: "capteur Wangfei"
                                                font {
                                                    weight: Font.DemiBold
                                                    pixelSize: 16
                                                }
                                            }
                                            Row {
                                                spacing: 10
                                                Text {
                                                    text: "Dernière connexion"
                                                    font {
                                                        pixelSize: 14
                                                    }
                                                }

                                                Text {
                                                    text: "Aujourd'hui à 16:35"
                                                    font {
                                                        weight: Font.DemiBold
                                                        pixelSize: 14
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 10
                            visible: deviceManager.scanning
                            Text {
                                text: qsTr("Capteurs détectés")
                                color: $Colors.colorPrimary
                                font.weight: Font.DemiBold
                                font.pixelSize: 18
                            }

                            Repeater {
                                model: deviceManager.devicesList
                                delegate: DeviceWidget {
                                    width: parent.width
                                    height: 100
                                    bigAssMode: (!isHdpi || (isTablet && width >= 480))
                                    singleColumn: (appWindow.singleColumn || devicesView.cellColumnsTarget === 1)
                                }
                            }
                        }

                        Item {
                            width: 1
                            height: 30
                        }

                        ////////
                    }

                }


            }
        }

    }

}
