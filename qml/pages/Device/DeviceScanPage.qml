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
        leading.icon: Icons.close
        color: Qt.rgba(12, 200, 25, 0)
        foregroundColor: $Colors.colorPrimary

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

    Component.onCompleted: {
        if (utilsApp.checkMobileBleLocationPermission()) {
            scan()
        } else {
            utilsApp.getMobileBleLocationPermission()
            retryScan.start()
        }
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
            Layout.preferredHeight: 180
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignHCenter
            anchors.margins: 15
            source: "qrc:/assets/icons_custom/radar-sensors.svg"
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
