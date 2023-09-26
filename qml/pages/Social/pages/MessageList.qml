import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
                    text: qsTr("Messages")
                }
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: Object.keys(realDiscussions)
        delegate: Rectangle {
            property var model: realDiscussions[modelData]
            property string pubkey: model.pubkey
            width: parent.width
            height: 80
            color: area.containsPress ? "#f2f2f2" : "white"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 35
                spacing: 30
                Avatar {
                    id: _avatar
                    height: 60
                    width: 60
                    Layout.preferredWidth: 30
                    avatarSize: 60
                }
                ColumnLayout {
                    Layout.fillHeight: true
                    spacing: 5
                    Label {
                        id: _nameLabel
                        text: pubkey.slice(0, 16) + "..."
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: "black"
                        Connections {
                            target: root
                            function onAuthorAdded(pubc) {
                                Qt.callLater(function (pubk) {
                                    if (pubkey === pubk) {
                                        _nameLabel.text = root.author[pubkey].name
                                                || ""
                                        if (root.author[pubkey].picture?.length
                                                || 0 > 10)
                                            _avatar.source = root.author[pubkey].picture
                                                    || ""
                                    }
                                }, pubc)
                            }
                        }

                        Component.onCompleted: {
                            $Services.getPubKeyInfo(pubkey, function (info) {
                                if (info !== undefined) {
                                    _nameLabel.text = info.name || ""
                                    _avatar.source = info.picture || ""
                                }
                            })
                        }
                    }
                    Label {
                        id: lastMessage
                        property string lastMessageText: ""
                        text: lastMessageText.length > 27 ? lastMessageText.slice(
                                                                0,
                                                                27) + "..." : lastMessageText
                        font.pixelSize: 16
                        color: "#767676"
                        Component.onCompleted: {
                            for (var i = 0; i < model.model.count; i++) {
                                console.log(model.model.get(i).created_at,
                                            model.mostRecent)
                                if (model.model.get(
                                            i).created_at === model.mostRecent) {
                                    lastMessageText = model.model.get(i).content
                                    break
                                }
                            }
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
            Item {
                anchors.right: parent.right
                anchors.rightMargin: 10
                height: parent.height
                width: dateLabel.width + 10
                Label {
                    id: dateLabel

                    text: root.timeAgoOrDate(model.mostRecent)
                    font.pixelSize: 12
                    color: "#767676"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -5
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: 30
                    height: 30
                    radius: 10
                    visible: false
                    color: "#004b00"
                    Label {
                        anchors.centerIn: parent
                        text: "1"
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }
                }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                onClicked: {
                    let friend = root.author[pubkey] || {}
                    friend["pubkey"] = pubkey

                    view.push(messagePage, {
                                  "friend": friend
                              })
                }
            }
        }
    }
}
