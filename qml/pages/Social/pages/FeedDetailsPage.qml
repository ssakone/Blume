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
    property var post: ({})
    property var comments: ({})
    property var likes: ({})
    property var author: ({})
    background: Rectangle {
        color: "white"
    }

    Component.onCompleted: console.log(post.pubkey)
    header: ToolBar {
        contentHeight: 60
        height: 70
        background: Rectangle {}
        RowLayout {
            y: 5
            spacing: 10
            width: parent.width - 40
            height: 70
            ToolBarButton {
                icon.source: Qaterial.Icons.arrowLeft
                onClicked: view.pop()
            }
            Avatar {
                id: _avatar
                height: 50
                width: 50
                source: currentProfile.picture
                avatarSize: 55
                onClicked: {
                    const data = root.author[post.pubkey] || {}
                    data["pubkey"] = post.pubkey
                    view.push(userProfile, {
                                  "profile": data
                              })
                }
            }
            Item {
                Layout.fillWidth: true
            }
            ColumnLayout {
                spacing: 1
                Label {
                    id: _nameLabel
                    text: currentProfile.name
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: "black"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            const data = root.author[post.pubkey] || {}
                            data["pubkey"] = post.pubkey
                            view.push(userProfile, {
                                          "profile": data
                                      })
                        }
                    }
                }
                Label {
                    text: root.timeAgoOrDate(post.created_at)
                    font.pixelSize: 12
                    font.bold: true
                    color: "#025d4b"
                }
            }
        }
    }

    Timer {
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            getComments(post)
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height
        color: "white"
        radius: 10

        Flickable {
            anchors.fill: parent
            contentHeight: _insideColumn.height
            Column {
                id: _insideColumn
                padding: 10
                spacing: 10
                width: parent.width

                Label {
                    id: content
                    color: "black"
                    width: _insideColumn.width - 20
                    padding: 5
                    font.pixelSize: 15
                    textFormat: Text.RichText
                    onLinkActivated: function (link) {
                        Qt.openUrlExternally(link)
                    }
                    wrapMode: Label.Wrap
                    Component.onCompleted: {
                        const data = captureLinks(post.content)
                        text = root.formatLinks(data[0])
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
                        videoOutput: videoOutput
                    }

                    VideoOutput {
                        id: videoOutput
                        anchors.fill: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log(_vid.source)
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
                                text: "%1 like".arg(page.likes.count)
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
                                text: "%1 comments".arg(page.comments.count)
                            }
                        }

                        height: 20
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    width: parent.width - 20
                    height: 2
                    color: "#eaeaea"
                }

                RowLayout {
                    spacing: 10
                    width: parent.width - 20
                    height: 40
                    Avatar {
                        height: 50
                        width: 50
                        source: userInfo.picture
                        avatarSize: 40
                    }
                    ColumnLayout {
                        spacing: 1
                        Label {
                            text: userInfo.name
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: "black"
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    width: parent.width - 20
                    InputField {
                        id: commentField
                        Layout.fillWidth: true
                        height: 40
                        font.pixelSize: 16
                        field.placeholderText: "Comment..."
                        field.placeholderTextColor: "#bfbfbf"
                        Keys.onReturnPressed: {
                            sendButton.clicked()
                        }
                    }
                    Qaterial.FabButton {
                        id: sendButton
                        icon.source: Qaterial.Icons.sendOutline
                        icon.width: 24
                        icon.height: 24
                        elevation: 0
                        implicitWidth: 40
                        implicitHeight: 40
                        visible: enabled
                        enabled: commentField.field.text.length > 0
                        onClicked: {
                            if (commentField.field.text.length === 0) {
                                return
                            }
                            let data = {
                                "id": post.id,
                                "pubkey": post.pubkey
                            }

                            const comment = commentField.field.text
                            Qt.callLater(function (message) {
                                http.replyPost(privateKey, data, message).then(
                                            function (result) {}).catch(
                                            function (error) {
                                                console.log(JSON.stringify(
                                                                error),
                                                            "comment")
                                            })
                            }, comment)
                            commentField.field.text = ""
                        }
                    }
                }

                Rectangle {
                    width: parent.width - 20
                    height: 2
                    color: "#eaeaea"
                }

                SortFilterProxyModel {
                    id: commentsProxyModel
                    sourceModel: post.comments

                    sorters: StringSorter {
                        roleName: "created_at"
                        sortOrder: Qt.DescendingOrder
                    }
                }

                Repeater {
                    model: commentsProxyModel
                    Column {
                        width: parent.width
                        RowLayout {
                            spacing: 10
                            width: parent.width - 20
                            height: 40
                            Avatar {
                                id: _avatar3
                                height: 50
                                width: 50
                                source: root.author[pubkey]?.picture || ""
                                avatarSize: 40
                                onClicked: {
                                    const data = root.author[pubkey] || {}
                                    data["pubkey"] = pubkey
                                    view.push(userProfile, {
                                                  "profile": data
                                              })
                                }
                            }
                            ColumnLayout {
                                spacing: 1
                                Label {
                                    id: _nameLabel3
                                    text: root.author[pubkey]?.name
                                          || pubkey.slice(0, 8)
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: "black"
                                    Connections {
                                        target: root
                                        function onAuthorAdded(pubc) {
                                            Qt.callLater(function (pubk) {
                                                if (pubkey === pubk) {
                                                    _nameLabel3.text = root.author[pubkey].name
                                                            || ""
                                                    _avatar3.source = root.author[pubkey].picture
                                                            || ""
                                                }
                                            }, pubc)
                                        }
                                    }

                                    Component.onCompleted: {
                                        $Services.getPubKeyInfo(
                                                    pubkey, function (info) {
                                                        if (info !== undefined) {
                                                            _nameLabel3.text = info.name
                                                                    || ""
                                                            _avatar3.source = info.picture
                                                                    || ""
                                                        }
                                                    })
                                    }
                                }
                                Label {
                                    text: root.timeAgoOrDate(created_at)
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#025d4b"
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                        Text {
                            padding: 10
                            width: parent.width - 20
                            wrapMode: Text.Wrap
                            text: content
                            textFormat: Text.RichText
                            onLinkActivated: function (link) {
                                Qt.openUrlExternally(link)
                            }

                            Component.onCompleted: {
                                const data = captureLinks(content)
                                text = root.formatLinks(data[0])
                                if (data[2].length > 0) {
                                    _vid2.source = data[2][0]
                                    _vidArea2.visible = true
                                } else if (data[1].length > 0) {
                                    _im2.source = data[1][0]
                                    _imArea2.visible = true
                                }
                            }
                        }
                        RadiusImage {
                            id: _imArea2
                            width: parent.width - 20
                            height: _im2.height
                            visible: false
                            Image {
                                id: _im2
                                width: parent.width
                                asynchronous: false
                                cache: false
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        RadiusImage {
                            id: _vidArea2
                            visible: false
                            width: parent.width - 20
                            height: visible ? 200 : 0
                            Rectangle {
                                anchors.fill: parent
                                color: "black"
                            }

                            MediaPlayer {
                                id: _vid2
                                //source: "https://www.w3schools.com/html/mov_bbb.mp4"
                                videoOutput: videoOutput2
                                audioOutput: AudioOutput {
                                    volume: 1
                                }
                            }

                            VideoOutput {
                                id: videoOutput2
                                anchors.fill: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    _vid2.play()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
