import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qaterial as Qaterial

import SortFilterProxyModel

import "../components"

Page {
    id: page
    property string blumePubkey: "a679fc5649038435d17f1ce17e38249ccee1dc3faad47d5c7795d27de942de42"
    property string botanistPubkey: "5ba9e7d4ca123a656845c0a6883d79652c71440d22d3636ef2f39c806de7b48c"

    function reloadDiscussions() {
        localMessagesModel.clear()
        const listMessages = Object.keys(realDiscussions).filter(key => realDiscussions[key].locuter !== blumePubkey && realDiscussions[key].locuter !== botanistPubkey)
        const size = listMessages.length
        for(let i = 0; i<size; i++) {
            const key = listMessages[i]
            localMessagesModel.append(realDiscussions[key])
        }
    }
    onFocusChanged: {
        if(focus) {
            searchInput.text = ""
            inputBackBtn.clicked()
        }
    }

    background: Rectangle {
        color: $Colors.colorPrimary
    }

    Timer {
        id: timerReload
        interval: 3000
        repeat: true
        onTriggered: reloadDiscussions()

    }

    ListModel {
        id: localMessagesModel
        Component.onCompleted: {
            reloadDiscussions()
            timerReload.start()
        }
    }

    SortFilterProxyModel {
        id: filterMessagesModel
        sourceModel: localMessagesModel
        filters: ExpressionFilter {
            expression: {
                return searchInput.text ? Boolean((root.author[locuter]?.name?.toLowerCase()?.includes(searchInput.text.toLowerCase()) || root.author[locuter]?.username?.toLowerCase()?.includes(searchInput.text))) : true
            }
        }
        sorters: StringSorter {
            roleName: "mostRecent"
            sortOrder: Qt.DescendingOrder
        }
    }

    header: ToolBar {
        contentHeight: 60
        height: 65
        background: Rectangle {
            color: $Colors.colorPrimary
        }
        RowLayout {
            width: parent.width - 30
            height: 60
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 10

            RowLayout {
                id: globalBackBtn
                Layout.fillWidth: true

                IconImage {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: width
                    source: Qaterial.Icons.chevronLeftCircleOutline
                    color: $Colors.white
                    Layout.alignment: Qt.AlignVCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            view.pop()
                        }
                    }

                }

                Label {
                    text: searchInput.text ? qsTr("Results for '%1'").arg(searchInput.text) : qsTr("Messages")
                    Layout.fillWidth: true
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    elide: Label.ElideRight
                    color: Qaterial.Colors.gray100
                    Layout.alignment: Qt.AlignVCenter
                }

            }


            ToolBarButton {
                id: inputBackBtn
                visible: false
                Layout.preferredHeight: 45
                Layout.preferredWidth: 45
                icon {
                    source: Qaterial.Icons.chevronLeft
                    color: $Colors.white
                }
                onClicked: {
                    visible = false
                    spacer.visible = true
                    globalBackBtn.visible = true
                    searchBtn.visible = true
                    //searchInput.text = ""
                    searchInput.visible = false
                    searchInput.focus = false
                }
            }



            TextField {
                id: searchInput
                property bool busy: false
                visible: false
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 16
                padding: 5
                leftPadding: 10
                rightPadding: 10
                color: "white"
                placeholderText: qsTr("Search")
                placeholderTextColor: "white"
                background: Rectangle {
                    gradient: $Colors.gradientPrimary
                    radius: 25
                }

                BusyIndicator {
                    running: searchInput.busy
                    width: 30
                    height: width
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 15
                    }
                }
            }

            Item {
                id: spacer
                visible: true
                Layout.fillWidth: true
            }

            ToolBarButton {
                id: searchBtn
                visible: true
                Layout.preferredHeight: 30
                Layout.preferredWidth: 30
                icon.source: Qaterial.Icons.magnify
                icon.color: Qaterial.Colors.white
                onClicked: {
                    visible = false
                    spacer.visible = false
                    globalBackBtn.visible = false
                    inputBackBtn.visible = true
                    searchInput.visible = true
                    searchInput.focus = true
                    //searchInput.text = ""
                    mouseContext.enabled = true
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

        MouseArea {
            id: mouseContext
            enabled: false
            anchors.fill: parent
            onClicked: {
                inputBackBtn.clicked()
                enabled = false
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            Column {
                id: pinedDiscColumn
                visible: !searchInput.focus //searchInput.text === ""
                Layout.fillWidth: true
                spacing: 15
                Label {
                    text: qsTr("Conversation avec Blume")
                    font {
                        pixelSize: 18
                        weight: Font.DemiBold
                    }
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Row {
                    spacing: 25
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        model: [
                            {
                                "is_pined": true,
                                "name": "Blume AI",
                                "picture": "http://34.28.201.80//get_file/68d2f1dd-4c41-437e-85a8-77f77f66b256.jpg",
                                "pubkey": blumePubkey,
                                "username": "blumeai"
                            },
                            {
                                "is_pined": true,
                                "name": "Mon botaniste",
                                "picture": "qrc:/assets/icons_custom/my-botanist.png",
                                "pubkey": botanistPubkey,
                                "username": "botanist"
                            }
                        ]

                        Column {

                            Item {
                                width: 60
                                height: width
                                //radius: height/2

                                Avatar {
                                    anchors.fill: parent
                                    source: modelData.picture
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
            }


            Qaterial.ClipRRect {
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: 40
                clip: true

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    radius: parent.radius
                    color: "white"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        Item {
                            Layout.preferredHeight: 30
                            width: 1
                        }

                        ListView {
                            id: listView
                           Layout.fillWidth: true
                           Layout.fillHeight: true
                            model: filterMessagesModel
                            delegate: Rectangle {
                                required property var model
                                required property int index
                                property var modelData: filterMessagesModel.get(index)
                                property string pubkey: modelData.locuter
                                width: listView.width
                                height: insideCol.height
                                color: area.containsPress ? "#f2f2f2" : "white"

                                Column {
                                    id: insideCol
                                    width: parent.width
                                    padding: 10
                                    RowLayout {
                                        width: parent.width - 20
                                        anchors.leftMargin: 35
                                        spacing: 10
                                        Avatar {
                                            id: _avatar
                                            Layout.preferredHeight: 60
                                            Layout.preferredWidth: 60
                                            avatarSize: 60
                                        }
                                        Column {
                                            Layout.fillWidth: true
                                            spacing: 0
                                            Label {
                                                id: _nameLabel
                                                text: modelData.locuter
                                                width: parent.width
                                                elide: Label.ElideRight
                                                font.pixelSize: 20
                                                font.weight: Font.Bold
                                                color: "black"
                                                Connections {
                                                    target: root
                                                    function onAuthorAdded(pubc) {
                                                        Qt.callLater(function (pubk) {
                                                            if (modelData.locuter === pubk) {
                                                                _nameLabel.text = root.author[pubk].name
                                                                        || ""
                                                                _avatar.source = root.author[pubk].picture
                                                                        || Qaterial.Icons.faceProfile
                                                            }
                                                        }, pubc)
                                                    }
                                                }

                                                Component.onCompleted: {
                                                    let author_pub = modelData.locuter
                                                    $Services.getPubKeyInfo(modelData.locuter,
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
                                                text: lastMessageText
                                                width: parent.width
                                                elide: Label.ElideRight
                                                font.pixelSize: 16
                                                color: "#767676"
                                                Component.onCompleted: {
                                                    for (let i = 0; i < modelData.model.count; i++) {
                                                        const metaData = modelData.model.get(i)
                                                        if (metaData.created_at === modelData.mostRecent) {
                                                            lastMessageText = metaData.content?.slice(0, 4) === "http" ? qsTr("File") : metaData.content
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Label {
                                        id: dateLabel

                                        text: root.timeAgoOrDate(modelData.mostRecent)
                                        font.pixelSize: 12
                                        color: "#767676"
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                    }
                                }


                                MouseArea {
                                    id: area
                                    anchors.fill: parent
                                    onClicked: {
                                        let friend = root.author[modelData.locuter] || {}
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
            onClicked: view.push(contacPickPage)
        }
    }
}
