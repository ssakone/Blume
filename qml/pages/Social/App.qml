import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial

import Qt.labs.settings
import QtCore
import QtWebSockets
import QtMultimedia

import SortFilterProxyModel 0.2

import ImageTools

import QtAndroidTools

import "widgets"
import "components"
import "pages"
import "utils"

Item {
    id: root
    anchors.fill: parent

    property var currentProfile: ({})

    Image2Base64 {
        id: imgToB64
    }

    Component {
        id: messagePage
        MessagePage {}
    }

    Component {
        id: messageList
        MessageList {}
    }

    Component {
        id: previewPage
        SocialPreview {}
    }

    Component {
        id: feedPage
        FeedPage {}
    }

    Component {
        id: feedDetailsPage
        FeedDetailsPage {}
    }

    Component {
        id: findUser
        FindUser {}
    }

    Component {
        id: userProfile
        UserProfile {}
    }

    Component {
        id: closeAccountPage
        CloseMyAccountPage {}
    }

    Component {
        id: startPage
        StartPage {}
    }

    Component {
        id: loginPage
        Login {}
    }

    Component {
        id: registerPage
        Register {}
    }

    Component {
        id: profileEditPage
        ProfileEditPage {}
    }

    Component {
        id: postEditPage
        PostEditPage {}
    }


    PostActions {
        id: postActionsDrawer
    }

    property string privateKey: ""
    property string publicKey: ""

    property string username: ""
    property string displayName: ""
    property string avatarUrl: ""
    property string bio: ""

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

    property string followerQuery: `[
    "REQ",
    "%1",
    {
    "authors": ["%2"],
    "kinds": [3],
    "limit": 1
    }
    ]`

    property string messageQuery: `[
    "REQ",
    "%1",
    {
    "authors": ["%2", "%3"],
    "kinds":[4],
    "#p": ["%3", "%2"]
    }
    ]`

    property string discussionQuery: `[
    "REQ",
    "%1",
    {
    "authors": ["%2"],
    "kinds":[4]
    }
    ]`

    property string discussionQuery2: `[
    "REQ",
    "%1",
    {
    "#p": ["%2"],
    "kinds":[4]
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
            if (publicKey === data[2].pubkey) {
                userInfo = author
            }

            authorAdded(data[2].pubkey)

            // console.log("Fetched", data[2].pubkey, author.name)
            root.author[data[2].pubkey] = author
        }
    }

    property variant contactHandler: function (data) {
        if (data[0] === "EVENT") {
            let contact = data[2].tags
            root.contacts[data[2].pubkey] = contact
            friendListUpdated()
            data[2].tags.forEach(function (tag) {
                subscribe(tag[1])
            })
        }
    }

    property variant eventHandler: function (data) {
        if (data[0] === "EVENT") {
            let event = data[2]
            if (event.tags.length > 0)
                return
            if (root.author[event.pubkey] === undefined) {
                const authorId = Math.random().toString(36).substring(7)
                reqHandler[authorId] = authorHandler

                const authorFetchQuery = authorQuery.arg(authorId).arg(
                                           event.pubkey)
                relay.sendTextMessage(authorFetchQuery)
            }

            getComments(event)

            event["comments"] = Qt.createQmlObject(
                        "import QtQuick; ListModel{}", root)
            event["likes"] = Qt.createQmlObject("import QtQuick; ListModel{}",
                                                root)
            events.append(event)
        }
    }

    property variant messageHandler: function (data) {
        if (data[0] === "EVENT") {
            let event = data[2]
            let found = false

            // check if already inside pass
            found = false
            for (var i = 0; i < messages.count; i++) {
                if (messages.get(i).removable) {
                    messages.remove(i)
                    continue
                }

                if (messages.get(i).id === event.id) {
                    found = true
                    break
                }
            }
            if (found)
                return

            if (publicKey === event.pubkey || event.tags[0][1] === publicKey) {
                if (currentDiscussionPubkey === event.tags[0][1]
                        || event.pubkey === currentDiscussionPubkey) {
                    messages.append(event)
                }
            }
        } else {

        }
    }

    property variant discussionHandler: function (data) {
        if (data[0] === "EVENT") {
            let event = data[2]
            let found = false
            if (event.tags[0][1] !== event.pubkey) {
                found = true
            } else {
                found = false
            }

            if (found === true) {
                let combination = publicKey
                    + (publicKey === event.pubkey ? event.tags[0][1] : event.pubkey)
                let mo
                if (realDiscussions[combination] !== undefined)
                    mo = realDiscussions[combination]
                else
                    mo = undefined

                if (mo === undefined) {
                    let moModel = Qt.createQmlObject(
                            "import QtQuick; ListModel{}", root)
                    let info = {
                        "mostRecent": event.created_at,
                        "pubkey": event.pubkey,
                        "locuter": publicKey === event.pubkey ? event.tags[0][1] : event.pubkey,
                        "model": moModel
                    }
                    mo = info
                } else {
                    let moModel = mo.model
                    if (mo.mostRecent < event.created_at) {
                        mo.mostRecent = event.created_at
                        mo.locuter = publicKey === event.pubkey ? event.tags[0][1] : event.pubkey
                    }
                    moModel.append(event)
                    mo = {
                        "mostRecent": mo.mostRecent,
                        "pubkey": mo.pubkey,
                        "locuter": mo.locuter,
                        "model": moModel
                    }
                }
                realDiscussions[combination] = mo
            }
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

    function getMessage(pubkey) {
        currentDiscussionPubkey = pubkey
        let rid = Math.random().toString(36).substring(7)
        reqHandler[rid] = messageHandler
        messagesRelay.sendTextMessage(messageQuery.arg(rid).arg(
                                          publicKey).arg(pubkey))
    }

    function getDiscussion() {
        let rid = Math.random().toString(36).substring(7)
        reqHandler[rid] = discussionHandler
        messagesRelay.sendTextMessage(discussionQuery.arg(rid).arg(publicKey))
        messagesRelay.sendTextMessage(discussionQuery2.arg(rid).arg(publicKey))
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

    function getContact(pubkey, force = false) {
        if (contactRequested.indexOf(pubkey) !== -1 && !force)
            return
        contactRequested.push(pubkey)
        const authorId = Math.random().toString(36).substring(7)
        reqHandler[authorId] = contactHandler
        const contactFetchQuery = followerQuery.arg(authorId).arg(pubkey)
        messagesRelay.sendTextMessage(contactFetchQuery)
    }

    function subscribe(pubkey) {
        if (subscribed.indexOf(pubkey) !== -1)
            return
        subscribed.push(pubkey)
        const id = Math.random().toString(36).substring(7)
        reqHandler[id] = eventHandler
        relay.sendTextMessage(textQuery.arg(id).arg(pubkey))
    }

    function initHuman() {
        getAuthor(publicKey, true)
        getContact(publicKey)
        getDiscussion()
    }

    function initTransaction() {
        subscribe("3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d")
        subscribe("32e1827635450ebb3c5a7d12c1f8e7b2b514439ac10a67eef3d9fd9c5c68e245")
        subscribe("817148c3690155401b494580871fb0564a5faafb9454813ef295f2706bc93359")
        subscribe(publicKey)
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

    WebSocket {
        id: relay
        url: "wss://relay.damus.io"
        active: false
        onStatusChanged: {
            if (relay.status === WebSocket.Open
                    && (privateKey !== "" && privateKey !== undefined)) {
                initTransaction()
                console.log('[BLUME][STATUS CHANGED]', getStatus(relay.status))
            } else {
                if (relay.status === WebSocket.Closed && privateKey !== "") {
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
    property string currentDiscussionPubkey: ""

    ListModel {
        id: discussions
    }

    ListModel {
        id: events
    }

    ListModel {
        id: messages
    }

    Http {
        id: http
    }

    SortFilterProxyModel {
        id: eventsProxy
        sourceModel: events
        // sort by created_at
        sorters: StringSorter {
            roleName: "created_at"
            sortOrder: Qt.DescendingOrder
        }

        proxyRoles: ExpressionRole {
            name: "commentsCount"
            expression: comments.count
        }
    }

    property var author: ({})

    property var userInfo: ({})
    property var contacts: ({})

    property var friendLists: ([])

    property var realDiscussions: ({})

    ListModel {
        id: _friendsListModel
    }

    property alias friendsListModel: _friendsListModel
    Settings {
        id: setting
        property alias privateKey: root.privateKey
        property alias publicKey: root.publicKey
        property alias userInfo: root.userInfo
        property alias contacts: root.contacts
        property alias author: root.author
    }

    Timer {
        id: timer
        interval: 100
        repeat: true
        onTriggered: {
            if (view.currentItem != startPage) {
                if (view.depth > 1) {
                    view.pop()
                    return
                }
                view.push(startPage)
                timer.stop()
            } else {
                timer.stop()
            }
        }
    }

    function wipeAll() {
        root.privateKey = ""
        root.publicKey = ""
        root.contacts = {}
        root.userInfo = {}
        root.realDiscussions = {}
        root.friendLists = []
        discussions.clear()
        messages.clear()
        events.clear()
        root.subscribed = []
        relay.active = false
        messagesRelay.active = false
    }


    function logout() {
        timer.start()
    }

    property alias $Services: _service

    property WebSocket messagesRelay

    Connections {
        target: messagesRelay
        function onStatusChanged() {
            if (messagesRelay.status === WebSocket.Open) {
                initHuman()
            } else {
                if (messagesRelay.status === WebSocket.Closed
                        && privateKey !== "") {
                    messagesRelay.active = false
                    messagesRelay.active = true
                }
            }
        }

        function onTextMessageReceived(message) {
            if (message.length === 0) {
                return
            }
            let el = JSON.parse(message)
            try {
                reqHandler[el[1]](el)
            } catch (e) {

            }
        }
    }

    Services {
        id: _service
    }

    signal friendListUpdated

    Timer {
        id: friendRefresh
        interval: 10000
        repeat: true
        onTriggered: {
            http.getContacts().then(function (rs) {
                friendLists = JSON.parse(rs)
                root.friendListUpdated()

                console.log("UPDATE CONTACT ", 0)
                friendsListModel.clear()
                console.log("UPDATE CONTACT ", friendLists.length)
                for(let i = 0; i<friendLists.length; i++) {
                    friendsListModel.append(friendLists[i])
                    console.log("append")
                }
            }).catch(function (e) {
                console.log(JSON.stringify(e))
            })
        }
    }

    Timer {
        id: discussionRefresher
        interval: 1500
        repeat: true
        onTriggered: getDiscussion()
    }

    StackView {
        id: view
        anchors.fill: parent
        onFocusChanged: {
            console.log("StackView focus changed ", focus)
        }

        Component.onCompleted: {
            page_view.indepthStacksList.push(view.pop)
            Qaterial.Style.theme = Qaterial.Style.Theme.Light
            Qaterial.Style.accentColor = Qaterial.Colors.teal
            initialItem = root.privateKey.length > 0 ? previewPage : startPage
            view.push(initialItem)
            messagesRelay = $Services.getWebSocket()
            messagesRelay.url = "wss://relay.damus.io"
            messagesRelay.active = true

            if (root.privateKey.length > 0) {
                relay.active = true
                friendRefresh.start()
                friendRefresh.triggered()
                discussionRefresher.start()
            }
        }
    }
}
