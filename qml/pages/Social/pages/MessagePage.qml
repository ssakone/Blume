import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SortFilterProxyModel
import QtWebSockets
import Qaterial as Qaterial
import "../components"

Page {
    id: page
    property var friend: ({})
    background: Rectangle {
        color: "white"
    }

    Component.onCompleted: {
        messages.clear()
        if (root.messagesRelay.status !== WebSocket.Open) {
            root.messagesRelay.active = false
            root.messagesRelay.active = true
        }

        Qt.callLater(() => root.getMessage(friend.pubkey))
    }

    Timer {
        running: true
        interval: 500
        repeat: true
        onTriggered: {
            root.getMessage(friend.pubkey)
        }
    }

    SortFilterProxyModel {
        id: messageModel
        sourceModel: messages

        sorters: StringSorter {
            roleName: "created_at"
            sortOrder: Qt.DescendingOrder
        }

        filters: ExpressionFilter {
            expression: model.pubkey === publicKey
                        || model.pubkey === page.friend.pubkey
        }
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
            Avatar {
                height: 60
                width: 60
                source: page.friend.picture || ""
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    leftPadding: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    text: page.friend.name || friend.pubkey.slice(
                              0, 18) + "..." || ""
                }
            }
        }
    }
    Item {
        anchors.fill: parent
        ListView {
            id: chatView
            anchors.fill: parent
            anchors.rightMargin: 5
            anchors.margins: 10
            spacing: 10
            verticalLayoutDirection: ListView.BottomToTop

            model: messageModel

            delegate: Rectangle {
                property bool current: pubkey === publicKey
                id: control
                width: (chatView.width / 2) + chatView.width / 4
                height: contentColumn.height + 4
                radius: 10
                x: current ? chatView.width - width - 10 : 0
                gradient: Gradient {
                    GradientStop {
                        position: 0.00
                        color: current ? "#d9fdd2" : "#f5f6f6"
                    }
                    GradientStop {
                        position: 1.00
                        color: current ? "#d9fdd2" : "#f5f6f6"
                    }
                }

                Column {
                    id: contentColumn
                    width: parent.width
                    RowLayout {
                        width: parent.width
                        Text {
                            id: _text
                            padding: 10
                            text: content
                            horizontalAlignment: current ? Text.AlignRight : Text.AlignLeft
                            Layout.fillWidth: true
                            Layout.alignment: current ? Qt.AlignRight : Qt.AlignLeft
                            Layout.preferredWidth: implicitWidth
                            wrapMode: Text.Wrap
                            color: "black"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                        }
                    }

                    Text {
                        text: "%1 <b><strong>%2</strong></b>".arg(
                                  root.timeAgoOrDate(created_at)).arg(
                                  model.id === "TEMP" ? "⏱" : "✓")
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        opacity: .6
                    }
                }
            }
        }
    }
    footer: ToolBar {
        contentHeight: 60
        height: 65
        background: Rectangle {}
        RowLayout {
            anchors.fill: parent
            spacing: 0
            MouseArea {
                height: 50
                width: 50
                visible: false
                Rectangle {
                    width: 40
                    height: 40
                    anchors.centerIn: parent
                    radius: 30
                    color: "transparent"
                    ColorImage {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        opacity: .8
                        source: `data:image/svg+xml,%3Csvg xmlns="http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg" width="24" height="24" viewBox="0 0 24 24"%3E%3Cg fill="%23676767" fill-rule="evenodd" clip-rule="evenodd"%3E%3Cpath d="M2 12C2 6.477 6.477 2 12 2s10 4.477 10 10s-4.477 10-10 10S2 17.523 2 12Zm10-8a8 8 0 1 0 0 16a8 8 0 0 0 0-16Z"%2F%3E%3Cpath d="M13 7a1 1 0 1 0-2 0v4H7a1 1 0 1 0 0 2h4v4a1 1 0 1 0 2 0v-4h4a1 1 0 1 0 0-2h-4V7Z"%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E`
                    }
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 24
                    id: textArea
                    TextField {
                        id: inputField
                        background: Rectangle {
                            radius: 24
                            color: "#e2e0dc"
                        }
                        font.pixelSize: 22
                        color: "black"
                        anchors.fill: parent
                        padding: 10
                        topPadding: 11
                        leftPadding: 14
                        rightPadding: 14
                        Keys.onReturnPressed: {
                            sendButton.clicked()
                        }
                    }
                }
                Row {
                    visible: !inputField.focus
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 24
                    spacing: 10
                    ColorImage {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        source: `data:image/svg+xml,%3Csvg xmlns="http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg" width="24" height="24" viewBox="0 0 24 24"%3E%3Cpath fill="none" stroke="%23676767" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9h8m-8 4h6m-5 5H6a3 3 0 0 1-3-3V7a3 3 0 0 1 3-3h12a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3h-3l-3 3l-3-3z"%2F%3E%3C%2Fsvg%3E`
                    }

                    Label {
                        text: "Type something"
                        anchors.verticalCenter: parent.verticalCenter
                        color: Qt.darker("#ccc")
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                }
            }
            ToolBarButton {
                id: sendButton
                enabled: inputField.text.length > 0
                icon.source: Qaterial.Icons.send
                icon.color: "#004b00"
                onClicked: {
                    if (inputField.text.length === 0)
                        return
                    let cdata = {
                        "id": "TEMP",
                        "content": inputField.text,
                        "pubkey": publicKey,
                        "removable": true,
                        "created_at": new Date().getTime() / 1000
                    }
                    messages.append(cdata)
                    Qt.callLater(function (content) {
                        http.sendMessage(privateKey, page.friend.pubkey,
                                         content).then(function (rs) {}).catch(
                                    function (err) {
                                        console.log(JSON.stringify(err))
                                    })
                    }, inputField.text)
                    inputField.text = ""
                }
            }
        }
    }
}
