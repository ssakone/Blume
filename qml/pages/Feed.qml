import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform
import QtWebSockets
import Qt.labs.settings
import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import "../components"
import "../components_generic"

BPage {
    id: feed

    property var currentProfile: ({})
    padding: 0

    header: AppBar {
        visible: false
        title: qsTr("Feed")
    }

    Component {
        id: feedView
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
                    AppBarButton {
                        foregroundColor: "black"
                        icon: Icons.arrowLeft
                        onClicked: page_view.pop()
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            leftPadding: 10
                            anchors.verticalCenter: parent.verticalCenter
                            font.weight: Font.Bold
                            font.pixelSize: 20
                            text: qsTr("Blume Social")
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
                    Repeater {
                        model: eventsProxy
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: feedListView.width - 40
                            height: _insideColumn.height
                            color: "white"
                            border.color: "gray"
                            radius: 10
                            layer.enabled: true

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    currentProfile = {
                                        "name": feed.author[pubkey].name,
                                        "picture": feed.author[pubkey].picture,
                                        "pubkey": pubkey
                                    }
                                    view2.push(feedDetailsPage, {
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
                                                target: feed
                                                function onAuthorAdded(pubc) {
                                                    Qt.callLater(function (pubk) {
                                                        if (pubkey === pubk) {
                                                            _nameLabel.text
                                                                    = feed.author[pubkey].name
                                                                    || ""
                                                            _avatar.source
                                                                    = feed.author[pubkey].picture
                                                                    || ""
                                                        }
                                                    }, pubc)
                                                }
                                            }

                                            Component.onCompleted: {
                                                _control.getPubKeyInfo(
                                                            pubkey,
                                                            function (info) {
                                                                if (info !== undefined) {
                                                                    _nameLabel.text = info.name
                                                                            || ""
                                                                    _avatar.source = info.picture
                                                                            || ""
                                                                }
                                                            })
                                            }

                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            color: "black"
                                        }
                                        Label {
                                            text: feed.timeAgoOrDate(created_at)
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
                                            imageLoader.source = data[1][0]
                                            _imArea.visible = true
                                        }
                                    }
                                }

                                ClipRRect {
                                    id: _imArea
                                    width: _insideColumn.width - 20
                                    height: _im.height
                                    visible: false

                                    Loader {
                                        id: imageLoader
                                    }
                                    Image {
                                        id: _im
                                        width: parent.width
                                        asynchronous: true
                                        cache: false
                                        source: imageLoader.source
                                        fillMode: Image.PreserveAspectFit
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: imageViewerWithZoom.show(
                                                           _im.source)
                                        }
                                    }
                                }

                                ClipRRect {
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
                                            IconSvg {
                                                anchors.verticalCenter: parent.verticalCenter
                                                source: Icons.heartOutline
                                                width: 18
                                                height: 18
                                            }

                                            Label {
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
                                            IconSvg {
                                                anchors.verticalCenter: parent.verticalCenter
                                                source: Icons.commentTextOutline
                                                width: 18
                                                height: 18
                                            }

                                            Label {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "%1 comments".arg(
                                                          comments.count)
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
        }
    }

    Component {
        id: feedDetailsPage
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
                    AppBarButton {
                        foregroundColor: "black"
                        icon: Icons.arrowLeft
                        onClicked: view2.pop()
                    }
                    Avatar {
                        id: _avatar
                        height: 50
                        width: 50
                        source: currentProfile.picture
                        avatarSize: 55
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
                                    const data = feed.author[post.pubkey] || {}
                                    data["pubkey"] = post.pubkey
                                    view.push(userProfile, {
                                                  "profile": data
                                              })
                                }
                            }
                        }
                        Label {
                            text: feed.timeAgoOrDate(post.created_at)
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
                                text = feed.formatLinks(data[0])
                                if (data[2].length > 0) {
                                    _vid.source = data[2][0]
                                    _vidArea.visible = true
                                } else if (data[1].length > 0) {
                                    imageLoader.source = data[1][0]
                                    _imArea.visible = true
                                }
                            }
                        }

                        ClipRRect {
                            id: _imArea
                            width: _insideColumn.width - 20
                            height: _im.height
                            visible: false
                            Loader {
                                id: imageLoader
                            }
                            Image {
                                id: _im
                                width: parent.width
                                asynchronous: false
                                cache: false
                                source: imageLoader.source
                                fillMode: Image.PreserveAspectFit
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: imageViewerWithZoom.show(
                                                   imageLoader.source)
                                }
                            }
                        }

                        ClipRRect {
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
                                    IconSvg {
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: Icons.heartOutline
                                        width: 18
                                        height: 18
                                    }

                                    Label {
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
                                    IconSvg {
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: Icons.commentTextOutline
                                        width: 18
                                        height: 18
                                    }

                                    Label {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "%1 comments".arg(
                                                  page.comments.count)
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
                                        source: feed.author[pubkey]?.picture
                                                || ""
                                        avatarSize: 40
                                        onClicked: {
                                            const data = feed.author[pubkey]
                                                       || {}
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
                                            text: feed.author[pubkey]?.name
                                                  || pubkey.slice(0, 8)
                                            font.pixelSize: 16
                                            font.weight: Font.Bold
                                            color: "black"
                                            Connections {
                                                target: feed
                                                function onAuthorAdded(pubc) {
                                                    Qt.callLater(function (pubk) {
                                                        if (pubkey === pubk) {
                                                            _nameLabel3.text
                                                                    = feed.author[pubkey].name
                                                                    || ""
                                                            _avatar3.source
                                                                    = feed.author[pubkey].picture
                                                                    || ""
                                                        }
                                                    }, pubc)
                                                }
                                            }

                                            Component.onCompleted: {
                                                $Services.getPubKeyInfo(
                                                            pubkey,
                                                            function (info) {
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
                                            text: feed.timeAgoOrDate(created_at)
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
                                        text = feed.formatLinks(data[0])
                                        if (data[2].length > 0) {
                                            _vid2.source = data[2][0]
                                            _vidArea2.visible = true
                                        } else if (data[1].length > 0) {
                                            _im2.source = data[1][0]
                                            _imArea2.visible = true
                                        }
                                    }
                                }
                                ClipRRect {
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

                                ClipRRect {
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
    }

    StackView {
        id: view2
        anchors.fill: parent
        initialItem: feedView
    }

    property string textQuery: `[
    "REQ",
    "%1",
    {
    "authors": ["%2"],
    "kinds": [1],
    "limit": 20
    }
    ]`

    property string commentQuery: `[
    "REQ",
    "%1",
    {
    "#e": ["%2"],
    "kinds": [1, 7],
    "limit": 50
    }]`

    property string authorQuery: `[
    "REQ",
    "%1",
    {
    "authors": ["%2"],
    "kinds": [0],
    "limit": 1
    }
    ]`

    function timeAgoOrDate(value) {
        const timestamp = value * 1000
        // convert seconds to milliseconds
        const date = new Date(timestamp)
        const now = new Date()
        const diffHrs = (now - date) / 1000 / 60 / 60

        // difference in hours
        if (diffHrs < 30) {
            if (diffHrs < 1) {
                const minutes = Math.round(diffHrs * 60)
                return `${minutes} minutes ago`
            } else {
                const hours = Math.round(diffHrs)
                return `${hours} hours ago`
            }
        } else {
            const year = date.getFullYear()
            const month = ('0' + (date.getMonth() + 1)).slice(-2)
            const day = ('0' + date.getDate()).slice(-2)
            const hour = ('0' + date.getHours()).slice(-2)
            const minute = ('0' + date.getMinutes()).slice(-2)
            return `${year}-${month}-${day} ${hour}:${minute}`
        }
    }

    function captureLinks(text) {
        const linkRegex = /(https?:\/\/[^\s]+)/g
        const imageRegex = /\.(jpg|jpeg|png|gif|bmp|webp|svg)(\?.*)?$/i
        const videoRegex = /\.(mp4|avi|mov|wmv|flv|webm|mkv|mpeg)(\?.*)?$/i

        const links = text.match(linkRegex) || []
        const images = []
        const videos = []
        const nonMediaLinks = []

        for (let link of links) {
            if (imageRegex.test(link)) {
                images.push(link)
            } else if (videoRegex.test(link)) {
                videos.push(link)
            } else {
                nonMediaLinks.push(link)
            }
        }

        let textWithoutMediaLinks = text

        // Enlever seulement les images et les vidéos du texte
        for (const link of images.concat(videos)) {
            textWithoutMediaLinks = textWithoutMediaLinks.replace(link, '')
        }

        return [textWithoutMediaLinks, images, videos, nonMediaLinks]
    }

    function formatLinks(text) {
        // Regex pour identifier les liens
        var urlRegex = /(https?:\/\/[^\s]+)/g

        // Remplacer les liens par des balises a
        return text.replace(urlRegex, function (url) {
            return '<a href="' + url + '" style="color: blue;">' + url + '</a>'
        })
    }

    signal authorAdded(var pubkey)

    property variant authorHandler: function (data) {
        if (data[0] === "EVENT") {
            let author = JSON.parse(data[2].content)

            authorAdded(data[2].pubkey)

            feed.author[data[2].pubkey] = author
        }
    }

    property variant eventHandler: function (data) {
        if (data[0] === "EVENT") {
            let event = data[2]
            if (event.tags.length > 0)
                return
            if (feed.author[event.pubkey] === undefined) {
                const authorId = Math.random().toString(36).substring(7)
                reqHandler[authorId] = authorHandler

                const authorFetchQuery = authorQuery.arg(authorId).arg(
                                           event.pubkey)
                relay.sendTextMessage(authorFetchQuery)
            }

            console.log("new event got")

            getComments(event)

            event["comments"] = Qt.createQmlObject(
                        "import QtQuick; ListModel{}", feed)
            event["likes"] = Qt.createQmlObject("import QtQuick; ListModel{}",
                                                feed)
            console.log("new event added")
            events.append(event)
        }
    }

    property variant commentHandler: function (data) {
        if (data.length === 3) {
            for (var i = 0; i < events.count; i++) {
                getAuthor(data[2].pubkey)
                if (events.get(i).id === data[2].tags[0][1]) {
                    try {
                        let ev = events.get(i)

                        // check if id already exist in comments or like
                        let found = false

                        if (data[0] === "EVENT") {
                            if (data[2].kind === 1) {
                                for (var j = 0; j < ev.comments.count; j++) {
                                    if (ev.comments.get(j).id === data[2].id) {
                                        found = true
                                        break
                                    }
                                }
                                if (!found)
                                    ev.comments.append(data[2])
                            } else {
                                let found = false
                                for (var j = 0; j < ev.likes.count; j++) {
                                    if (ev.likes.get(j).id === data[2].id) {
                                        found = true
                                        break
                                    }
                                }
                                if (!found)
                                    ev.likes.append(data[2])
                            }
                        }
                    } catch (e) {
                        console.log(e, "comment")
                    }
                }
            }
        }
    }

    function getComments(event) {
        let rid = Math.random().toString(36).substring(7)
        reqHandler[rid] = commentHandler
        referenceEvent[rid] = event
        relay.sendTextMessage(commentQuery.arg(rid).arg(event.id))
    }

    function getAuthor(pubkey, force = false) {
        if (!force)
            if (authorRequested.indexOf(pubkey) !== -1 && !force)
                return
        authorRequested.push(pubkey)
        const authorId = Math.random().toString(36).substring(7)
        reqHandler[authorId] = authorHandler
        const authorFetchQuery = authorQuery.arg(authorId).arg(pubkey)
        messagesRelay.sendTextMessage(authorFetchQuery)
    }

    function subscribe(pubkey) {
        if (subscribed.indexOf(pubkey) !== -1)
            return
        subscribed.push(pubkey)
        const id = Math.random().toString(36).substring(7)
        reqHandler[id] = eventHandler
        relay.sendTextMessage(textQuery.arg(id).arg(pubkey))
    }

    function getStatus(status) {
        switch (status) {
        case WebSocket.Closing:
            return "Closing"
        case WebSocket.Closed:
            return "Closed"
        case WebSocket.Connecting:
            return "Connecting"
        case WebSocket.Open:
            return "Open"
        default:
            return "Unknown"
        }
    }

    function initTransaction() {
        subscribe("817148c3690155401b494580871fb0564a5faafb9454813ef295f2706bc93359")
    }

    WebSocket {
        id: relay
        url: "wss://relay.damus.io"
        active: false
        onStatusChanged: {
            if (relay.status === WebSocket.Open) {
                initTransaction()
                console.log('[BLUME][STATUS CHANGED]', getStatus(relay.status))
            } else {
                if (relay.status === WebSocket.Closed) {
                    relay.active = false
                    relay.active = true
                }
                console.log('[BLUME][STATUS CHANGED]', getStatus(relay.status))
            }
        }
        onTextMessageReceived: function (message) {
            if (message.length === 0) {
                return
            }
            let el = JSON.parse(message)
            console.log(message)
            try {
                reqHandler[el[1]](el)
            } catch (e) {

            }
        }
    }

    property var reqHandler: ({})
    property var referenceEvent: ({})
    property var authorRequested: ([])
    property var contactRequested: ([])
    property var subscribed: ([])

    ListModel {
        id: events
    }

    SortFilterProxyModel {
        id: eventsProxy
        sourceModel: events
        sorters: StringSorter {
            roleName: "created_at"
            sortOrder: Qt.DescendingOrder
        }

        onCountChanged: {
            console.log(count)
        }

        proxyRoles: ExpressionRole {
            name: "commentsCount"
            expression: comments.count
        }
    }

    property var author: ({})

    property var userInfo: ({})
    property var contacts: ({})

    Settings {
        id: setting
        property alias contacts: feed.contacts
        property alias author: feed.author
    }

    Popup {
        id: imageViewerWithZoom
        width: parent.width
        height: parent.height
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        function show(url) {
            popupImage.source = url
            open()
        }

        background: Rectangle {
            color: "darkgray"
        }

        Image {
            id: popupImage
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            fillMode: Image.PreserveAspectFit
            PinchArea {
                id: pinchArea
                anchors.fill: parent
                pinch.target: popupImage
                pinch.minimumScale: 0.1
                pinch.maximumScale: 10
                pinch.dragAxis: Pinch.XAndYAxis
                pinch.minimumX: -parent.width * 2
                pinch.maximumX: parent.width * 2
                pinch.minimumY: -parent.height * 2
                pinch.maximumY: parent.height * 2
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.MiddleButton
                onWheel: {
                    if (wheel.angleDelta.y > 0) {
                        popupImage.scale += 0.1
                    } else if (wheel.angleDelta.y < 0) {
                        popupImage.scale -= 0.1
                    }
                }
            }
        }

        AppBarButton {
            icon: Icons.close
            foregroundColor: "white"
            onClicked: imageViewerWithZoom.close()
        }
    }

    property alias $Service: _control
    Item {
        id: _control
        property variant pubkeyFetched: []
        property variant waitList: []
        function getPubKeyInfo(pubkey, callback) {
            if (feed.author[pubkey] !== undefined) {
                callback(feed.author[pubkey])
                return
            }

            if (pubkeyFetched.indexOf(pubkey) !== -1) {
                callback(feed.author[pubkey])
                return
            }

            if (waitList.indexOf(pubkey) !== -1) {
                return
            }

            waitList.push(pubkey)

            getAuthor(pubkey, true)
        }

        Timer {
            id: nameRefresher
            property int counter: 0
            interval: 250
            repeat: true
            running: true
            onTriggered: {
                for (var i = 0; i < _control.waitList.length; i++) {
                    var pubkey = _control.waitList[i]
                    if (feed.author[pubkey] !== undefined
                            && feed.author[pubkey].name !== null
                            && feed.author[pubkey].name.toString(
                                ) !== "undefined") {
                        if (feed.author[pubkey].name.length > 0) {
                            if (feed.author[pubkey].name.length > 0) {
                                _control.waitList.splice(i, 1)
                                _control.pubkeyFetched.push(pubkey)
                            }
                        }
                    }
                }
            }
        }

        function getWebSocket() {
            let socket = Qt.createQmlObject(`
                                            import QtQuick
                                            import QtWebSockets
                                            WebSocket {}
                                            `, feed)
            return socket
        }
    }

    Component.onCompleted: {
        relay.active = true
    }
}
