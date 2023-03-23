import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Popup {
    id: popupLocationNotification
    x: (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height) : ((appWindow.height / 2) - (height / 2) - (appHeader.height))

    width: singleColumn ? parent.width : 640
    height: columnContent.height + padding*2
    padding: singleColumn ? 20 : 24

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    signal confirmed()

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: singleColumn ? 0 : Theme.componentBorderWidth
        radius: singleColumn ? 0 : Theme.componentRadius

        Rectangle {
            width: parent.width
            height: Theme.componentBorderWidth
            visible: singleColumn
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Column {
            id: columnContent
            width: parent.width
            spacing: 20

            Text {
                width: parent.width

                text: qsTr("Blume utilise la location pour identifier les capteurs aux alentours, et mettre les informations des plantes à jour même quand l'application est fermée.", "", screenDeviceList.selectionCount)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width

                text: qsTr("Cela nécessaire pour accéder à l'application", "", screenDeviceList.selectionCount)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
            }
            Text {
                width: parent.width

                text: qsTr("Votre position n'est ni communiquée ni stockée à des tiers.", "", screenDeviceList.selectionCount)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
            }

            Flow {
                id: flowContent
                width: parent.width
                height: singleColumn ? 120+40 : 40

                property real btnSize: (width-spacing) / 2
                spacing: 16

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Je refuse")
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground

                    onClicked: Qt.quit()
                }
                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("J'accepte")
                    primaryColor: Theme.colorGreen
                    fullColor: true

                    onClicked: {
                        if (!utilsApp.checkMobileBleLocationPermission()) {
                             utilsApp.getMobileBleLocationPermission()
                        }
                        popupLocationNotification.confirmed()
                        popupLocationNotification.close()
                    }
                }
            }
        }
    }
}
