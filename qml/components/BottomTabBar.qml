import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ThemeEngine

import "../components_generic"

Loader {
    id: control
    property string activePage
    property color bgColor: $Colors.white
    property bool showTitles: false

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
                property bool isActivePage: activePage === "Garden"
                Rectangle {
                    width: 50
                    height: width
                    radius: height/2
                    color: parent.isActivePage ? Theme.colorPrimary : control.bgColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    ColorImage {
                        source: "qrc:/assets/icons_custom/menubottom_garden.svg"
                        color: parent.parent.isActivePage ? $Colors.white : $Colors.black
                        anchors.centerIn: parent
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Garden")
                    color: "white"
                    visible: control.showTitles
                }
            }

            componentRadius: 0
            fullColor: true
            primaryColor: control.bgColor
            onClicked: {
                console.log("Depth ", page_view.depth)
                if (activePage !== "Garden") {
                    for (var i = 0; i <= page_view.depth; i++) {
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
                property bool isActivePage: activePage === "Plants"
                Rectangle {
                    width: 50
                    height: width
                    radius: height/2
                    color: parent.isActivePage ? Theme.colorPrimary : control.bgColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    ColorImage {
                        source: "qrc:/assets/icons_custom/menubottom_plants.svg"
                        color: parent.parent.isActivePage ? $Colors.white : $Colors.black
                        anchors.centerIn: parent
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Plants")
                    color: "white"
                    visible: control.showTitles
                }
            }

            componentRadius: 0
            fullColor: true
            primaryColor: control.bgColor
            onClicked: {
                activePage !== "Plants" && appContent.openStackView(
                            plantBrowserPage)
            }
        }

        ButtonWireframe {
            Layout.preferredHeight: 70
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                property bool isActivePage: activePage === "Health"
                Rectangle {
                    width: 50
                    height: width
                    radius: height/2
                    color: parent.isActivePage ? Theme.colorPrimary : control.bgColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    ColorImage {
                        source: "qrc:/assets/icons_custom/menubottom_health.svg"
                        color: parent.parent.isActivePage ? $Colors.white : $Colors.black
                        anchors.centerIn: parent
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Health")
                    color: "white"
                    visible: control.showTitles
                }
            }

            componentRadius: 0
            fullColor: true
            primaryColor: control.bgColor
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
                property bool isActivePage: activePage === "DeviceList"
                Rectangle {
                    width: 50
                    height: width
                    radius: height/2
                    color: parent.isActivePage ? Theme.colorPrimary : control.bgColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    ColorImage {
                        source: "qrc:/assets/icons_custom/menubottom_devices.svg"
                        color: parent.parent.isActivePage ? $Colors.white : $Colors.black
                        anchors.centerIn: parent
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("DeviceList")
                    color: "white"
                    visible: control.showTitles
                }
            }


            componentRadius: 0
            fullColor: true
            primaryColor: control.bgColor
            onClicked: {
                activePage !== "DeviceList" && page_view.push(
                            navigator.deviceList)
                //                appContent.state = "DeviceList"
            }
        }

        ButtonWireframe {
            Layout.preferredHeight: 70
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                property bool isActivePage: activePage === "Feed"
                Rectangle {
                    width: 50
                    height: width
                    radius: height/2
                    color: parent.isActivePage ? Theme.colorPrimary : control.bgColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    ColorImage {
                        source: Icons.accountGroup
                        color: parent.parent.isActivePage ? $Colors.white : $Colors.black
                        anchors.centerIn: parent
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Feed")
                    color: "white"
                    visible: control.showTitles
                }
            }


            componentRadius: 0
            fullColor: true
            primaryColor: control.bgColor
            onClicked: {
                activePage !== "Feed" && page_view.push(navigator.feedPage)
                //                appContent.state = "DeviceList"
            }
        }
    }
}
