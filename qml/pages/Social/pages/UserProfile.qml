import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia

import SortFilterProxyModel 0.2

import "../../../components_js/Http.js" as Http
import "../../../components_generic"
import "../../../components" as Components
import "../components"

BPage {
    id: page
    property var profile: ({})
    property string pubKey
    property bool isContact: false
    property bool isMyProfile: false

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
            }
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 0
        contentWidth: width
        contentHeight: insideCol.height + 50
        Column {
            id: insideCol
            spacing: 60
            width: parent.width

            Image {
                width: parent.width
                height: 170
                source: "qrc:/assets/img/bg-profile.png"

                Rectangle {
                    width: 100
                    height: width
                    radius: height / 2
                    border {
                        width: 1
                        color: $Colors.gray700
                    }
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.bottom
                        topMargin: -height/2
                    }

                    IconSvg {
                        anchors.fill: parent
                        source: page.profile.picture || Icons.account
                        anchors.margins: 20
                    }

//                    Item {
//                        anchors.fill: parent
//                        anchors.margins: 10

//                        Rectangle {
//                            color: $Colors.green300
//                            radius: height/2
//                            anchors.fill: parent
//                        }

//                        IconSvg {
//                            anchors.fill: parent
//                            source: page.profile.picture || Icons.account
//                        }
//                    }
                }

            }

            Column {
                width: parent.width
                spacing: 20

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

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Blume App"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: $Colors.colorPrimary
                }

                Rectangle {
                    width: parent.width
                    height: 90
                    color: $Colors.colorTertiary
                    radius: 15

                    RowLayout {
                        anchors.fill: parent
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 7
                            Label {
                                text: $Model.space.plantInSpace.count
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: $Colors.colorPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: "Nombre de plantes"
                                font.pixelSize: 14
                                font.weight: Font.Light
                                Layout.fillWidth: true
                                wrapMode: Label.Wrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 7
                            Label {
                                text: root.friendLists.length
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: $Colors.colorPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: "Abonnés"
                                font.pixelSize: 14
                                font.weight: Font.Light
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 7
                            Label {
                                text: "0"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: $Colors.colorPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: "Abonnements"
                                font.pixelSize: 14
                                font.weight: Font.Light
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }

                Flickable {
                    height: 180
                    width: parent.width
                    contentWidth: _insideRow.width
                    clip: true
                    anchors.topMargin: 20

                    Row {
                        id: _insideRow
                        spacing: 10

                        BusyIndicator {
                            running: favorisRepeater.model?.length === 0
                            visible: running
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Repeater {
                            id: favorisRepeater
                            Component.onCompleted: {
                                if(page.profile.pubkey === publicKey) return
                                const url = `https://blume.mahoudev.com/items/Plantes?offset=${Math.ceil(
                                              Math.random(
                                                  ) * 1000)}&limit=5&fields=*.*`

                                Http.fetch({
                                               "method": "GET",
                                               "url": url,
                                               "headers": {
                                                   "Accept": 'application/json',
                                                   "Content-Type": 'application/json'
                                               }
                                           }).then(function (response) {
                                               //                                                    console.log("Got favoris ", response)
                                               const parsedResponse = JSON.parse(
                                                                        response)
                                                                    ?? []
                                               console.log("Favoris ",
                                                           parsedResponse?.data?.length)
                                               favorisRepeater.model = parsedResponse.data
                                                       ?? parsedResponse
                                           })
                            }

                            model: []
                            delegate: Components.GardenPlantLineImage {
                                required property variant modelData
                                property var plant: modelData
                                width: 300
                                height: 180
                                title: plant.name_scientific
                                subtitle: plant.noms_communs[0]?.name ?? ""
                                moreDetailsList: [{
                                        "iconSource": plant.toxicity
                                                      === null ? "" : Components.Icons.water,
                                        "text": plant.toxicity === null ? "" : plant.toxicity === true ? "Toxique" : "Non toxique"
                                    }, {
                                        "iconSource": Components.Icons.food,
                                        "text": plant.commestible ? "Commestible" : "Non commestible"
                                    }]
                                roomName: ""
                                imageSource: plant.images_plantes.length > 0 ? "https://blume.mahoudev.com/assets/" + plant.images_plantes[0].directus_files_id : ""
                                onClicked: $Signaler.showPlant(plant)
                            }
                        }
                    }
                }

                Components.NiceButton {
                    //visible: page.isMyProfile
                    visible: page.profile.pubkey === publicKey
                    bgGradient: $Colors.gradientPrimary
                    text: qsTr("Edit my profile")
                    radius: 10
                    width: parent.width
                    height: 60
                    onClicked: {
                        view.push(profileEditPage)
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
                    width: parent.width
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
}
