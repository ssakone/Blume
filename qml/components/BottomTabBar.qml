import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ThemeEngine

import "../components_generic"

Loader {
    property string activePage
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
//            primaryColor: appContent.state
//                          === "Navigator" ? Theme.colorPrimary : Theme.colorSecondary
            primaryColor: activePage
                          === "Garden" ? Theme.colorPrimary : Theme.colorSecondary
            onClicked: {
                console.log("Depth ", page_view.depth)
                if(activePage !== "Garden") {
                    for(let i=0; i<=page_view.depth; i++) {
                        page_view.pop()
                    }
                }

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
            primaryColor: activePage
                          === "Plants" ? Theme.colorPrimary : Theme.colorSecondary
            onClicked: {
                activePage !== "Plants" && appContent.openStackView(plantBrowserPage)
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
            primaryColor: activePage
                          === "Health" ? Theme.colorPrimary : Theme.colorSecondary
            onClicked: {
                activePage !== "Health" && appContent.openStackView(desease)
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
            primaryColor: activePage
                          === "DeviceList" ? Theme.colorPrimary : Theme.colorSecondary
            onClicked: {
                activePage !== "DeviceList" && page_view.push(navigator.deviceList)
//                appContent.state = "DeviceList"
            }
        }
    }
}
