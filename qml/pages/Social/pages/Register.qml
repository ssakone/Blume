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

//                ButtonWireframeIcon {
//                    text: qsTr("Sign in with Google")
//                    source: Icons.google
//                    backgroundBorderWidth: 1
//                    primaryColor: $Colors.colorPrimary
//                    secondaryColor: root.shade
//                    height: 50
//                    width: parent.width
//                    anchors.horizontalCenter: parent.horizontalCenter
//                }

//                ButtonWireframeIcon {
//                    text: qsTr("Sign in with Apple")
//                    source: Icons.apple
//                    primaryColor: $Colors.colorPrimary
//                    secondaryColor: root.shade
//                    height: 50
//                    width: parent.width
//                    anchors.horizontalCenter: parent.horizontalCenter
//                }

//                RowLayout {
//                    width: parent.width
//                    anchors.topMargin: 25
//                    anchors.bottomMargin: 25
//                    Rectangle {
//                        Layout.fillWidth: true
//                        Layout.preferredHeight: 1
//                        color: $Colors.gray500
//                        Layout.alignment: Qt.AlignVCenter
//                    }

//                    Label {
//                        text: qsTr("OR")
//                        color: $Colors.gray500
//                        Layout.alignment: Qt.AlignVCenter
//                    }

//                    Rectangle {
//                        Layout.fillWidth: true
//                        Layout.preferredHeight: 1
//                        color: $Colors.gray500
//                        Layout.alignment: Qt.AlignVCenter
//                    }
//                }

                ColumnLayout {
                    width: parent.width
                    spacing: 20

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Last name")
                        }
                        TextField {
                            id: lastName
                            placeholderText: qsTr("Your last name")
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
                            text: qsTr("First name")
                        }
                        TextField {
                            id: firstName
                            placeholderText: qsTr("Your first name")
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
                            text: qsTr("Email or phone")
                        }
                        TextField {
                            id: email
                            placeholderText: qsTr("Email address or phone number")
                            backgroundColor: Qaterial.Colors.white
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 21
                            radius: 15
                            width: parent.width
                            height: 50
                            onTextChanged: errorLabel.text = ""
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Username *")
                        }
                        TextField {
                            id: username
                            placeholderText: qsTr("Your user ID")
                            backgroundColor: Qaterial.Colors.white
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 21
                            radius: 15
                            width: parent.width
                            height: 50
                            onTextChanged: errorLabel.text = ""
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Password *")
                        }
                        TextField {
                            id: password
                            placeholderText: qsTr("Your password")
                            backgroundColor: Qaterial.Colors.white
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 21
                            radius: 15
                            width: parent.width
                            height: 50
                            echoMode: TextInput.Password
                            onTextChanged: errorLabel.text = ""
                            Keys.onReturnPressed: {
                                connectButton.clicked()
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 5

                        Qaterial.CheckButton {
                            id: agreementCheck
                            text: qsTr("J'accepte les conditions d'utilisation")
                        }

                        Qaterial.Label {
                            text: "Lire les conditions d'utilisation"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.underline: true
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://mahoudev.github.io/blume-politique-confidentialite")
                            }
                        }
                    }

                    Label {
                        id: errorLabel
                        color: "red"
                        font.pixelSize: 14
                    }


                    Qaterial.ExtendedFabButton {
                        id: connectButton
                        property bool busy: false
                        text: busy ? "" : qsTr("Create my account")
                        width: 230
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon.source: Qaterial.Icons.lock

                        Qaterial.BusyIndicator {
                            anchors.centerIn: parent
                            width: 30
                            running: parent.busy
                        }

                        onClicked: {
                            Qt.callLater(function () {
                                errorLabel.text = ""
                                if (username.text === '' || password.text === '' || agreementCheck.checked === false) {
                                    errorLabel.text = qsTr("Fill all required fields")

                                    return
                                }
                                if (busy === true) {
                                    return
                                }
                                busy = true
                                http.createAccount(username.text, password.text).then(function (rs) {
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
                                        if (data.status === "USERNAME_NOT_AVAILABLE") {
                                            errorLabel.text = qsTr("Username not available")
                                            busy = false
                                        }
                                    }
                                }).catch(e => {
                                             console.log(JSON.stringify(e))
                                             busy = false
                                             errorLabel.text = qsTr("An error occured")

                                         })
                            })
                        }
                    }

                }
            }
        }


    }

}
