import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia

import "../components"
import "../widgets"

Page {
//    property bool isFullScreen: false
//    onIsFullScreenChanged: {
//        if (isFullScreen)
//            fullScreenPop.close()

//    }
    FocusScope {
        Keys.onBackPressed: console.log("BAAAAACK")
        FullScreenMedia {
            id: fullScreenPop
            //onSwithMode: isFullScreen = !isFullScreen
        }

    }

    Flickable {
        anchors.fill: parent
        contentHeight: insideCol.height

        Column {
            id: insideCol
            width: parent.width
            spacing: 25
            topPadding: 20

            // Search bar row
            Column {
                width: parent.width - 30
                leftPadding: 15
                rightPadding: 15

                RowLayout {
                    width: parent.width
                    height: 50
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 10

                    Avatar {
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: height
                        source: userInfo?.picture
                                ?? Qaterial.Icons.faceManProfile

                        onClicked: {
                            let data = userInfo || {}
                            data["pubkey"] = publicKey
                            view.push(userProfile, {
                                          "profile": data
                                      })
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                        radius: 25
                        color: Qaterial.Colors.gray100

                        border {
                            width: 1
                            color: Qaterial.Colors.gray300
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: view.push(findUser)
                        }

                        Row {
                            leftPadding: 20
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter
                            IconImage {
                                width: 30
                                height: width
                                source: Qaterial.Icons.magnify
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: qsTr("Search for a friend")
                                color: Qaterial.Colors.gray600
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    IconImage {
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: height
                        source: Qaterial.Icons.messageOutline
                        color: $Colors.colorPrimary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: view.push(messageList)
                        }
                    }
                }
            }

            Flickable {
                width: parent.width - 20
                height: 120
                contentWidth: storiesRow.width

                Row {
                    id: storiesRow
                    spacing: 15
                    leftPadding: 15
                    Repeater {
                        model: root.friendLists

                        Rectangle {
                            width: 200
                            height: 120
                            radius: 10
                            border {
                                width: 2
                                color: $Colors.colorPrimary
                            }

                            Qaterial.ClipRRect {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: parent.radius
                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/assets/img/plant-with-insect.png"
                                }
                            }
                            Label {
                                text: modelData["name"]?.slice(0, 15)
                                padding: 4
                                leftPadding: 30
                                rightPadding: 7
                                color: $Colors.colorPrimary
                                background: Rectangle {
                                    color: $Colors.colorTertiary
                                    radius: 5
                                }
                                anchors {
                                    top: parent.top
                                    topMargin: 3
                                    left: parent.left
                                    leftMargin: 5
                                }

                                Avatar {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 5
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: 20
                                    height: width
                                    avatarSize: height
                                    source: JSON.parse(modelData["profile"]
                                                       || "{}").picture
                                            || Qaterial.Icons.faceManProfile
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if(modelData['is_pined']) {
                                        view.push(messagePage, {
                                         "friend": modelData
                                         })
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Column {
                id: postListColumn
                width: parent.width
                spacing: 20
                Repeater {
                    model: eventsProxy
                    Rectangle {
                        id: rootPostRect
                        function showProfile() {
                            let data = root.author[pubkey]
                            data["pubkey"] = pubkey
                            view.push(userProfile, {
                                          "profile": data
                                      })
                        }

                        width: postListColumn.width
                        height: postColumn.height
                        radius: 20
                        border {
                            width: 2
                            color: $Colors.gray300
                        }

                        Column {
                            id: postColumn
                            width: parent.width - 20
                            padding: 10

                            Column {
                                width: parent.width

                                RowLayout {
                                    width: parent.width
                                    spacing: 10
                                    Avatar {
                                        id: _avatar
                                        Layout.preferredHeight: 70
                                        Layout.preferredWidth: height
                                        source: Qaterial.Icons.powerSocketIt
                                        onClicked: rootPostRect.showProfile()
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Label {
                                            id: _nameLabel
                                            color: $Colors.colorPrimary
                                            font.pixelSize: 14

                                            Connections {
                                                target: root
                                                function onAuthorAdded(pubc) {
                                                    Qt.callLater(function (pubk) {
                                                        if (pubkey === pubk) {
                                                            _nameLabel.text
                                                                    = root.author[pubkey].name
                                                                    || ""
                                                            _avatar.source
                                                                    = root.author[pubkey].picture
                                                                    || Qaterial.Icons.faceProfile
                                                        }
                                                    }, pubc)
                                                }
                                            }

                                            Component.onCompleted: {
                                                $Services.getPubKeyInfo(
                                                            pubkey,
                                                            function (info) {
                                                                if (info !== undefined) {
                                                                    _nameLabel.text = info.name
                                                                            || ""
                                                                    _avatar.source = info.picture
                                                                            || Qaterial.Icons.faceProfile
                                                                }
                                                            })
                                            }
                                        }
                                        Label {
                                            text: root.timeAgoOrDate(created_at)
                                            color: $Colors.gray600
                                            font.pixelSize: 11
                                        }
                                    }

                                    Row {
                                        spacing: 7
                                        IconImage {
                                            source: "qrc:/assets/icons_custom/three-dots-inline.svg"
                                            color: $Colors.gray400
                                            anchors.verticalCenter: parent.verticalCenter

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: postActionsDrawer.display()
                                            }
                                        }
                                        IconImage {
                                            source: Qaterial.Icons.heartPlusOutline
                                            color: $Colors.gray400
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width
                                    spacing: 10
                                    Label {
                                        color: Qaterial.Colors.gray600
                                        width: parent.width
                                        wrapMode: Label.Wrap
                                        maximumLineCount: 3
                                        Component.onCompleted: {
                                            const data = captureLinks(content)
                                            text = data[0]?.slice(0)
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
                                        width: parent.width
                                        height: _im.height //width * (9 / 16)
                                        visible: _im.source.toString() !== ""
                                        Image {
                                            id: _im
                                            width: parent.width
                                            asynchronous: false
                                            cache: false
                                            fillMode: Image.PreserveAspectFit
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: fullScreenPop.displayImage(parent.source)
                                            }
                                        }
                                    }

                                    RadiusImage {
                                        id: _vidArea
                                        visible: false
                                        width: parent.width
                                        height: visible ? width * (9 / 16) : 0
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

                                    //                                    Qaterial.ClipRRect {
                                    //                                        width: parent.width
                                    //                                        height: width * (9/16)
                                    //                                        Image {
                                    //                                            anchors.fill: parent
                                    //                                            source: "qrc:/assets/img/orchidee.jpg"
                                    //                                        }
                                    //                                    }
                                    //                                    RowLayout {
                                    //                                        width: parent.width
                                    //                                        Item {
                                    //                                            Layout.fillWidth: true
                                    //                                        }

                                    //                                        Repeater {
                                    //                                            model: 3
                                    //                                            Rectangle {
                                    //                                                Layout.preferredHeight: 10
                                    //                                                Layout.preferredWidth: height
                                    //                                                radius: height/2
                                    //                                                border {
                                    //                                                    width: 1
                                    //                                                    color: $Colors.colorPrimary
                                    //                                                }
                                    //                                                color: $Colors.gray200
                                    //                                            }
                                    //                                        }

                                    //                                        Item {
                                    //                                            Layout.fillWidth: true
                                    //                                        }
                                    //                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    anchors.topMargin: 10
                                    Row {
                                        Layout.fillWidth: true
                                        spacing: 5
                                        IconImage {
                                            source: Qaterial.Icons.heartOutline
                                            color: Qaterial.Colors.orange300
                                            width: 30
                                            height: width
                                        }
                                        Label {
                                            color: $Colors.gray600
                                            text: "%1 like".arg(likes.count)
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    Label {
                                        color: $Colors.gray600
                                        text: "%1 comments".arg(comments.count)
                                        Layout.fillWidth: true
                                    }
                                    Label {
                                        color: $Colors.gray600
                                        text: qsTr("40 shares")
                                        Layout.fillWidth: true
                                        horizontalAlignment: Label.AlignRight
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 50
                                    radius: 10
                                    border {
                                        width: 1
                                        color: Qaterial.Colors.gray200
                                    }
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        Row {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            IconImage {
                                                source: Qaterial.Icons.heartOutline
                                                color: Qaterial.Colors.gray600
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Rectangle {
                                                Layout.preferredHeight: parent.height
                                                width: 1
                                                color: Qaterial.Colors.gray200
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            IconImage {
                                                source: Qaterial.Icons.messageOutline
                                                color: Qaterial.Colors.gray600
                                                Layout.alignment: Qt.AlignVCenter
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
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Rectangle {
                                                Layout.preferredHeight: parent.height
                                                width: 1
                                                color: Qaterial.Colors.gray200
                                            }
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            IconImage {
                                                source: Qaterial.Icons.shareOutline
                                                color: Qaterial.Colors.gray600
                                                Layout.alignment: Qt.AlignVCenter
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
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color: $Colors.colorPrimary
                    icon: Qaterial.Icons.homeOutline
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                onClicked: view.push(postEditPage)
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color: Qaterial.Colors.gray600
                    icon: Qaterial.Icons.shareOutline
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                onClicked: page_view.pop()
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 5
                    height: width
                    color: $Colors.colorPrimary
                    icon: "qrc:/assets/icons_custom/blume-circle-green.svg"
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color: Qaterial.Colors.gray600
                    icon: Qaterial.Icons.bellOutline
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                onClicked: view.push(findUser)
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color: Qaterial.Colors.gray600
                    icon: Qaterial.Icons.accountOutline
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
