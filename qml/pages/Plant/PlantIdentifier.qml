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
import "../../components_generic"
import "../../components"
import "../../"

BPage {
    id: pageControl
    property var plant_results
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
        PlantIdentifierDetails {}
    }

    PositionSource {
        id: gps
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
    }
    header: AppBar {
        title: identifierLayoutView.currentIndex === 0 ? "Back" : "Results"
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
                    property bool fromCamera: false
                    property bool fromGalery: false

                    function openCamera() {
                        fromCamera = true
                        fromGalery = false
                        QtAndroidAppPermissions.openCamera()
                    }
                    function openGallery() {
                        fromGalery = true
                        fromCamera = false
                        QtAndroidAppPermissions.openGallery()
                    }

                    Connections {
                        target: QtAndroidAppPermissions
                        function onImageSelected(path) {
                            image.source = "file://?" + Math.random()
                            image.source = "file://" + path
                            if(fromCamera) analyserButton.clicked()
                            fromGalery  = false
                            fromCamera = false
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
                        Material.background: $Colors.colorPrimary
                        Material.foreground: Material.color(Material.Grey,
                                                            Material.Shade50)
                        Material.accent: Material.color(Material.Grey,
                                                        Material.Shade50)
                        Layout.fillWidth: true
                        visible: Qt.platform.os !== 'ios'
                                 && Qt.platform.os !== 'android'
                        TabButton {
                            text: qsTr("File image")
                        }
                        TabButton {
                            text: qsTr("Camera")
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

                            function chooseFile() {
                                if (Qt.platform.os === 'ios') {
                                    imgPicker.openPicker()
                                } else if (Qt.platform.os === 'android') {
                                    androidToolsLoader.item.openGallery()
                                } else
                                    fileDialog.open()
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
                                    fillMode: (Qt.platform.os === 'ios'
                                               || Qt.platform.os === 'android') ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                                }
                                ItemNoImage {
                                    visible: image.source.toString() === ""
                                    anchors.fill: parent
                                    spacing: 10
                                    padding: 25

                                    title: qsTr("Identify plant")
                                    subtitle: qsTr("Be sure to take a clear, bright photo that includes only the plant you want to identify")
                                    onClicked: tabView.chooseFile
                                }

                                Column {
                                    width: 70
                                    anchors {
                                        bottom: parent.bottom
                                        bottomMargin: 10

                                        right: parent.right
                                        rightMargin: 10
                                    }
                                    spacing: 7

                                    ClipRRect {
                                        visible: image.source.toString() !== ""
                                        width: 60
                                        height: width
                                        radius: height / 2

                                        ButtonWireframe {
                                            fullColor: true
                                            primaryColor: $Colors.colorPrimary
                                            anchors.fill: parent
                                            onClicked: tabView.chooseFile()
                                            IconSvg {
                                                anchors.centerIn: parent
                                                source: Icons.image
                                                color: "white"
                                            }
                                        }
                                    }

                                    ClipRRect {
                                        visible: Qt.platform.os == 'ios' || Qt.platform.os == 'android'
                                        width: 60
                                        height: width
                                        radius: height / 2

                                        ButtonWireframe {
                                            fullColor: true
                                            primaryColor: $Colors.colorPrimary
                                            anchors.fill: parent
                                            onClicked: {
                                                if (Qt.platform.os === 'ios') {
                                                    imgPicker.openCamera()
                                                } else {
                                                    androidToolsLoader.item.openCamera()
                                                }
                                            }
                                            IconSvg {
                                                anchors.centerIn: parent
                                                source: Icons.camera
                                                color: "white"
                                            }
                                        }
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
                            text: qsTr("New")
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
                            text: qsTr("Analyse")
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
                                        "modifiers": ["crops_fast", "similar_images"],
                                        "language": Qt.locale().name.slice(0, 2),
                                        "plant_details": ["common_names", "taxonomy", "url", "wiki_description", "wiki_image", "wiki_images", "edible_parts", "propagation_methods"],
                                        "longitude": gps.position.coordinate.longitude,
                                        "latitude": gps.position.coordinate.latitude
                                    }
                                    Http.request("POST",
                                                 "https://plant.id/api/v2/identify",
                                                 data).then(function (r) {
                                                     let datas = JSON.parse(r)
                                                     pageControl.plant_results = datas
                                                     imgAnalysisSurface.loading = false
                                                     identifierLayoutView.currentIndex = 1
                                                     if (datas.is_plant)
                                                         identifedPlantListView.model
                                                                 = datas.suggestions.slice(
                                                                     0, 3)
                                                     else
                                                         identifedPlantListView.model = []
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

                    }

                    Image2Base64 {
                        id: imgTool
                    }

                    RowLayout {
                        visible: false
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        ButtonWireframe {
                            text: qsTr("File image")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            height: 45
                            onClicked: tabView.currentIndex = 1 //fileDialog.open()
                        }
                    }

//                    Item {
//                        Layout.fillHeight: true
//                        Layout.fillWidth: true
//                    }
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
                            font.pixelSize: 16
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: pageControl.plant_results?.is_plant
                                     ?? false
                            text: qsTr("One of these results should match your search")
                        }
                        Label {
                            font.pixelSize: 28
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: !pageControl.plant_results?.is_plant
                            text: qsTr("No plant detected")
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
                                text: modelData["plant_name"]
                                font.pixelSize: 16
                            }
                            Label {
                                text: modelData["plant_details"]["common_names"][0]
                            }
                        }

                        height: 100
                        width: identifedPlantListView.width

                        ClipRRect {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 80
                            height: width
                            radius: height / 2

                            Rectangle {
                                anchors.fill: parent
                                color: "teal"
                                Image {
                                    source: modelData["plant_details"]["wiki_image"]["value"]
                                    anchors.fill: parent
                                }
                            }
                        }

                        onClicked: page_view.push(plantResultPage, {
                                                      "plant_data": modelData
                                                  })
                    }
                }
            }
        }
    }
}
