import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components_generic"
import "../../components"
import "../.."


BPage {
    property int spaceID
    property string spaceName: ""
    property string spaceDescription: ""
    property bool isOutDoor: false
    property bool shouldCreate: spaceName === "" && spaceDescription === ""
    property var callback: function () {}


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
        }

    }

    Timer {
        id: retryScan
        interval: 333
        running: false
        repeat: false
        onTriggered: scan()
    }


    ColumnLayout {
        id: _insideCol
        anchors.fill: parent
        spacing: 15
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Scan en cours...")
            color: $Colors.colorPrimary
            font {
                weight: Font.DemiBold
                pixelSize: 24
            }
        }

        Image {
            Layout.preferredHeight: 240
            Layout.preferredWidth: 240
            Layout.alignment: Qt.AlignHCenter
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

        Column {
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftPadding: 10
            rightPadding: 10

            ColumnLayout {
                width: parent.width - 20
                height: parent.height
                Label {
                    text: qsTr("Capteurs détectés...")
                    color: $Colors.colorPrimary
                    font {
                        weight: Font.DemiBold
                        pixelSize: 16
                    }
                }

                DeviceListUnified {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }


    }

}
