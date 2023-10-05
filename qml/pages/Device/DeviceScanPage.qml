import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components_generic"
import "../../components"
import "../.."


BPage {
    id: control
    property int spaceID
    property string spaceName: ""
    property string spaceDescription: ""
    property bool isOutDoor: false
    property bool shouldCreate: spaceName === "" && spaceDescription === ""
    property var callback: function () {}

    property bool hasPermissions: utilsApp.getMobileBleLocationPermission()


    background.opacity: 0.5
//    background.color: Qt.rgba(12, 200, 25, 0)


    header: AppBar {
        id: header
        title: ""
        statusBarVisible: false
    }

    function scan() {
        if (!deviceManager.updating) {
            if (deviceManager.scanning) {
                deviceManager.scanDevices_stop()
            } else {
                deviceManager.scanDevices_start()
            }
        } else
            console.warn("deviceManager.updating")
    }

    onFocusChanged: {
        if(focus) {
            if (utilsApp.checkMobileBleLocationPermission()) {
                scan()
            } else {
                utilsApp.getMobileBleLocationPermission()
                retryScan.start()
            }
        } else {
            deviceManager.scanDevices_stop()
        }

    }

    Timer {
        id: retryScan
        interval: 333
        running: false
        repeat: false
        onTriggered: {
            if (utilsApp.checkMobileBleLocationPermission()) {
                hasPermissions = true
                scan()
            } else {
                hasPermissions = utilsApp.getMobileBleLocationPermission()
                retryScan.start()
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: _insideCol.height

        Column {
            id: _insideCol
            anchors.fill: parent
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                width: parent.width
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Scanning...")
                    color: $Colors.colorPrimary
                    visible: deviceManager.scanning
                    font {
                        weight: Font.DemiBold
                        pixelSize: 24
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Scan completed")
                    color: "#D68C44"
                    visible: hasPermissions && !deviceManager.scanning
                    font {
                        weight: Font.DemiBold
                        pixelSize: 24
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Permissions not granted")
                    color: $Colors.red300
                    visible: !hasPermissions
                    font {
                        weight: Font.DemiBold
                        pixelSize: 24
                    }
                }
            }


            Image {
                height: 240
                width: height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 15
                source: "qrc:/assets/icons_custom/radar-sensors.svg"

                SequentialAnimation on opacity {
                    id: scanAnimation
                    loops: Animation.Infinite
                    running: deviceManager.scanning
                    alwaysRunToEnd: true

                    PropertyAnimation {
                        to: 0.33
                        duration: 750
                    }
                    PropertyAnimation {
                        to: 1
                        duration: 750
                    }
                }

            }

            Item {
                width: 1
                height: 100
                visible: !deviceManager.scanning
            }

            Column {
                width: parent.width
                leftPadding: 10
                rightPadding: 10

                Column {
                    width: parent.width - 20
                    spacing: 30

                    Label {
                        text: qsTr("No sensor found!")
                        color: "#D68C44"
                        width: parent.width
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            weight: Font.DemiBold
                            pixelSize: 24
                        }
                        visible: hasPermissions && !deviceManager.scanning
                    }
                    Label {
                        text: qsTr("Please check your sensors and search again.")
                        width: parent.width
                        leftPadding: 30
                        rightPadding: 30
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        color: $Colors.colorPrimary
                        font {
                            weight: Font.Light
                            pixelSize: 16
                        }
                        visible: hasPermissions && !deviceManager.scanning
                    }

                    NiceButton {
                        id: btn2
                        width: parent.width
                        height: 60
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: hasPermissions ? qsTr("Launch detection") : qsTr("Grant permissions")
                        visible: !deviceManager.scanning
                        bgGradient: $Colors.gradientPrimary
                        radius: 10
                        font.pixelSize: 18
                        padding: 10
                        leftPadding: 20
                        rightPadding: leftPadding
                        onClicked: {
                            console.log("click")
                            retryScan.start()
                        }
                    }


                }

                Column {
                    width: parent.width - 20
                    visible: deviceManager.scanning
                    Label {
                        text: qsTr("Detected sensors...")
                        color: $Colors.colorPrimary
                        font {
                            weight: Font.DemiBold
                            pixelSize: 16
                        }
                    }

                    Repeater {
                        model: deviceManager.devicesList
                        delegate: DeviceWidget {
                            width: parent.width
                            height: 100
                            bigAssMode: (!isHdpi || (isTablet && width >= 480))
                        }
                    }
                }
            }


        }
    }


}
