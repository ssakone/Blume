import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import "../components_generic"

Popup {
    id: actionMenu
    width: 200

    padding: 0
    margins: 0

    parent: appContent
    modal: true
    dim: false
    focus: isMobile
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

    property int layoutDirection: Qt.RightToLeft

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        radius: Theme.componentRadius
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
    }

    Keys.onBackPressed: {
        console.log("BACK PRESSED")
        close()
    }

    ////////////////////////////////////////////////////////////////////////////

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        topPadding: 8
        bottomPadding: 8
        spacing: 4

        ////////

        Item {
            // spacer
            height: 8
            width: parent.width
        }

        ActionMenuItem {
            id: textOrderBy

            index: 0
            source: "qrc:/assets/icons_material/baseline-sort-24px.svg"
            layoutDirection: actionMenu.layoutDirection

            function setText() {
                var txt = qsTr("Order by:") + " "
                if (settingsManager.orderBy === "waterlevel") {
                    txt += qsTr("water level")
                } else if (settingsManager.orderBy === "plant") {
                    txt += qsTr("plant name")
                } else if (settingsManager.orderBy === "model") {
                    txt += qsTr("sensor model")
                } else if (settingsManager.orderBy === "location") {
                    txt += qsTr("location")
                }
                textOrderBy.text = txt
            }
            property var sortmode: {
                if (settingsManager.orderBy === "waterlevel") {
                    return 3
                } else if (settingsManager.orderBy === "plant") {
                    return 2
                } else if (settingsManager.orderBy === "model") {
                    return 1
                } else {
                    // if (settingsManager.orderBy === "location") {
                    return 0
                }
            }

            onClicked: {
                sortmode++
                if (sortmode > 3)
                    sortmode = 0

                if (sortmode === 0) {
                    settingsManager.orderBy = "location"
                    deviceManager.orderby_location()
                } else if (sortmode === 1) {
                    settingsManager.orderBy = "model"
                    deviceManager.orderby_model()
                } else if (sortmode === 2) {
                    settingsManager.orderBy = "plant"
                    deviceManager.orderby_plant()
                } else if (sortmode === 3) {
                    settingsManager.orderBy = "waterlevel"
                    deviceManager.orderby_waterlevel()
                }
            }
            Component.onCompleted: textOrderBy.setText()
            Connections {
                target: settingsManager
                function onOrderByChanged() {
                    textOrderBy.setText()
                }
                function onAppLanguageChanged() {
                    textOrderBy.setText()
                }
            }
        }

        Item {
            // spacer
            height: 8
            width: parent.width
        }
        Rectangle {
            height: 1
            width: parent.width
            color: Theme.colorSeparator
        }

        ActionMenuItem {
            id: actionRefresh

            index: 1
            text: qsTr("Refresh sensor data")
            source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
            layoutDirection: actionMenu.layoutDirection

            onClicked: {
                if (!deviceManager.scanning) {
                    if (deviceManager.updating) {
                        deviceManager.refreshDevices_stop()
                    } else {
                        deviceManager.refreshDevices_start()
                    }
                    actionMenu.close()
                }
            }
        }

        ////////

        Rectangle {
            width: parent.width; height: 1;
            color: Theme.colorSeparator
            visible: (deviceManager.bluetooth && (selectedDevice && selectedDevice.hasHistory))
        }

        ActionMenuItem {
            id: actionSyncHistory

            index: 2
            text: qsTr("Sync sensors history")
            source: "qrc:/assets/icons_custom/duotone-date_all-24px.svg"
            layoutDirection: actionMenu.layoutDirection

            onClicked: {
                if (!deviceManager.scanning) {
                    if (deviceManager.syncing) {
                        deviceManager.syncDevices_stop()
                    } else {
                        deviceManager.syncDevices_start()
                    }
                    actionMenu.close()
                }
            }
        }

        ////////

        Rectangle {
            width: parent.width; height: 1;
            color: Theme.colorSeparator
        }

        ActionMenuItem {
            id: actionSearchNewSensors

            index: 8
            text: qsTr("Search for new sensors")
            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            layoutDirection: actionMenu.layoutDirection
            enabled: (deviceManager.bluetooth
                      && deviceManager.bluetoothPermissions)
            onClicked: {
                if (deviceManager.scanning) {
                    deviceManager.scanDevices_stop()
                } else {
                    deviceManager.scanDevices_start()
                }
                actionMenu.close()
            }
        }

        ActionMenuItem {
            id: actionBleDevice

            index: 9
            text: qsTr("Bluetooth devices")
            source: Icons.bluetooth
            layoutDirection: actionMenu.layoutDirection
            enabled: (deviceManager.bluetooth
                      && deviceManager.bluetoothPermissions)

            onClicked: {
                screenDeviceBrowser.loadScreen()
            }
        }

    }
}
