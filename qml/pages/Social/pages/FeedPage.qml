import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebSockets
import QtMultimedia

import Qaterial as Qaterial

import SortFilterProxyModel

import "../components"

Page {
    background: Rectangle {
        color: "white"
    }
    header: ToolBar {
        contentHeight: 60
        height: 65
        background: Rectangle {
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                opacity: .2
                color: "#025d4b"
            }
        }
        RowLayout {
            anchors.fill: parent
            spacing: 0
            IconImage {
                Layout.leftMargin: 15
                source: Qaterial.Icons.close
                color: $Colors.colorPrimary
                MouseArea {
                    anchors.fill: parent
                    onClicked: page_view.pop()
                }
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: feedListView.height + 20
        Column {
            id: feedListView
            spacing: 20
            topPadding: 10
            width: parent.width
            Flickable {
                width: parent.width
                height: 120
                contentWidth: _insideRow.width + 10
                contentHeight: height
                Row {
                    id: _insideRow
                    leftPadding: 20
                    rightPadding: 20
                    spacing: 10
                    height: 120
                    Repeater {
                        model: root.friendLists
                        Column {
                            visible: modelData["pubkey"] !== publicKey
                            Avatar {
                                height: 100
                                width: 100
                                avatarSize: 80
                                source: JSON.parse(modelData["profile"]
                                                   || "{}").picture
                                        || Qaterial.Icons.faceManProfile
                                anchors.horizontalCenter: parent.horizontalCenter
                                onClicked: {
                                    const data = JSON.parse(
                                                   modelData["profile"] || "{}")
                                    data["pubkey"] = modelData["pubkey"]
                                    view.push(userProfile, {
                                                  "profile": data
                                              })
                                }
                            }
                            Label {
                                text: modelData["name"]
                                font.pixelSize: 12
                                font.bold: true
                                color: "#025d4b"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            Repeater {
                model: eventsProxy
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: feedListView.width - 40
                    height: _insideColumn.height
                    color: "white"
                    border.color: Qaterial.Colors.gray400
                    radius: 10
                    layer.enabled: true

                    function showProfile() {
                        let data = root.author[pubkey]
                        data["pubkey"] = pubkey
                        view.push(userProfile, {
                                      "profile": data
                                  })
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentProfile = {
                                "name": root.author[pubkey].name,
                                "picture": root.author[pubkey].picture,
                                "pubkey": pubkey
                            }

                            view.push(feedDetailsPage, {
                                          "post": model,
                                          "comments": comments,
                                          "likes": likes
                                      })
                        }
                    }

                    Column {
                        id: _insideColumn
                        padding: 10
                        spacing: 10
                        width: parent.width
                        RowLayout {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 20
                            width: parent.width - 40
                            height: 60
                            Avatar {
                                id: _avatar
                                height: 50
                                width: 50
                                avatarSize: 55
                                onClicked: showProfile()
                            }
                            ColumnLayout {
                                spacing: 1

                                Label {
                                    id: _nameLabel
                                    Connections {
                                        target: root
                                        function onAuthorAdded(pubc) {
                                            Qt.callLater(function (pubk) {
                                                if (pubkey === pubk) {
                                                    _nameLabel.text = root.author[pubkey].name
                                                            || ""
                                                    _avatar.source = root.author[pubkey].picture
                                                            || Qaterial.Icons.faceProfile
                                                }
                                            }, pubc)
                                        }
                                    }

                                    Component.onCompleted: {
                                        $Services.getPubKeyInfo(
                                                    pubkey, function (info) {
                                                        if (info !== undefined) {
                                                            _nameLabel.text = info.name
                                                                    || ""
                                                            _avatar.source = info.picture
                                                                    || Qaterial.Icons.faceProfile
                                                        }
                                                    })
                                    }

                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: "black"
                                }
                                Label {
                                    text: root.timeAgoOrDate(created_at)
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#025d4b"
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        Label {
                            topPadding: -5
                            text: content //"Lorem 2 ipsum dolor sit amet, consectetur adipiscing elit. nisl odio aliquet arcu, sed dapibus elit nisl vitae magna. Donec euismod, nisl odio aliquet arcu, sed dapibus elit nisl vitae magna. Donec euismod, ligula vitae aliquam semper, nisl odio aliquet arcu, sed dapibus elit nisl vitae magna."
                            color: "black"
                            width: _insideColumn.width - 20
                            padding: 5
                            font.pixelSize: 15
                            wrapMode: Label.Wrap

                            Component.onCompleted: {
                                const data = captureLinks(content)
                                text = data[0]
                                if (data[2].length > 0) {
                                    _vid.source = data[2][0]
                                    _vidArea.visible = true
                                } else if (data[1].length > 0) {
                                    _im.source = data[1][0]
                                    _imArea.visible = true
                                }
                            }
                        }

                        RadiusImage {
                            id: _imArea
                            width: _insideColumn.width - 20
                            height: _im.height
                            visible: false
                            Image {
                                id: _im
                                width: parent.width
                                asynchronous: false
                                cache: false
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        RadiusImage {
                            id: _vidArea
                            visible: false
                            width: _insideColumn.width - 20
                            height: visible ? 200 : 0
                            Rectangle {
                                anchors.fill: parent
                                color: "black"
                            }

                            MediaPlayer {
                                id: _vid
                                //source: "https://www.w3schools.com/html/mov_bbb.mp4"
                                videoOutput: videoOutput
                            }

                            VideoOutput {
                                id: videoOutput
                                anchors.fill: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    _vid.play()
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width - 30
                            Item {
                                Row {
                                    spacing: 5
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Qaterial.Icon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: Qaterial.Icons.heartOutline
                                        size: 18
                                    }

                                    Qaterial.Label {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "%1 like".arg(likes.count)
                                    }
                                }

                                height: 20
                                Layout.fillWidth: true
                            }

                            Item {
                                Row {
                                    spacing: 5
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Qaterial.Icon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: Qaterial.Icons.commentTextOutline
                                        size: 18
                                    }

                                    Qaterial.Label {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "%1 comments".arg(comments.count)
                                    }
                                }

                                height: 20
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }

    Qaterial.FabButton {
        width: 65
        height: 65
        elevation: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.right: parent.right
        anchors.rightMargin: 15
        icon.source: Qaterial.Icons.plus
        icon.color: 'white'
        icon.width: 28
        icon.height: 28
        onClicked: view.push(postEditPage)
    }

    footer: Rectangle {
        height: 65
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                backgroundColor: Qaterial.Colors.teal100
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    color: parent.foregroundColor
                    icon: Qaterial.Icons.homeOutline
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    color: parent.foregroundColor
                    icon: Qaterial.Icons.messageOutline
                }
                onClicked: view.push(messageList)
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    color: parent.foregroundColor
                    icon: Qaterial.Icons.heartOutline
                }
                onClicked: view.push(findUser)
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    color: parent.foregroundColor
                    icon: Qaterial.Icons.accountOutline
                }
                onClicked: {
                    let data = userInfo || {}
                    data["pubkey"] = publicKey
                    view.push(userProfile, {
                                  "profile": data
                              })
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            color: "#e0e0e0"
        }
    }
}
