import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia

import SortFilterProxyModel

import "../components"

Page {
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
                    text: qsTr("Relation")
                }
            }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 0
        Qaterial.LatoTabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Qaterial.LatoTabButton {
                text: "Abonnements"
            }
            Qaterial.LatoTabButton {
                text: "Chercher"
            }
        }

        SwipeView {
            currentIndex: tabBar.currentIndex
            interactive: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            Item {
                ListView {
                    id: friendListView
                    anchors.fill: parent
                    header: Item {
                        width: parent.width
                        height: 0
                        visible: false
                        RowLayout {
                            anchors.fill: parent
                            ButtonImage {
                                visible: false
                                source: `data:image/svg+xml,%3Csvg xmlns="http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg" width="48" height="48" viewBox="0 0 48 48"%3E%3Cg fill="none" stroke="gray" stroke-linejoin="round" stroke-width="4"%3E%3Cpath d="M21 38c9.389 0 17-7.611 17-17S30.389 4 21 4S4 11.611 4 21s7.611 17 17 17Z"%2F%3E%3Cpath stroke-linecap="round" d="M26.657 14.343A7.975 7.975 0 0 0 21 12a7.975 7.975 0 0 0-5.657 2.343m17.879 18.879l8.485 8.485"%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E`
                            }

                            InputField {
                                Layout.fillWidth: true
                                height: 45
                                font.pixelSize: 16
                                field.placeholderText: "Rechercher..."
                                field.placeholderTextColor: "#bfbfbf"
                            }
                        }
                    }

                    Connections {
                        target: root
                        function onFriendListUpdated() {
                            friendListView.model = []
                            friendListView.model = contacts[publicKey]
                        }
                    }

                    model: contacts[publicKey]
                    delegate: Rectangle {
                        width: parent.width
                        height: 70
                        radius: 10
                        color: area.containsMouse
                               || area.containsPress ? "#f2f2f2" : "white"

                        MouseArea {
                            id: area
                            hoverEnabled: true
                            anchors.fill: parent
                            onClicked: {
                                let data = root.author[modelData[1]] || {}
                                data["pubkey"] = modelData[1]
                                view.push(userProfile, {
                                              "profile": data
                                          })
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Avatar {
                                id: _avatar
                                height: 50
                                width: 50
                                avatarSize: 40
                            }
                            ColumnLayout {
                                spacing: 1
                                Label {
                                    id: _nameLabel
                                    text: modelData[1].slice(0, 18) + "..."
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: "black"
                                    Connections {
                                        target: root
                                        function onAuthorAdded(pubc) {
                                            Qt.callLater(function (pubk) {
                                                if (modelData[1] === pubk) {
                                                    _nameLabel.text = root.author[modelData[1]].name
                                                            || ""
                                                    _avatar.source
                                                            = root.author[modelData[1]].picture
                                                            || ""
                                                }
                                            }, pubc)
                                        }
                                    }

                                    Component.onCompleted: {
                                        $Services.getPubKeyInfo(
                                                    modelData[1],
                                                    function (info) {
                                                        if (info !== undefined) {
                                                            _nameLabel.text = info.name
                                                                    || ""
                                                            _avatar.source = info.picture
                                                                    || ""
                                                        }
                                                    })
                                    }
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            Item {
                ListView {
                    id: searchContact
                    anchors.fill: parent
                    header: Item {
                        width: parent.width
                        height: 50
                        visible: true
                        RowLayout {
                            anchors.fill: parent
                            ButtonImage {
                                visible: false
                                source: `data:image/svg+xml,%3Csvg xmlns="http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg" width="48" height="48" viewBox="0 0 48 48"%3E%3Cg fill="none" stroke="gray" stroke-linejoin="round" stroke-width="4"%3E%3Cpath d="M21 38c9.389 0 17-7.611 17-17S30.389 4 21 4S4 11.611 4 21s7.611 17 17 17Z"%2F%3E%3Cpath stroke-linecap="round" d="M26.657 14.343A7.975 7.975 0 0 0 21 12a7.975 7.975 0 0 0-5.657 2.343m17.879 18.879l8.485 8.485"%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E`
                            }

                            InputField {
                                property bool busy: false
                                Layout.fillWidth: true
                                height: 45
                                font.pixelSize: 16
                                field.placeholderText: "Rechercher..."
                                field.placeholderTextColor: "#bfbfbf"
                                field.onTextChanged: {
                                    busy = true
                                    http.searchProfile(field.text).then(
                                                function (res) {
                                                    searchContact.model = JSON.parse(
                                                                res)
                                                    busy = false
                                                }).catch(function (err) {
                                                    console.log(err)
                                                }).finally(function () {
                                                    busy = false
                                                })
                                }

                                BusyIndicator {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin: 10
                                    width: 20
                                    running: parent.busy
                                }
                            }
                        }
                    }
                    delegate: Rectangle {
                        width: parent.width
                        height: 70
                        radius: 10
                        color: area2.containsMouse
                               || area2.containsPress ? "#f2f2f2" : "white"

                        MouseArea {
                            id: area2
                            hoverEnabled: true
                            anchors.fill: parent
                            onClicked: {
                                let data = root.author[modelData["pubkey"]]
                                    || {}
                                data["pubkey"] = modelData["pubkey"]
                                view.push(userProfile, {
                                              "profile": data
                                          })
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Avatar {
                                id: _avatar2
                                height: 50
                                width: 50
                                avatarSize: 40
                            }
                            ColumnLayout {
                                spacing: 1
                                Label {
                                    id: _nameLabel2
                                    text: modelData["pubkey"].slice(0,
                                                                    18) + "..."
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: "black"
                                    Connections {
                                        target: root
                                        function onAuthorAdded(pubc) {
                                            Qt.callLater(function (pubk) {
                                                if (modelData[1] === pubk) {
                                                    _nameLabel2.text
                                                            = root.author[modelData["pubkey"]].name
                                                            || ""
                                                    _avatar2.source = root.author[modelData["pubkey"]].picture
                                                            || ""
                                                }
                                            }, pubc)
                                        }
                                    }

                                    Component.onCompleted: {
                                        $Services.getPubKeyInfo(
                                                    modelData["pubkey"],
                                                    function (info) {
                                                        if (info !== undefined) {
                                                            _nameLabel2.text = info.name
                                                                    || ""
                                                            _avatar2.source = info.picture
                                                                    || ""
                                                        }
                                                    })
                                    }
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
