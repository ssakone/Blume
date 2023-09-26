import QtQuick

Item {
    property variant pubkeyFetched: []
    property variant waitList: []
    function getPubKeyInfo(pubkey, callback) {
        if (root.author[pubkey] !== undefined) {
            callback(root.author[pubkey])
            return
        }

        if (pubkeyFetched.indexOf(pubkey) !== -1) {
            callback(root.author[pubkey])
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
            for (var i = 0; i < waitList.length; i++) {
                var pubkey = waitList[i]
                if (root.author[pubkey] !== undefined
                        && root.author[pubkey].name !== null
                        && root.author[pubkey].name.toString(
                            ) !== "undefined") {
                    if (root.author[pubkey].name.length > 0) {
                        if (root.author[pubkey].name.length > 0) {
                            waitList.splice(i, 1)
                            pubkeyFetched.push(pubkey)
                            //callback(root.author[pubkey])
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
                                        `, root)
        return socket
    }
}
