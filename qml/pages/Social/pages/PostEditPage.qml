import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia
import ImagePicker

import SortFilterProxyModel
import QtAndroidTools

import "../components" as Control
import "../utils"

Page {
    id: page
    property bool uploadingImage: false
    property ListModel mediaModel: ListModel {}

    property bool haveImage: false
    property string media_name: ""
    background: Rectangle {
        color: "white"
    }
    header: ToolBar {
        contentHeight: 60
        height: 65
        background: Rectangle {}
        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: 3
            spacing: 0
            Control.ButtonImage {
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
                    text: qsTr("Nouvelle publication")
                }
            }
            Control.ToolBarButton {
                function handleUploadImage(img) {
                    const ext = img.split(".").pop()
                    const data = imgToB64.getBase64(img)
                    let b64_imageUrl
                    if (["png", "jpg"].indexOf(ext) !== -1) {
                        b64_imageUrl = "data:image/png;base64," + data
                    }

                    mediaModel.append({
                                          "path": b64_imageUrl,
                                          "done": false,
                                          "name": ""
                                      })
                    console.log("image selected", ext)
                    var element = mediaModel.get(mediaModel.count - 1)
                    uploadingImage = true
                    http.uploadImage(ext, data).then(function (res) {
                        console.log(res)
                        media_name = res
                        element.done = true
                        element.name = res
                        uploadingImage = false
                    }).catch(function (err) {
                        console.log(err)
                        element.done = false
                        mediaModel.remove(mediaModel.count - 1)
                        haveImage = false
                        uploadingImage = false
                    })
                }

                icon.source: Qaterial.Icons.attachment
                onClicked: {
                    if (Qt.platform.os === 'ios') {
                        iosPermRequester.grantOrRunCamera(function () {
                            imgPicker.openPicker()
                        })
                    } else if (Qt.platform.os === 'android') {
                        QtAndroidAppPermissions.openGallery()
                    }
                }

                ImagePicker {
                    id: imgPicker
                    onCapturedImage: function (path) {
                        handleUploadImage("file://" + path)
                    }
                }

                Connections {
                    target: QtAndroidAppPermissions
                    function onImageSelected(img) {
                        handleUploadImage(img)
                    }

                }
            }
        }
    }
    Column {
        y: 10
        spacing: 15
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            width: parent.width
            height: page.height - 320
            radius: 8
            border.color: "transparent"
            border.width: 1
            Control.TextArea {
                id: postField
                y: 5
                height: 300
                width: parent.width
                textArea.placeholderText: "Content..."
                textArea.color: 'black'
                textArea.textFormat: TextEdit.PlainText
            }
        }
        ListView {
            model: mediaModel
            width: parent.width
            height: 120
            orientation: Qt.Horizontal
            spacing: 10
            visible: mediaModel.count > 0
            delegate: Rectangle {
                color: Qaterial.Colors.gray900
                width: 120
                height: 120
                radius: 8
                border.color: "transparent"
                Qaterial.ClipRRect {
                    anchors.fill: parent
                    radius: parent.radius
                    Image {
                        anchors.fill: parent
                        source: path
                    }

                    BusyIndicator {
                        running: !done
                        anchors.centerIn: parent
                    }

                    Qaterial.Icon {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        visible: done
                        y: 10
                        icon: Qaterial.Icons.checkCircle
                        color: Qaterial.Colors.lightGreen
                    }
                }
            }
        }
    }
    Qaterial.FabButton {
        property bool busy: false
        property bool enable: (!busy && postField.text !== "")
                              && (!haveImage || media_name !== "")
        opacity: enable ? 1 : .7
        //icon.source: Qaterial.Icons.postOutline
        Qaterial.Icon {
            anchors.centerIn: parent
            color: "white"
            rotation: -90
            icon: Qaterial.Icons.sendOutline
        }

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 20
        }

        BusyIndicator {
            width: 30
            anchors.centerIn: parent
            running: parent.busy
        }

        onClicked: {
            if (busy || !enable)
                return
            busy = true
            Qt.callLater(function () {
                let content = postField.textArea.text
                if (mediaModel.count > 0) {
                    for (var i = 0; i < mediaModel.count; i++) {
                        let element = mediaModel.get(i)
                        if (element.done) {
                            content += "\n%1/get_file/".arg(
                                        http.apihost) + element.name
                        }
                    }
                }
                console.log("finale", content, media_name)
                http.sendPost(privateKey, content).then(function (rs) {
                    if (rs === "ok") {
                        postField.text = ""
                        view.pop()
                    } else {
                        console.log(rs)
                    }
                }).catch(function (err) {
                    console.log(JSON.stringify(err))
                })
            })
        }
    }
}
