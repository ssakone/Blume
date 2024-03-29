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
                            text: qsTr("Username")
                        }
                        TextField {
                            id: username
                            placeholderText: qsTr("Your user id")
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
                            text: qsTr("Password")
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

                    Qaterial.Label {
                        id: errorLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "red"
                        font.pixelSize: 14
                    }

                    Qaterial.ExtendedFabButton {
                        id: connectButton
                        property bool busy: false
                        text: busy ? "" : qsTr("Login")
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
                                    errorLabel.text = qsTr("Fill username and password")
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
                                        busy = false
                                        errorLabel.text = data.status

                                    }
                                }).catch(e => {
                                             console.log(JSON.stringify(e))
                                             busy = false
                                             errorLabel.text = qsTr("An error occured")
                                             if(e.status === 401) {
                                                 errorLabel.text = qsTr("Invalid credentials")
                                             }

                                         })
                            })
                        }
                    }

                }
            }
        }


    }

}
