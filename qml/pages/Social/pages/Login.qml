import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0
import Qaterial as Qaterial
import QtWebSockets

import MaterialIcons
import "../../../components"
import "../../../components_generic"
import "../components"
BPage {
    id: root

    property bool isSubmiting: false
    property string errorText: ""
    property color shade: Qt.rgba(15, 200, 15, 0.7)

    header: AppBar {}

    IconSvg {
        source: "qrc:/assets/icons_custom/tulipe_left.svg"
        height: 180
        width: 70
        anchors {
            left: parent.left
            top: parent.top
            topMargin: 150
        }
        transform: Rotation {
            angle: 10
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 25

        IconSvg {
            source: "qrc:/assets/logos/logo.svg"
            Layout.preferredHeight: 70
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignHCenter
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: insideCol.height + 90

            Column {
                id: insideCol
                width: parent.width
                spacing: 25

                ButtonWireframeIcon {
                    text: qsTr("Sign in with Google")
                    source: Icons.google
                    backgroundBorderWidth: 1
                    primaryColor: $Colors.colorPrimary
                    secondaryColor: root.shade
                    height: 50
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ButtonWireframeIcon {
                    text: qsTr("Sign in with Apple")
                    source: Icons.apple
                    primaryColor: $Colors.colorPrimary
                    secondaryColor: root.shade
                    height: 50
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                RowLayout {
                    width: parent.width
                    anchors.topMargin: 25
                    anchors.bottomMargin: 25
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: $Colors.gray500
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Label {
                        text: qsTr("OR")
                        color: $Colors.gray500
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: $Colors.gray500
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 20

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Username")
                        }
                        TextField {
                            id: username
                            placeholderText: "Identifiant"
                            backgroundColor: Qaterial.Colors.white
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 21
                            radius: 15
                            width: parent.width
                            height: 50
                            onTextChanged: errorLabel.visible = false
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Password")
                        }
                        TextField {
                            id: password
                            placeholderText: "Mot de passe"
                            backgroundColor: Qaterial.Colors.white
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 21
                            radius: 15
                            width: parent.width
                            height: 50
                            echoMode: TextInput.Password
                            onTextChanged: errorLabel.visible = false
                            Keys.onReturnPressed: {
                                connectButton.clicked()
                            }
                        }
                    }

                    Qaterial.Label {
                        id: errorLabel
                        visible: false
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Mot de passe incorrect"
                        color: "red"
                    }

                    Qaterial.ExtendedFabButton {
                        id: connectButton
                        property bool busy: false
                        text: busy ? "" : "Creer / Connecter"
                        width: 230
                        //enabled: !busy
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon.source: Qaterial.Icons.lock

                        Qaterial.BusyIndicator {
                            anchors.centerIn: parent
                            width: 30
                            running: parent.busy
                        }

                        onClicked: {
                            Qt.callLater(function () {
                                if (username.text === '' || password.text === '') {
                                    errorLabel.visible = true
                                    return
                                }
                                if (busy === true) {
                                    return
                                }
                                busy = true
                                http.auth(username.text, password.text).then(function (rs) {
                                    const data = JSON.parse(rs)

                                    console.log(rs)

                                    if (data.status === "ok") {
                                        privateKey = data.privateKey
                                        publicKey = data.pubkey
                                        view.push(previewPage)
                                        relay.active = false
                                        relay.active = true
                                        messagesRelay.active = false
                                        messagesRelay.active = true
                                        http.getContacts().then(function (rs) {
                                            friendLists = JSON.parse(rs)
                                            busy = false
                                        }).catch(function (e) {
                                            console.log(JSON.stringify(e))
                                            busy = false
                                        })
                                    } else {
                                        if (data.status === "Error during authentication") {
                                            errorLabel.visible = true
                                            busy = false
                                        }
                                    }
                                }).catch(e => {
                                             console.log(JSON.stringify(e))
                                             busy = false
                                         })
                            })
                        }
                    }

                }
            }
        }


    }

}
