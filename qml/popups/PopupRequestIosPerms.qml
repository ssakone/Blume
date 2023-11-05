import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

import "../components_generic/"
import "../components_themed/"

Popup {
    id: pop
    x: (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height) : ((appWindow.height / 2)
                                                     - (height / 2) /*- (appHeader.height)*/
                                                     )

    width: singleColumn ? parent.width : 640
    height: columnContent.height + padding * 2
    padding: singleColumn ? 20 : 24

    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    property var callbackSuccess
    property var callbackError

    signal confirmed
    signal rejected

    function grantOrRunCamera(onSuccess = function () {}, onError = function () {}) {
        console.log("callbackFunc ", onSuccess)
        callbackSuccess = onSuccess
        callbackError = onError
        if(!pesistedAppSettings.didAccepIOSPersm) {
            pop.open()
        } else confirmed()
    }

    onConfirmed: {
        if(callbackSuccess) callbackSuccess()
    }

    onRejected: {
        if(callbackError) callbackError()
    }

    onClosed: {
        console.log("ON CLOSED")
        callbackSuccess = undefined
        callbackError = undefined
    }

    ////////////////////////////////////////////////////////////////////////////
    background: Rectangle {
        color: $Colors.gray200
        border.color: Theme.$Colors.gray800
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

                text: qsTr("Autorisation requise")
                textFormat: Text.PlainText
                font.pixelSize: 20
                color: $Colors.gray900
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width

                text: qsTr("Blume a besoin d'accéder à la caméra de votre téléphone pour forunir les fonctionnalité de détection de plantes et les fonctionnalités du chat. Acceptez-vous que Blume accède à votre caméra pour ces actions ?")
                textFormat: Text.PlainText
                font.pixelSize: 16
                color: $Colors.gray700
                wrapMode: Text.WordWrap
            }

            Flow {
                id: flowContent
                width: parent.width
                height: singleColumn ? 120 + 32 : 40

                property var btnSize: singleColumn ? width : ((width - spacing * 2) / 3)
                spacing: 20

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Accepter")
                    primaryColor: $Colors.white
                    secondaryColor: $Colors.colorPrimary

                    onClicked: {
                        confirmed()
                        pop.close()
                    }
                }
                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Refuser")
                    primaryColor: $Colors.red400
                    fullColor: true

                    onClicked: {
                        rejected()
                        pop.close()
                    }
                }
            }
        }
    }
}
