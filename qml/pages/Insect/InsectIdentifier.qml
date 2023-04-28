import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import ImagePicker
import Qt.labs.platform
import QtAndroidTools
import Qt5Compat.GraphicalEffects
import QtPositioning
import ThemeEngine 1.0

import MaterialIcons
import "../../components_js/Http.js" as Http
import "../../components"
import "../../"

Page {
    id: pageControl
    property var insects: []
    property var view: pageControl.StackView.view
    padding: 0
    onVisibleChanged: {
        if (visible) {
            image.source = ""
        } else {
            tabBar.currentIndex = 0
            image.source = ""
        }
    }

    Component {
        id: plantResultPage
        Page {}
    }

    PositionSource {
        id: gps
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
    }
    header: AppBar {
        title: identifierLayoutView.currentIndex === 0 ? "Identification d'insecte" : "Resultat"
        noAutoPop: true
        leading.onClicked: {
            if (identifierLayoutView.currentIndex === 0) {
                pageControl.view.pop()
            } else if (identifierLayoutView.currentIndex === 1) {
                tabBar.currentIndex = 0
                identifierLayoutView.currentIndex = 0
            } else {
                identifierLayoutView.currentIndex--
            }
        }
        actions: [
            AppBarButton {
                icon: Icons.camera
                visible: (Qt.platform.os == 'ios'
                          || Qt.platform.os == 'android')
                         && identifierLayoutView.currentIndex === 0
                onClicked: {
                    if (Qt.platform.os === 'ios') {
                        imgPicker.openCamera()
                    } else {
                        androidToolsLoader.item.openCamera()
                    }
                }
                width: 64
                height: 64
            }
        ]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        Loader {
            id: androidToolsLoader
            active: Qt.platform.os === "android"
            sourceComponent: Component {
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
                            image.source = "file://?" + Math.random()
                            image.source = "file://" + path
                        }
                    }
                }
            }
        }

        StackLayout {
            id: identifierLayoutView
            property bool viewCamera: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 0
            currentIndex: 0
            onCurrentIndexChanged: {
                if (accessCam.active)
                    accessCam.active = false
                tabBar.currentIndex = 0
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2
                    TabBar {
                        id: tabBar
                        topPadding: 0
                        Material.background: "#00c395"
                        Material.foreground: Material.color(Material.Grey,
                                                            Material.Shade50)
                        Material.accent: Material.color(Material.Grey,
                                                        Material.Shade50)
                        Layout.fillWidth: true
                        visible: Qt.platform.os !== 'ios'
                                 && Qt.platform.os !== 'android'
                        TabButton {
                            text: "Fichier"
                        }
                        TabButton {
                            text: "Camera"
                            visible: Qt.platform.os !== 'ios'
                        }
                        onCurrentIndexChanged: {
                            image.source = ""
                        }
                    }

                    Item {
                        id: imgAnalysisSurface
                        property string savedImagePath: ""
                        property bool loading: false
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        StackLayout {
                            id: tabView
                            anchors.fill: parent
                            currentIndex: tabBar.currentIndex
                            onCurrentIndexChanged: {
                                if (currentIndex === 0)
                                    accessCam.active = false
                                else
                                    tm.start()
                            }

                            Timer {
                                id: tm
                                interval: 1000
                                onTriggered: {
                                    accessCam.active = true
                                    if (accessCam.status === Loader.Ready) {
                                        accessCam.item.camera.start()
                                    } else {
                                        start()
                                    }
                                }
                            }

                            Item {
                                Image {
                                    id: image
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectFit
                                }
                                ItemNoImage {
                                    visible: image.source.toString() === ""
                                    anchors.fill: parent
                                    spacing: 10
                                    padding: 25

                                    title: 'Identifier un insecte'
                                    subtitle: 'Assurez-vous de prendre une photo nette et lumineuse comprenant uniquement le parasite que vous souhaitez identifier.'
                                    onClicked: function() {
                                        if (Qt.platform.os === 'ios') {
                                            imgPicker.openPicker()
                                        } else if (Qt.platform.os === 'android') {
                                            androidToolsLoader.item.openGallery()
                                        } else
                                            fileDialog.open()
                                    }
                                }
                            }

                            Loader {
                                id: accessCam
                                asynchronous: true
                                active: false

                                Component {
                                    id: cameraView
                                    Item {
                                        id: control
                                        property alias camera: cam
                                        property alias imgCapture: imageCapture
                                        property alias image_view: image2
                                        anchors.fill: accessCam
                                        Connections {
                                            target: tabBar
                                            function onCurrentIndexChanged(index) {
                                                if (tabBar.currentIndex === 0)
                                                    cam.stop()
                                            }
                                        }
                                        CaptureSession {
                                            camera: Camera {
                                                id: cam
                                            }

                                            imageCapture: ImageCapture {
                                                id: imageCapture
                                                onImageSaved: function (id, path) {
                                                    image.source = "file://" + path
                                                    image2.source = "file://" + path
                                                    image2.visible = true
                                                    analyserButton.clicked()
                                                }
                                                onImageCaptured: function (id, path) {
                                                    image2.source = imageCapture.preview
                                                }

                                                onErrorOccurred: function (id, error, message) {}
                                            }
                                            videoOutput: tabBar.currentIndex
                                                         === 1 ? videoOutput : null
                                        }

                                        Rectangle {
                                            width: (parent.width / 2) + 40
                                            height: width
                                            radius: width / 3
                                            y: 40
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            border.color: "#00c395"
                                            border.width: 6
                                            ClipRRect {
                                                anchors.fill: parent
                                                anchors.margins: 5
                                                radius: parent.radius
                                                VideoOutput {
                                                    id: videoOutput
                                                    width: control.width + 50
                                                    height: width
                                                    anchors.centerIn: parent
                                                }
                                                Image {
                                                    id: image2
                                                    visible: false
                                                    width: control.width / 2
                                                    height: width
                                                    anchors.centerIn: parent
                                                    source: image.source
                                                    fillMode: Image.PreserveAspectCrop
                                                }
                                            }
                                        }
                                    }
                                }
                                sourceComponent: cameraView
                            }
                        }

                        BusyIndicator {
                            running: parent.loading
                            anchors.centerIn: parent
                        }

                        FileDialog {
                            id: fileDialog
                            nameFilters: ["Image file (*.png *.jpg *.jpeg *.gif)"]
                            onAccepted: {
                                if (Qt.application.os === "windows"
                                        || Qt.application.os === "osx"
                                        || Qt.application.os === "linux") {
                                    image.source = selectedFile
                                } else {
                                    image.source = currentFile
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        Layout.rightMargin: 10
                        Layout.leftMargin: 5

                        Item {
                            Layout.fillWidth: true
                        }

                        ImagePicker {
                            id: imgPicker
                            onCapturedImage: function (path) {
                                image.source = "file://" + path
                            }
                        }

                        NiceButton {
                            text: "Nouveau"
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 120
                            visible: tabBar.currentIndex === 1
                                     && accessCam.item?.image_view.visible === true
                            height: 45
                            onClicked: {
                                if (accessCam.item.image_view.visible) {
                                    accessCam.item.image_view.visible = false
                                } else {
                                    analyserButton.clicked()
                                }
                            }
                        }

                        NiceButton {
                            id: analyserButton
                            Layout.alignment: Qt.AlignHCenter
                            text: "Analyser"
                            icon.source: Icons.magnify
                            Layout.preferredWidth: Qt.platform.os === 'ios' ? 120 : 180
                            Layout.preferredHeight: 60
                            visible: image.source.toString() !== ""
                                     || accessCam.active
                            onClicked: {
                                if (image.source.toString() !== "") {
                                    imgAnalysisSurface.loading = true
                                    let data = {
                                        "images": [imgTool.getBase64(
                                                image.source.toString().replace(
                                                    Qt.platform.os
                                                    === "windows" ? "file:///" : "file://",
                                                    ""))],
                                        "longitude": gps.position.coordinate.longitude,
                                        "latitude": gps.position.coordinate.latitude
                                    }
                                    Http.request(
                                                "POST",
                                                "https://insect.mlapi.ai/api/v1/identification",
                                                data,
                                                "0GqFkaJYbGLGG4tKMTjZ5FymjSbhlGfUriiZ7FkGIyX2Tm0qK4").then(
                                                function (r) {
                                                    let datas = JSON.parse(r)
                                                    console.log(JSON.stringify(
                                                                    datas))
                                                    imgAnalysisSurface.loading = false
                                                    pageControl.insects = datas.result.classification.suggestions
                                                    identifedPlantListView.model
                                                            = pageControl.insects
                                                    identifierLayoutView.currentIndex = 1
                                                    console.log(JSON.stringify(
                                                                    datas))
                                                }).catch(function (e) {
                                                    imgAnalysisSurface.loading = false
                                                    console.log('Erreur',
                                                                JSON.stringify(
                                                                    e))
                                                })
                                } else {
                                    let path = StandardPaths.writableLocation(
                                            StandardPaths.PicturesLocation).toString(
                                            ).replace(
                                            Qt.application.os
                                            === "windows" ? "file:///" : "file://",
                                            "")
                                    let ln = (Math.random(
                                                  ) % 10 * 100000).toFixed(0)
                                    let filePath = path + "/" + ln + '.jpg'
                                    imgAnalysisSurface.savedImagePath = filePath
                                    accessCam.item.imgCapture.captureToFile(
                                                filePath)
                                }
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Image2Base64 {
                        id: imgTool
                    }

                    RowLayout {
                        visible: false
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        ButtonWireframe {
                            text: "Fichier"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            height: 45
                            onClicked: tabView.currentIndex = 1 //fileDialog.open()
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
            Item {
                ListView {
                    id: identifedPlantListView
                    anchors.fill: parent
                    model: 0
                    spacing: 5
                    clip: true
                    header: Column {
                        width: identifedPlantListView.width
                        padding: 10
                        spacing: 3
                        Label {
                            font.pixelSize: 18
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: pageControl.insects.length > 0 ?? false
                            text: "Un de ces résultats devrait correspondre à votre recherche"
                        }
                        Label {
                            font.pixelSize: 28
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: pageControl.insects.length === 0
                            text: "Ceci n'est pas un insecte"
                        }
                    }

                    delegate: ItemDelegate {
                        required property int index
                        required property variant modelData

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            spacing: 10
                            Label {
                                text: modelData["name"]
                                font.pixelSize: 21
                            }
                        }

                        height: 60
                        width: identifedPlantListView.width
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 55
                            height: 55
                            radius: width / 2
                            color: "teal"
                            Label {
                                anchors.centerIn: parent
                                color: "white"
                                text: parseInt(
                                          modelData["probability"] * 100) + "%"
                            }
                        }
                    }
                }
            }
        }
    }
}
