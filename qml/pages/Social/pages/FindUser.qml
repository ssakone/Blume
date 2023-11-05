import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SortFilterProxyModel
import Qaterial as Qaterial
import "../components"

Page {
    id: page

    property string filterBy: "all"
    function checkFollow(pubkey) {
        if (pubkey !== publicKey) {
            if (root.contacts[publicKey] === undefined) {
                root.contacts[publicKey] = []
            }
            for(let i = 0; i<root.contacts[publicKey].length; i++) {
                if (root.contacts[publicKey][i][1] === pubkey) {
                    return true
                }
            }
        }

        return false
    }

    function follow(pubkey) {
        return new Promise(function (resolve, reject) {
            http.addContact(privateKey, contacts[publicKey] || [], pubkey).then(
            function (rs) {
                console.log(rs)
                if (rs === "ok") {
                    resolve()
                    getContact(publicKey)
                } else {
                    reject(rs)
                }
            }).catch(function (err) {
                console.log(JSON.stringify(err))
                reject(err)
            })

        })
    }

    function reloadDefaultFriendsList() {
        localFriendsModel.clear()
        const dataset = friendLists.filter(f => f.is_pined !== true && f.pubkey !== publicKey)
        const size = dataset.length
        for(let i = 0; i<size; i++) {
            localFriendsModel.append(dataset[i])
        }
    }

    state: filterBy

    ListModel {
        id: localFriendsModel
        Component.onCompleted: reloadDefaultFriendsList()
    }

    SortFilterProxyModel {
        id: filteredFriendsModel
        sourceModel: localFriendsModel
        filters: ExpressionFilter {
            expression: {
                return filterBy === "friends" ? page.checkFollow(pubkey) : true
            }
        }
    }

    states: [
        State {
            name: "all"
            PropertyChanges {
                target: textFilterAll
                color: "white"
                background {
                    color: $Colors.colorPrimary
                }
            }
            PropertyChanges {
                target: textFilterFriends
                color: $Colors.gray600
                background {
                    border {
                        width: 1
                        color: $Colors.colorPrimary
                    }
                }
            }
        },
        State {
            name: "friends"
            PropertyChanges {
                target: textFilterAll
                color: $Colors.gray600
                background {
                    border {
                        width: 1
                        color: $Colors.colorPrimary
                    }
                }
            }
            PropertyChanges {
                target: textFilterFriends
                color: "white"
                background {
                    color: $Colors.colorPrimary
                }
            }
        }
    ]


    ColumnLayout {
        anchors.fill: parent
        Column {
            id: headerColumn
            Layout.fillWidth: true
            leftPadding: 5
            rightPadding: 5
            topPadding: 10
            bottomPadding: 25
            spacing: 20
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
                        Layout.alignment: Qt.AlignVCenter
                        source: Qaterial.Icons.chevronLeftCircleOutline
                        color: $Colors.colorPrimary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                view.pop()
                            }
                        }

                    }

                    Label {
                        text: searchInput.text.length === 0 ? qsTr("Search") : qsTr("Results for '%1").arg(searchInput.text)
                        font.pixelSize: 18
                        color: Qaterial.Colors.gray600
                        Layout.fillWidth: true
                        elide: Label.ElideRight
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
                        color: $Colors.colorPrimary
                    }
                    onClicked: {
                        visible = false
                        spacer.visible = true
                        globalBackBtn.visible = true
                        searchBtn.visible = true
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
                    onTextChanged: {
                        if(text === "") {
                            reloadDefaultFriendsList()
                            return
                        }

                        searchInput.busy = true
                        http.searchProfile(text).then(
                                    function (res) {
                                        localFriendsModel.clear()
                                        const data = JSON.parse(
                                                    res)
                                        for(let i = 0; i<data.length; i++) {
                                            localFriendsModel.append(data[i])
                                        }

                                        searchInput.busy = false
                                    }).catch(function (err) {
                                        console.log(err)
                                        console.log(JSON.stringify(err))
                                        searchInput.busy = false
                                    })
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

            Column {
                id: categoriesColumn
                width: parent.width
                spacing: 10
                leftPadding: 10
                rightPadding: 10
                Label {
                    text: qsTr("Categories")
                    font {
                        weight: Font.DemiBold
                        pixelSize: 16
                    }
                }
                Row {
                    spacing: 10
                    Label {
                        id: textFilterAll
                        text: qsTr("All")
                        color: $Colors.gray600
                        padding: 5
                        width: 80
                        height: 40
                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border {
                                width: 1
                                color: $Colors.colorPrimary
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                page.filterBy = "all"
                            }
                        }
                    }
                    Label {
                        id: textFilterFriends
                        text: qsTr("Friends")
                        color: $Colors.gray600
                        padding: 5
                        width: 80
                        height: 40
                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border {
                                width: 1
                                color: $Colors.colorPrimary
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                page.filterBy = "friends"
                            }
                        }
                    }
                }
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                anchors.fill: parent
                contentHeight: insideCol.height
                clip: true

                Column {
                    id: insideCol
                    width: parent.width
                    padding: 10

                    Flow {
                        id: grid
                        width: parent.width - 20
                        spacing: 10

                        Repeater {
                            id: contactListView
                            model: filteredFriendsModel
                            delegate: Rectangle {
                                id: delegateItem
                                required property int index
                                required property var model
                                property var modelData: filteredFriendsModel.get(index)
                                property bool isFollowed: page.checkFollow(modelData.pubkey)

                                width: grid.width / 2.1
                                height: insideDelegateColumn.height
                                radius: 5
                                color: Qt.rgba(0,0,0,0)
                                border {
                                    width: 1
                                    color: Qaterial.Colors.gray200
                                }
                                anchors.bottomMargin: 20

                                Column {
                                    id: insideDelegateColumn
                                    spacing: 5
                                    width: parent.width - 10

                                    Qaterial.ClipRRect {
                                        width: parent.width
                                        height: width * (9/16)
                                        radius: 5

                                        Image {
                                            anchors.centerIn: parent
                                            anchors.fill: parent
                                            fillMode: Image.PreserveAspectCrop
                                            source: JSON.parse(modelData["profile"]
                                                               || "{}").picture
                                                    || Qaterial.Icons.faceManProfile
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: view.push(userProfile, {"profile": modelData})
                                        }
                                    }

                                    Column {
                                        spacing: 5
                                        width: parent.width
                                        padding: 7

                                        Label {
                                            text: modelData.name || modelData.username
                                            width: parent.width
                                            elide: Label.ElideRight
                                            color: $Colors.colorPrimary
                                            font {
                                                pixelSize: 16
                                                weight: Font.DemiBold
                                            }
                                        }
                                        RowLayout {
                                            spacing: 5
                                            IconImage {
                                                source: Qaterial.Icons.mapMarker
                                                color: Qaterial.Colors.blue800
                                            }

                                            Label {
                                                text: "France, Paris"
                                                Layout.fillWidth: true
                                                wrapMode: Label.Wrap
                                                color: Qaterial.Colors.gray400
                                                font {
                                                    pixelSize: 12
                                                    weight: Font.Light
                                                }
                                            }
                                        }
                                        RowLayout {
                                            width: parent.width - 10
                                            spacing: 10
                                            NiceButton {
                                                Layout.fillWidth: true
                                                text: qsTr("Write")
                                                radius: 5
                                                padding: 5
                                                icon {
                                                    source: Qaterial.Icons.messageOutline
                                                    color: Qaterial.Colors.white
                                                }
                                                backgroundColor: $Colors.colorPrimary
                                                foregroundColor: "white"
                                                onClicked: view.push(messagePage, {"friend": modelData})
                                            }
                                            NiceButton {
                                                id: followBtn
                                                property bool isFollowing: false
                                                Layout.fillWidth: true
                                                enabled: !isFollowing
                                                text: delegateItem.isFollowed ? qsTr("Remove") : qsTr("Add")
                                                radius: 5
                                                padding: 5
                                                backgroundColor: Qt.rgba(0,0,0,0)
                                                foregroundColor: delegateItem.isFollowed ? $Colors.red400 : $Colors.colorPrimary
                                                backgroundBorderWidth: 1
                                                backgroundBorderColor: delegateItem.isFollowed ? $Colors.red400 : $Colors.colorPrimary
                                                onClicked: {
                                                    if(!delegateItem.isFollowed) {
                                                        followBtn.isFollowing = true
                                                        page.follow(modelData.pubkey)
                                                        .then(function () {
                                                            followBtn.isFollowing = false
                                                            delegateItem.isFollowed = true
                                                        })
                                                        .catch(function () {
                                                            followBtn.isFollowing = false
                                                        })
                                                    }
                                                }

                                                BusyIndicator {
                                                    running: followBtn.isFollowing
                                                    anchors.centerIn: parent
                                                    width: 40
                                                    height: width
                                                }
                                            }
                                        }

                                    }
                                }

                            }
                        }
                    }
                }
            }

            MouseArea {
                id: mouseContext
                enabled: false
                anchors.fill: parent
                onClicked: {
                    console.log("CLICKKP ")
                    searchInput.focus = false
                    enabled = false
                }
            }

        }
    }
}
