import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import ThemeEngine
import ImagePicker
import Qt.labs.platform
import QtAndroidTools

import "components" as Components

Components.ClipRRect {
    property alias image_source: image.source

    Rectangle {
        id: area
        anchors.fill: parent
        color: "#f0f0f0"
        radius: 10

        FileDialog {
            id: fileDialog
            nameFilters: ["Image file (*.png *.jpg *.jpeg *.gif)"]
            onAccepted: {
                if (Qt.application.os === "windows" || Qt.application.os === "osx"
                        || Qt.application.os === "linux") {
                    image_source = selectedFile
                } else {
                    image_source = currentFile
                }
            }
        }

        IconSvg {
            visible: image_source.toString() === ""
            source: "qrc:/assets/icons_material/camera.svg"
            anchors.centerIn: parent
            anchors.margins: 7
            color: Theme.colorPrimary
        }

        Image {
            id: image
            anchors.fill: parent
            clip: true
        }

        ImagePicker {
            id: imgPicker
            onCapturedImage: function (path) {
                image_source = "file://" + path
            }
        }

        Item {
            function openCamera() {
                QtAndroidAppPermissions.openCamera()
            }
            function openGallery() {
                QtAndroidAppPermissions.openGallery()
            }

            Connections {
                target: QtAndroidAppPermissions
                function onImageSelected(path) {
                    image_source = "file://" + path
                }
            }
        }


        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"
            onClicked: {
                if (Qt.platform.os === 'ios') {
                    imgPicker.openCamera()
                } else if (Qt.platform.os === 'android') {
                    androidToolsLoader.item.openCamera()
                } else {
                    fileDialog.open()
                }
            }
        }
    }

}

