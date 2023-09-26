import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia

import SortFilterProxyModel 0.2

import "../components"

Page {
    id: page
    property var profile: ({})
    property string pubKey
    property bool isContact: false

    Component.onCompleted: {
        checkFollow()
    }

    Connections {
        target: root
        function onUserInfoChanged() {
            if (profile.pubkey === publicKey) {
                page.profile = {
                    "pubkey": publicKey,
                    "name": root.userInfo.name,
                    "picture": root.userInfo.picture,
                    "about": root.userInfo.about,
                    "profession": root.userInfo.profession
                }
                page.isContact = false
            }
        }
    }

    function checkFollow() {
        if (profile.pubkey !== publicKey) {
            if (root.contacts[publicKey] === undefined) {
                root.contacts[publicKey] = []
            }

            root.contacts[publicKey].forEach(function (contact) {
                if (contact[1] === profile.pubkey) {
                    isContact = true
                }
            })
        } else {
            isContact = false
        }
    }

    Timer {
        id: followTimer
        repeat: true
        running: !page.isContact
        interval: 1000
        onTriggered: {
            checkFollow()
        }
    }

    palette.window: 'white'
    header: ToolBar {
        contentHeight: 60
        height: 65
        background: Rectangle {}
        RowLayout {
            anchors.fill: parent
            spacing: 0
            ToolBarButton {
                icon.source: Qaterial.Icons.arrowLeft
                onClicked: view.pop()
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    leftPadding: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    text: qsTr("Profil of %1").arg(page.profile.name
                                                   || page.profile.pubkey.slice(
                                                       0, 18) + "...")
                }
            }
            ToolBarButton {
                visible: page.profile.pubkey === publicKey

                icon.source: Qaterial.Icons.pencilOutline
                onClicked: {
                    view.push(profileEditPage)
                }
            }
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 0
        contentWidth: width
        Column {
            spacing: 20
            width: parent.width
            Avatar {
                height: 150
                width: 150
                source: page.profile.picture || ""
                avatarSize: 140
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Column {
                spacing: 1
                anchors.horizontalCenter: parent.horizontalCenter
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: page.profile.name || ""
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: "black"
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: page.profile.profession || ""
                    font.pixelSize: 12
                    opacity: .7
                    color: "black"
                }
            }

            Row {
                visible: page.profile.pubkey !== publicKey
                height: 50
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Qaterial.RaisedButton {
                    text: "Ajouter"
                    height: 50
                    font.pixelSize: 15
                    font.bold: true
                    padding: 15
                    visible: !page.isContact
                    palette.buttonText: "white"
                    background: Rectangle {
                        radius: 5
                        color: "#025d4b"
                    }

                    onClicked: {
                        enabled = false
                        http.addContact(privateKey, contacts[publicKey] || [],
                                        page.profile.pubkey).then(
                                    function (rs) {
                                        console.log(rs)
                                        if (rs === "ok") {
                                            getContact(publicKey)
                                        }
                                    }).catch(function (err) {
                                        console.log(JSON.stringify(err))
                                        enabled = true
                                    })
                    }
                }
                Qaterial.RaisedButton {
                    text: "Envoyer un message"
                    height: 50
                    font.pixelSize: 15
                    font.bold: true
                    padding: 15
                    backgroundColor: "#025d4b"

                    onClicked: {
                        view.push(messagePage, {
                                      "friend": page.profile
                                  })
                    }
                }
            }

            // bio
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
                wrapMode: Label.Wrap
                text: page.profile.about || ""
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                color: "black"
            }

            Qaterial.RaisedButton {
                text: "Logout"
                height: 50
                font.pixelSize: 15
                font.bold: true
                padding: 15
                palette.buttonText: "white"
                visible: page.profile.pubkey === publicKey
                anchors.horizontalCenter: parent.horizontalCenter
                backgroundColor: Qaterial.Colors.red
                onClicked: {
                    root.privateKey = ""
                    root.publicKey = ""
                    root.contacts = {}
                    root.userInfo = {}
                    root.realDiscussions = {}
                    root.friendLists = []
                    discussions.clear()
                    messages.clear()
                    events.clear()
                    root.subscribed = []
                    relay.active = false
                    messagesRelay.active = false
                    root.logout()
                    view.pop()
                    view.pop()
                }
            }
        }
    }
}
