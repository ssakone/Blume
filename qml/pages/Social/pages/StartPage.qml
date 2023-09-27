import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia

import "../components"

Page {

    component StyledButton: Button {
        text: "Créer un compte"
        anchors.horizontalCenter: parent.horizontalCenter
        width: 160
        height: 50
        palette.buttonText: 'white'
        background: Rectangle {
            radius: 5
            color: parent.hovered ? "#203b3e" : "#025d4b"
            border.color: "#ccc"
            border.width: 1.5
            function styleFont() {
                return {
                    "pixelSize": 18
                }
            }
        }
    }
    background: Rectangle {
        color: Qaterial.Colors.teal800
        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: "https://picsum.photos/1000"
            opacity: .2
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 15
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Blume"
            font.family: 'Comic Sans MS'
            color: "white"
            font.weight: Font.Black
            font.pixelSize: 50
            bottomPadding: 40
        }
        Qaterial.Label {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 18
            font.family: 'Comic Sans MS'
            color: "white"
            text: "Authentication"
        }

        TextField {
            id: username
            placeholderText: "Identifiant"
            backgroundColor: Qaterial.Colors.white
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 21
            radius: 30
            width: 280
            height: 50
            onTextChanged: errorLabel.visible = false
        }

        TextField {
            id: password
            placeholderText: "Mot de passe"
            backgroundColor: Qaterial.Colors.white
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 21
            radius: 30
            width: 280
            height: 50
            echoMode: TextInput.Password
            onTextChanged: errorLabel.visible = false
            Keys.onReturnPressed: {
                connectButton.clicked()
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
                            view.push(feedPage)
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
