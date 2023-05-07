import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ThemeEngine

import "../components_generic"

Loader {
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
                    source: Icons.potMix
                    width: 32
                    height: 32
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Garden")
                    color: "white"
                }
            }

            componentRadius: 0
            fullColor: true
            primaryColor: appContent.state
                          === "Navigator" ? Theme.colorPrimary : Theme.colorSecondary
            onClicked: {
                appContent.state = "Navigator"
            }
        }

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
                    text: qsTr("Plants")
                }
            }

            componentRadius: 0
            fullColor: true
            primaryColor: Theme.colorSecondary
            onClicked: {
                appContent.openStackView(plantBrowserPage)
            }
        }
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
                    text: qsTr("Health")
                    color: "white"
                }
            }

            componentRadius: 0
            fullColor: true
            primaryColor: Theme.colorSecondary
            onClicked: {
                appContent.openStackView(desease)
            }
        }
        ButtonWireframe {
            Layout.preferredHeight: 70
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                ColorImage {
                    source: Icons.devices
                    width: 32
                    height: 32
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Devices")
                    color: "white"
                }
            }

            componentRadius: 0
            fullColor: true
            primaryColor: appContent.state
                          === "DeviceList" ? Theme.colorPrimary : Theme.colorSecondary
            onClicked: {
                appContent.state = "DeviceList"
            }
        }
    }
}
