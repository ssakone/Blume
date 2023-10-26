import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SortFilterProxyModel
import QtWebSockets
import QtMultimedia
import Qaterial as Qaterial
import QtAndroidTools
import "../components"

Page {
    id: page
    property var friend: ({})
    property bool isAIWritting: false
    property bool isBotMode: Boolean(friend?.is_pined)
    property int prevCount: 0

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
                Column {
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        leftPadding: 10
                        font.weight: Font.Bold
                        font.pixelSize: 20
                        text: page.friend.name || friend.pubkey.slice(
                                  0, 18) + "..." || ""
                    }

                    Text {
                        leftPadding: 10
                        font.weight: Font.Light
                        font.pixelSize: 12
                        text: qsTr("Online")
                    }

                    Text {
                        visible: page.isAIWritting
                        leftPadding: 10
                        font.pixelSize: 12
                        text: qsTr("is writting....")

                        Connections {
                            target: messageModel
                            function onCountChanged(newCount) {
                                if(newCount === page.prevCount + 2) {
                                    page.isAIWritting = false
                                }
                            }
                        }
                    }

                }
            }
            Row {
                spacing: 15
                rightPadding: 10
                IconImage {
                    source: Qaterial.Icons.phone
                }

                IconImage {
                    source: Qaterial.Icons.video
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        ListView {
            id: chatView
            anchors {
                top: parent.top
                bottom: lockText.top
                left: parent.left
                right: parent.right
                //bottomMargin: page.isAIWritting ? lockText.height+25 : 10
            }

            anchors.rightMargin: 5
            anchors.margins: 10
            spacing: 10
            verticalLayoutDirection: ListView.BottomToTop

            model: messageModel

            delegate: Column {
                property bool current: pubkey === publicKey
                id: control
                width: chatView.width * 0.8
                x: current ? chatView.width - width - 10 : 0

                RadiusImage {
                    id: _imArea
                    width: parent.width
                    height: 200
                    visible: false
                    anchors.right: control.current ? parent.right : null
                    Image {
                        id: _im
                        width: parent.width
                        height: 200
                        asynchronous: false
                        cache: false
                        fillMode: Image.PreserveAspectFit
                    }
                }

                RadiusImage {
                    id: _vidArea
                    visible: false
                    width: 200
                    height: visible ? 200 : 0
                    anchors.right: control.current ? parent.right : null
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

                Label {
                    id: _text
                    padding: 10
                    text: content
                    visible: Boolean(text)
                    anchors.right: control.current ? parent.right : null

                    horizontalAlignment: current ? Text.AlignRight : Text.AlignLeft
                    width: implicitWidth > parent.width ? parent.width : implicitWidth
                    wrapMode: Text.Wrap
                    color: control.current ? "white" : "black"
                    font.pixelSize: 16
                    font.weight: Font.Light
                    background: Rectangle {
                        radius: 10
                        color: current ? $Colors.colorPrimary : $Colors.colorBgPrimary
                    }

                    Component.onCompleted: {
                        const data = captureLinks(content)
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

        Label {
            id: lockText
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            visible: page.isAIWritting
            width: 250
            wrapMode: Label.Wrap
            text: qsTr("You will write a new message after is finish responding to the previous !")
        }
    }


    Drawer {
        id: mediaDrawer
        width: parent.width
        height: contentColumn.height + 20
        edge: Qt.BottomEdge
        dim: false
        modal: true
        interactive: true

        background: Rectangle {
            color: Qaterial.Colors.gray50
            radius: 30
        }

        Column {
            id: contentColumn
            padding: 15
            spacing: 35
            width: parent.width
            RowLayout {
                width: parent.width
                IconImage {
                    source: Qaterial.Icons.close
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaDrawer.close()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Share a content")
                    font {
                        pixelSize: 16
                        weight: Font.DemiBold
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

            }

            Column {
                width: parent.width - 30
                spacing: 25

                MouseArea {
                    width: parent.width
                    height: rowPickCamera.height
                    onClicked: QtAndroidAppPermissions.openGallery()

                    Row {
                        id: rowPickCamera
                        spacing: 10
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 40
                            height: width
                            radius: 10
                            color: $Colors.colorBgPrimary
                            ToolBarButton {
                                anchors.centerIn: parent
                                icon.source: Qaterial.Icons.camera
                                icon.color: $Colors.colorPrimary
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Label {
                                text: qsTr("Camera")
                                font {
                                    weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }


                Row {
                    spacing: 10
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: width
                        radius: 10
                        color: $Colors.colorBgPrimary

                        ToolBarButton {
                            anchors.centerIn: parent
                            icon.source: Qaterial.Icons.file
                            icon.color: $Colors.colorPrimary
                        }

                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Label {
                            text: qsTr("Documents")
                            font {
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            text: qsTr("Share a file")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 12
                            }
                        }
                    }
                }

                Row {
                    spacing: 10
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: width
                        radius: 10
                        color: $Colors.colorBgPrimary

                        ToolBarButton {
                            anchors.centerIn: parent
                            icon.source: Qaterial.Icons.file
                            icon.color: $Colors.colorPrimary
                        }

                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Label {
                            text: qsTr("Media")
                            font {
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            text: qsTr("Share a photo or video")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 12
                            }
                        }
                    }
                }

                Row {
                    spacing: 10
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        radius: 10
                        height: width
                        color: $Colors.colorBgPrimary

                        ToolBarButton {
                            anchors.centerIn: parent
                            icon.source: Qaterial.Icons.file
                            icon.color: $Colors.colorPrimary
                        }

                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Label {
                            text: qsTr("Contact")
                            font {
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            text: qsTr("Sahre a contact")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 12
                            }
                        }
                    }
                }

                Row {
                    spacing: 10
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: width
                        color: $Colors.colorBgPrimary

                        ToolBarButton {
                            anchors.centerIn: parent
                            icon.source: Qaterial.Icons.file
                            icon.color: $Colors.colorPrimary
                        }

                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Label {
                            text: qsTr("Location")
                            font {
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            text: qsTr("Sahre a location")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }


    MouseArea {
        id: contextMouse
        enabled: false
        anchors.fill: parent
        onClicked: {
            inputField.textArea.focus = false
            enabled = false
        }
    }

    footer: ToolBar {
        id: footerToolbar
        visible: !page.isAIWritting
        height: 50
        background: Rectangle {}
        RowLayout {
            anchors.fill: parent
            anchors.bottomMargin: 10
            spacing: 0
            MouseArea {
                height: 50
                width: 50
                Layout.alignment: Qt.AlignVCenter
                Rectangle {
                    //visible: inputField.text.length === 0
                    width: 40
                    height: 40
                    anchors.centerIn: parent
                    radius: 30
                    color: "transparent"
                    Connections {
                        target: QtAndroidAppPermissions
                        function onImageSelected(img) {
                            const ext = img.split(".").pop()
                            const data = imgToB64.getBase64(img)
                            if (["png", "jpg"].indexOf(ext) !== -1) {
                                const b64_imageUrl = "data:image/png;base64," + data
                                //imageLoader.source = b64_imageUrl
                            }

                            http.uploadImage(ext, data).then(function (res) {
                                console.log("http://34.28.201.80/get_file/" + res)
                                let cdata = {
                                    "id": "TEMP",
                                    "content": "http://34.28.201.80/get_file/" + res,
                                    "pubkey": publicKey,
                                    "removable": true,
                                    "created_at": new Date().getTime() / 1000
                                }
                                messages.append(cdata)
                                Qt.callLater(function (content) {
                                    http.sendMessage(privateKey,
                                                     page.friend.pubkey,
                                                     content).then(
                                                function (rs) {}).catch(
                                                function (err) {
                                                    console.log(JSON.stringify(
                                                                    err))
                                                })
                                }, "http://34.28.201.80/get_file/" + res)
                            }).catch(function (err) {
                                console.log(err)
                            })
                        }
                    }
                    ColorImage {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        opacity: .8
                        source: Qaterial.Icons.paperclip
                    }
                }
                onClicked: {
                    mediaDrawer.open()
                }
            }

            TextArea {
                id: inputField
                font.pixelSize: 22
                //color: "black"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.bottomMargin: 10

                textArea {
                    padding: 10
                    color: "black"
                    background: Rectangle {
                        color: "#e4e4e4"
                        radius: 20
                    }
                    textFormat: TextEdit.PlainText

                    placeholderText: qsTr("Type something...")
                    onFocusChanged: {
                        if(contextMouse.enabled) {
                            footerToolbar.height = 50
                        } else {
                            footerToolbar.height = 120
                        }
                        contextMouse.enabled = true
                    }
                }
            }


            ToolBarButton {
                id: recordAudioButton
                visible: !sendButton.visible
                icon.source: Qaterial.Icons.microphoneOutline
                icon.color: "#004b00"
                Layout.alignment: Qt.AlignVCenter
            }

            ToolBarButton {
                id: sendButton
                enabled: inputField.text.length > 0
                visible: enabled
                icon.source: Qaterial.Icons.send
                icon.color: "#004b00"
                Layout.alignment: Qt.AlignVCenter
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
                    messages.append(cdata)()
                    Qt.callLater(function (content) {
                        if(page.isBotMode) {
                            page.isAIWritting = true
                        }

                        http.sendMessage(privateKey, page.friend.pubkey,
                                         content).then(function (rs) {
                                            page.isAIWritting = false
                                         }).catch(
                                    function (err) {
                                        page.isAIWritting = false
                                        console.log(JSON.stringify(err))
                                    })
                    }, inputField.text)
                    inputField.text = ""
                }
            }
        }
    }

}


