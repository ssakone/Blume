import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia

import SortFilterProxyModel
import QtAndroidTools

import "../components" as Control
import "../utils"

Page {
    id: page
    property bool uploadingImage: false
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
                icon.source: Qaterial.Icons.attachment
                onClicked: {
                    QtAndroidAppPermissions.openGallery()
                }


                Connections {
                    target: QtAndroidAppPermissions
                    function onImageSelected(img) {
                        const ext = img.split(".").pop()
                        const data = imgToB64.getBase64(img)
                        if (["png", "jpg"].indexOf(ext) !== -1) {
                            const b64_imageUrl = "data:image/png;base64," + data
                            imageLoader.source = b64_imageUrl
                        }
                        haveImage = true
                        uploadingImage = true

                        http.uploadImage(ext, data).then(function(res) {
                            media_name = res
                            uploadingImage = false
                        }).catch(function(err) {
                            console.log(err)
                            haveImage = false
                            uploadingImage = false
                        })
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
        Rectangle {
            color:  Qaterial.Colors.gray900
            width: 160
            height: 160
            radius: 8
            border.color: "transparent"
            visible: haveImage
            Qaterial.ClipRRect {
                anchors.fill: parent
                radius: parent.radius
                Image {
                    id: imageLoader
                    anchors.fill: parent
                }

                BusyIndicator {
                    running: uploadingImage
                    anchors.centerIn: parent
                }

                Qaterial.Icon {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    y: 10
                    icon: Qaterial.Icons.checkCircle
                    color: Qaterial.Colors.lightGreen
                }
            }
        }
    }
    Qaterial.FabButton {
        property bool busy: false
        property bool enable: (!busy && postField.text !== "") && (!haveImage || media_name !== "")
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
            if (busy || !enable) return
            busy = true
            Qt.callLater(function () {
                let content = postField.textArea.text
                if (haveImage && media_name !== "") {
                    content += "\n%1/get_file/".arg(http.apihost) + media_name
                }
                console.log("finale", content, media_name)
                http.sendPost(privateKey, content).then(
                            function (rs) {
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
