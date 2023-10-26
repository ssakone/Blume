import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qaterial as Qaterial

import SortFilterProxyModel

import "../components"

Page {
    background: Rectangle {
        color: $Colors.colorPrimary
    }

    header: ToolBar {
        contentHeight: 60
        height: 65
        background: Rectangle {
            color: $Colors.colorPrimary
        }
        RowLayout {
            anchors.fill: parent
            spacing: 0
            ToolBarButton {
                icon.source: Qaterial.Icons.chevronLeft
                icon.color: $Colors.white
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
                    color: $Colors.white
                }
            }
        }
    }

    Rectangle {
        anchors {
            fill: parent
            topMargin: 30
        }
        color: $Colors.gray100
        radius: 20
        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            Label {
                text: qsTr("Conversation avec Blume")
                font {
                    pixelSize: 18
                    weight: Font.DemiBold
                }
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter
            }
            Row {
                spacing: 25
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: [
                        {
                            "is_pined": true,
                            "name": "Blume AI",
                            "profile": {
                                "name": "Blume AI",
                                "picture": "qrc:/assets/icons_custom/blumai.svg"
                            },
                            "pubkey": "a679fc5649038435d17f1ce17e38249ccee1dc3faad47d5c7795d27de942de42",
                            "username": "blumeai"
                        }

                    ]

                    Column {

                        Rectangle {
                            width: 60
                            height: width
                            radius: height/2

                            IconImage {
                                anchors.fill: parent
                                source: Qaterial.Icons.robot
                                color: $Colors.colorPrimary

                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: view.push(messagePage, {
                                    "friend": modelData,
                                    "isBotMode": true
                                })
                            }
                        }


                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: 12
                            text: modelData.name
                        }

                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    radius: 40

                    color: "white"

                    ColumnLayout {
                        width: parent.width
                        spacing: 10

                        Label {
                            text: qsTr("My friends")
                            color: $Colors.colorPrimary
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 20
                            font {
                                pixelSize: 16
                                weight: Font.DemiBold
                            }
                        }

                        ListView {
                           Layout.fillWidth: true
                           Layout.fillHeight: true
                            model: Object.keys(realDiscussions)
                            delegate: Rectangle {
                                property var model: realDiscussions[modelData]
                                property string pubkey: model.locuter
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
                                            text: model.locuter.slice(0, 16) + "..."
                                            font.pixelSize: 20
                                            font.weight: Font.Bold
                                            color: "black"
                                            Connections {
                                                target: root
                                                function onAuthorAdded(pubc) {
                                                    Qt.callLater(function (pubk) {
                                                        if (model.locuter === pubk) {
                                                            _nameLabel.text = root.author[pubk].name
                                                                    || ""
                                                            _avatar.source = root.author[pubk].picture
                                                                    || Qaterial.Icons.faceProfile
                                                        }
                                                    }, pubc)
                                                }
                                            }

                                            Component.onCompleted: {
                                                let author_pub = model.locuter
                                                $Services.getPubKeyInfo(model.locuter,
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
                                        let friend = root.author[model.locuter] || {}
                                        friend["pubkey"] = pubkey

                                        view.push(messagePage, {
                                                      "friend": friend
                                                  })
                                    }
                                }
                            }
                        }

                    }

                }
            }
        }
    }

    Rectangle {
        width: 60
        height: width
        radius: 20
        anchors {
            bottom: parent.bottom
            bottomMargin: 10

            right: parent.right
            rightMargin: 10
        }
        color: $Colors.colorPrimary
        IconImage {
            anchors.centerIn: parent
            source: Qaterial.Icons.messageOutline
            color: "white"
        }
        MouseArea {
            anchors.fill: parent
        }
    }
}
