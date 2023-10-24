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
import QtPositioning
import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import MaterialIcons

import "../"
import "../Insect/"
import "../Garden/"
import "../../"
import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    id: planteDeseaseControl
    property variant analyseResults
    padding: 0

    objectName: "Health"

    onVisibleChanged: {
        if (visible)
            image.source = ""
        else {
            if (accessCam.active)
                accessCam.active = false
            tabView.currentIndex = 0
            tabBar.currentIndex = 0
            image.source = ""
        }
    }

    Component {
        id: resultDeseaseDetailPage
        PlantDeseaseDetails {}
    }
    Component {
        id: plantDeseaseEncyclopedie
        PlantDeseaseEncylopedie {}
    }

    PositionSource {
        id: gps
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
    }

    header: AppBar {
        width: parent.width
        isHomeScreen: identifierLayoutView.currentIndex === 0
        title: {
            switch (identifierLayoutView.currentIndex) {
            case 0:
                return "Health menu"
            case 1:
                return "Disease detection"
            case 2:
                return "Results"
            default:
                return "Not found"
            }
        }
        noAutoPop: true
        z: 10
        statusBarVisible: false
        leading.onClicked: {
            if (identifierLayoutView.currentIndex === 0) {
                planteDeseaseControl.StackView.view.pop()
            } else if (identifierLayoutView.currentIndex === 4
                       || identifierLayoutView.currentIndex === 3) {
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
        z: 1
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
                        QtAndroidAppPermissions.openImageGallery()
                    }

                    Connections {
                        target: QtAndroidAppPermissions
                        function onImageSelected(path) {
                            image.source = "file://?" + Math.random()
                            image.source = "file://" + path
                            if (fromCamera)
                                analyserButton.clicked()
                            fromGalery = false
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
                if (currentIndex !== 1) {
                    if (accessCam.active) {
                        tabView.currentIndex = 0
                        tabBar.currentIndex = 0
                        accessCam.active = false
                    }
                }
            }
            Item {

                Item {
                    anchors.fill: parent
                    anchors.topMargin: 10
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0

                    Flickable {
                        id: optionsFlickable
                        anchors.fill: parent
                        contentHeight: _insideColumn.height
                        clip: true
                        Container {
                            width: parent.width - 20
                            background: Rectangle {
                                color: $Colors.gray50
                            }

                            contentItem: Column {
                                id: _insideColumn
                                width: parent.width
                                topPadding: diseaseSearchBox.height + 40
                                leftPadding: 10
                                rightPadding: 10
                                spacing: 30
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 10
                                Rectangle {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 140
                                    radius: 10
                                    Image {
                                        anchors.fill: parent
                                        source: "qrc:/assets/img/alocasia 1.png"
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    Label {
                                        width: parent.width - 7
                                        wrapMode: Label.Wrap
                                        text: qsTr("Check your plant health status")
                                        color: $Colors.colorPrimary
                                        font {
                                            pixelSize: 15
                                            weight: Font.DemiBold
                                        }
                                    }
                                    Label {
                                        width: parent.width
                                        wrapMode: Text.Wrap
                                        text: qsTr("Take photos of the diseased parts of your plant, and get a diagnosis.")
                                        font {
                                            pixelSize: 14
                                        }
                                    }

                                    NiceButton {
                                        text: qsTr("Start diagnosis")
                                        width: parent.width
                                        height: 50
                                        anchors.topMargin: 10

                                        foregroundColor: $Colors.white
                                        backgroundColor: $Colors.colorPrimary
                                        radius: 10

                                        onClicked: identifierLayoutView.currentIndex++
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                height: 120
                                spacing: 10
                                Item {
                                    Layout.preferredWidth: 50
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: width
                                    radius: 15
                                    gradient: $Colors.gradientPrimary
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        IconSvg {
                                            source: Icons.bug
                                            color: $Colors.white
                                            width: parent.width / 2
                                            height: width
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Label {
                                            text: qsTr("Identify an insect")
                                            color: $Colors.white
                                            width: parent.width
                                            font.pixelSize: 16
                                            font.weight: Font.DemiBold
                                            wrapMode: Text.Wrap
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: page_view.push(navigator.insectIdentifier)
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: width
                                    color: $Colors.gray50
                                    radius: 15
                                    border {
                                        width: 1
                                        color: $Colors.colorPrimary
                                    }
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        IconSvg {
                                            source: "qrc:/assets/icons_custom/library.svg"
                                            color: $Colors.colorPrimary
                                            width: parent.width / 2
                                            height: width
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Label {
                                            text: qsTr("Encyclopedia of diseases")
                                            color: $Colors.colorPrimary
                                            width: parent.width
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                            wrapMode: Text.Wrap
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: page_view.push(navigator.deseaseEncyclopedie)
                                    }
                                }

                                Item {
                                    Layout.preferredWidth: 50
                                }
                            }

                            Container {
                                width: parent.width
                                anchors.topMargin: 150
                                background: Rectangle {
                                    color: $Colors.gray200
                                    radius: 10
                                }

                                contentItem: Column {
                                        width: parent.width
                                        padding: 15
                                        spacing: 10
                                        RowLayout {
                                            width: parent.width
                                            spacing: 15
                                            IconSvg {
                                                Layout.preferredWidth: 80
                                                Layout.preferredHeight: 120
                                                source: "qrc:/assets/img/jardinier.png"
                                            }
                                            Column {
                                                Layout.fillWidth: true
                                                Label {
                                                    text: qsTr("Ask our plant experts")
                                                    color: $Colors.colorPrimary
                                                    width: parent.width - 20
                                                    wrapMode: Text.Wrap
                                                    font {
                                                        pixelSize: 24
                                                        weight: Font.Bold
                                                    }
                                                }
                                                Label {
                                                    width: parent.width - 20
                                                    wrapMode: Text.Wrap
                                                    text: qsTr("Take photos of the diseased parts of your plant, and get a diagnosis.")
                                                    font {
                                                        pixelSize: 16
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            gradient: $Colors.gradientPrimary
                                            width: parent.width - 20
                                            height: 40
                                            radius: height/2
                                            Text {
                                                anchors.centerIn: parent
                                                text: qsTr("Ask our plant experts")
                                                color: $Colors.white
                                                font {
                                                    pixelSize: 16
                                                    weight: Font.DemiBold
                                                }
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: page_view.push(navigator.askToExperts)
                                            }
                                        }
                                    }
                            }


                            Column {
                                width: parent.width
                                spacing: 5
                                Item {
                                    height: 70
                                }

                                Label {
                                    text: qsTr("Some diseases")
                                    color: $Colors.colorPrimary
                                    font {
                                        pixelSize: 16
                                        weight: Font.Bold
                                    }
                                }

                                PlantDeseaseEncylopedie {
                                    width: parent.width
                                    height: planteDeseaseControl.height
                                    header: Item {}
                                    hideSearchBar: true
                                }

                            }

                        }

                    }
                }

                Rectangle {
                    anchors {
                        bottom: parent.top
                        bottomMargin: -180
                        horizontalCenter: parent.horizontalCenter
                    }

                    height: 1200
                    width: height / 1.5
                    radius: height

                    color: $Colors.primary
                }

                Column {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        leftMargin: 15
                        rightMargin: 15
                    }

                    Column {
                        id: diseaseSearchBox
                        width: parent.width - 30
                        spacing: 7
                        anchors.horizontalCenter: parent.horizontalCenter

                        RowLayout {
                            width: parent.width
                            anchors.topMargin: 5

                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                radius: height/2
                                color: $Colors.white


                                IconSvg {
                                    width: parent.width - 4
                                    height: width
                                    anchors.centerIn: parent
                                    source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                                    color: $Colors.colorPrimary
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: appDrawer.open()
                                    }
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                Label {
                                    text: qsTr("Health menu")
                                    font {
                                        pixelSize: 36
                                        family: "Courrier"
                                        weight: Font.Bold
                                    }
                                    color: $Colors.white
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Label {
                                    text: qsTr("Diagnose the health of your plants")
                                    opacity: .5
                                    color: $Colors.white
                                    font {
                                        pixelSize: 14
                                        family: "Courrier"
                                        weight: Font.Bold
                                    }
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                radius: height / 2
                                color: $Colors.white


                                IconSvg {
                                    width: parent.width - 4
                                    height: width
                                    anchors.centerIn: parent
                                    source: Icons.bell
                                    color: $Colors.colorPrimary
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: page_view.push(navigator.loginPage)
                                    }
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: 60
                            MouseArea {
                                id: diseaseSearchBoxMS
                                anchors.fill: parent
                                anchors.rightMargin: 70
                                onClicked: {
                                    page_view.push(navigator.deseaseEncyclopedie)
                                }
                            }
                            RowLayout {
                                anchors.top: parent.top
                                anchors.topMargin: 14
                                anchors.left: parent.left
                                anchors.leftMargin: 25
                                anchors.right: parent.right
                                anchors.rightMargin: 25
                                spacing: 15

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    z: 5
                                    color: "#BBFEEA"
                                    radius: height/2
                                    Text {
                                        text: qsTr("Search for disease")
                                        color: $Colors.gray600
                                        leftPadding: 15
                                        font.pixelSize: 14
                                        anchors {
                                            verticalCenter: parent.verticalCenter
                                            leftMargin: 25
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredHeight: 50
                                    Layout.preferredWidth: 50
                                    color: $Colors.white
                                    radius: 25

                                    IconSvg {
                                        anchors.centerIn: parent
                                        source: Icons.camera
                                        color: $Colors.colorPrimary
                                    }
                                }

                            }

                        }

                    }
                }


            }

            Item {
                Rectangle {
                    id: head
                    anchors {
                        bottom: parent.top
                        bottomMargin: -130
                        horizontalCenter: parent.horizontalCenter
                    }

                    height: 1200
                    width: height / 1.7
                    radius: height
                    z: 1

                    gradient: $Colors.gradientPrimary
                }

                Image {
                    z: 3
                    width: 120
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: head.bottom
                    anchors.bottomMargin: -height / 2
                    source: "qrc:/assets/img/plant-with-insect.png"

                    IconSvg {
                        anchors.centerIn: parent
                        source: "qrc:/assets/img/overlay-scan.svg"
                        color: "white"
                    }

                    ClipRRect {
                        visible: Qt.platform.os == 'ios'
                                 || Qt.platform.os == 'android'
                        width: 50
                        height: width
                        radius: height / 2

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: -height/2
                        }

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

                ColumnLayout {
                    anchors.fill: parent
                    anchors {
                        top: head.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        topMargin: 80
                    }

                    spacing: 2
                    TabBar {
                        id: tabBar
                        topPadding: 0
                        visible: Qt.platform.os !== 'ios'
                                 && Qt.platform.os !== 'android'
                        Material.background: $Colors.colorPrimary
                        Material.foreground: Material.color(Material.Grey,
                                                            Material.Shade50)
                        Material.accent: Material.color(Material.Grey,
                                                        Material.Shade50)
                        Layout.fillWidth: true
                        TabButton {
                            text: qsTr("File image")
                            onClicked: tabView.currentIndex = 0
                        }
                        TabButton {
                            text: qsTr("Camera")
                            visible: Qt.platform.os !== 'ios'
                            onClicked: tabView.currentIndex = 1
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
                        Layout.topMargin: 80
                        StackLayout {
                            id: tabView
                            anchors.fill: parent
                            onCurrentIndexChanged: {
                                if (currentIndex === 1) {
                                    tm.start()
                                } else {
                                    accessCam.active = false
                                }
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
                                interval: 500
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
                                    anchors.margins: 35
                                    fillMode: (Qt.platform.os == 'ios'
                                               || Qt.platform.os == 'android') ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                                }
                                ItemNoImage {
                                    visible: image.source.toString() === ""
                                    anchors.fill: parent
                                    spacing: 10
                                    padding: 25

                                    title: ""
                                    subtitle: qsTr("Be sure to take a clear, bright photo that includes only the sick part of the plant you want to identify")
                                    onClicked: tabView.chooseFile
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
                                                if (tabBar.currentIndex !== 1) {
                                                    cam.stop()
                                                }
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
                                                onErrorOccurred: function (id, error, message) {
                                                    console.log(id,
                                                                error, message)
                                                }
                                            }
                                            videoOutput: tabView.currentIndex
                                                         === 1 ? videoOutput : null
                                        }

                                        Rectangle {
                                            width: (parent.width / 2) + 40
                                            height: width
                                            radius: width / 3
                                            y: 20
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            border.color: "#00c395"
                                            border.width: 6
                                            ClipRRect {
                                                anchors.fill: parent
                                                anchors.margins: 5
                                                radius: parent.radius
                                                VideoOutput {
                                                    id: videoOutput
                                                    width: control.width
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
                        Layout.leftMargin: 0

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
                            visible: tabView.currentIndex === 1
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
                                        "disease_details": ["cause", "treatment", "common_names", "classification", "description", "url"],
                                        "modifiers": ["similar_images"],
                                        "language": Qt.locale().name.slice(0, 2),
                                        "longitude": gps.position.coordinate.longitude,
                                        "latitude": gps.position.coordinate.latitude
                                    }
                                    Http.request("POST",
                                                 "https://plant.id/api/v2/health_assessment",
                                                 data).then(function (r) {
                                                     let datas = JSON.parse(r)
                                                     planteDeseaseControl.analyseResults = datas
                                                     imgAnalysisSurface.loading = false
                                                     page_view.push(navigator.diseaseIdentifierResultsPage, {
                                                        "resultsList": datas.health_assessment.diseases,
                                                        "scanedImage": image.source.toString(),
                                                        "isPlant": datas.is_plant,
                                                        "healthyProbability": planteDeseaseControl.analyseResults?.health_assessment.is_healthy_probability
                                                        })
                                                 }).catch(function (e) {
                                                     imgAnalysisSurface.loading = false
                                                     console.log(JSON.stringify(
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
                }

            }
        }
    }
}
