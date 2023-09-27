import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qaterial as Qaterial
import QtWebSockets
import QtMultimedia

import SortFilterProxyModel
import QtAndroidTools

import "../components"
import "../utils"

Page {
    background: Rectangle {
        color: "white"
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
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    leftPadding: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    text: qsTr("Edit profile")
                }
            }
        }
    }
    Column {
        y: 10
        spacing: 15
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter

        InputField {
            id: nameField
            width: parent.width
            height: 50
            field.placeholderTextColor: "grey"
            field.placeholderText: "Name"
            field.text: userInfo.name || ""
        }

        InputField {
            id: emailField
            width: parent.width
            height: 50
            field.placeholderTextColor: "grey"
            field.placeholderText: "Email"
            field.text: userInfo.email || ""
        }

        InputField {
            id: bioField
            width: parent.width
            height: 50
            field.placeholderTextColor: "grey"
            field.placeholderText: "Bio"
            field.text: userInfo.about || ""
        }

        InputField {
            id: professionField
            width: parent.width
            height: 50
            field.placeholderTextColor: "grey"
            field.placeholderText: "Profession"
            field.text: userInfo.profession || ""
        }

        InputField {
            property bool uploadingImage: false
            id: pictureField
            width: parent.width
            height: 50
            field.placeholderTextColor: "grey"
            field.placeholderText: "Picture URL"
            field.text: userInfo.picture || ""
            field.enabled: false
            Qaterial.FabButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                icon.source: pictureField.uploadingImage ? "" : Qaterial.Icons.camera
                onClicked: {
                    QtAndroidAppPermissions.openGallery()
                }

                BusyIndicator {
                    running: pictureField.uploadingImage
                    anchors.centerIn: parent
                    width: 30
                }

                Connections {
                    target: QtAndroidAppPermissions
                    function onImageSelected(img) {
                        const ext = img.split(".").pop()
                        const data = imgToB64.getBase64(img)
                        if (["png", "jpg"].indexOf(ext) !== -1) {
                            const b64_imageUrl = "data:image/png;base64," + data
                        }
                        pictureField.uploadingImage = true

                        http.uploadImage(ext, data).then(function (res) {
                            pictureField.field.text = http.apihost + "/get_file/" + res
                            pictureField.uploadingImage = false
                        }).catch(function (err) {
                            console.log(err)
                            pictureField.uploadingImage = false
                        })
                    }
                }
            }
        }

        Qaterial.RaisedButton {
            property bool busy: false
            height: 55
            text: busy ? "" : "Modifier"
            palette.buttonText: "white"
            backgroundColor: "#1d1d1d"
            enabled: !busy || !pictureField.uploadingImage
            BusyIndicator {
                width: 30
                anchors.centerIn: parent
                running: parent.busy
            }

            onClicked: {
                busy = true
                Qt.callLater(function () {
                    let data = {
                        "name": nameField.field.text,
                        "email": emailField.field.text,
                        "about": bioField.field.text,
                        "profession": professionField.field.text,
                        "picture": pictureField.field.text
                    }
                    http.updateProfile(privateKey, data).then(function (rs) {
                        if (rs === "ok") {
                            busy = false
                            getAuthor(publicKey, true)
                            view.pop()
                        } else {
                            console.log(rs)
                        }
                    }).catch(function (err) {
                        console.log(JSON.stringify(err))
                    })
                })
            }

            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
