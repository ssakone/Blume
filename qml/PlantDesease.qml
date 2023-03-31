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

import ThemeEngine 1.0

import MaterialIcons
import "components"

Popup {
    id: planteDeseasePopup
    dim: true
    modal: true
    property variant analyseResults
    width: appWindow.width
    height: appWindow.height
    parent: appWindow.contentItem
    padding: 0

    onClosed:  {
        if (accessCam.active)
            accessCam.active = false
        tabView.currentIndex = 0
        tabBar.currentIndex = 0
    }

    PlantDeseaseDetails {
        id: resultDeseaseDetailPopup
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        Rectangle {
            color: "#00c395"
            Layout.preferredHeight: Qt.platform.os == 'ios' ? 90 : 65
            Layout.fillWidth: true
            RowLayout {
                width: parent.width
                anchors.verticalCenterOffset: Qt.platform.os == 'ios' ? 20 : 0
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                AppBarButton {
                    id: buttonBackBg
                    icon: "qrc:/assets/menus/menu_back.svg"
                    onClicked: {
                        if (identifierLayoutView.currentIndex === 0) {
                            planteDeseasePopup.close()
                        } else if (identifierLayoutView.currentIndex === 3) {
                            identifierLayoutView.currentIndex = 0
                        }

                        else {
                            identifierLayoutView.currentIndex--
                        }
                    }
                    Layout.preferredHeight: 64
                    Layout.preferredWidth: 64
                    Layout.alignment: Qt.AlignVCenter
                }
                Label {
                    text: identifierLayoutView.currentIndex === 0 ? "Maladie des plantes" : identifierLayoutView.currentIndex === 1 ? "Analyse de plante" :  "Resultat"
                    font.pixelSize: 21
                    font.bold: true
                    font.weight: Font.Medium
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }
                AppBarButton {
                    icon:  Icons.camera
                    visible: Qt.platform.os == 'ios' || Qt.platform.os == 'android' && identifierLayoutView.currentIndex === 1
                    onClicked: {
                        if (Qt.platform.os === 'ios') {
                            imgPicker.openCamera()
                        } else {
                            androidToolsLoader.item.openCamera()
                        }
                    }
                    Layout.preferredHeight: 64
                    Layout.preferredWidth: 64
                    Layout.alignment: Qt.AlignVCenter
                }
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
                                    image.source = "file://" + path + "?" + Math.random()
                                }
                            }
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
                if (currentIndex != 1) {
                    if (accessCam.active)
                    {
                        tabView.currentIndex = 0
                        tabBar.currentIndex = 0
                        accessCam.active = false
                    }
                }
            }
            Item {

                Column {
                    width: parent.width - 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 20
                    spacing: 20
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 112
                        height: 112
                        opacity: .4
                        source: Icons.palmTree
                    }

                    ColumnLayout {
                        width: parent.width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        NiceButton {
                            text: "Analyser une plantes"
                            Layout.preferredHeight: 60
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 340
                            icon.source: Icons.magnify
                            onClicked: {
                                identifierLayoutView.currentIndex++
                            }
                        }
                        NiceButton {
                            text: "Encyclopedie des maladies"
                            icon.source: Icons.tree
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredHeight: 60
                            Layout.fillWidth: true
                            Layout.maximumWidth: 340
                            onClicked: identifierLayoutView.currentIndex = 3
                        }
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2
                    TabBar {
                        id: tabBar
                        topPadding: 0
                        visible:  Qt.platform.os !== 'ios' && Qt.platform.os !== 'android'
                        Material.background: "#00c395"
                        Material.foreground: Material.color(Material.Grey, Material.Shade50)
                        Material.accent: Material.color(Material.Grey, Material.Shade50)
                        Layout.fillWidth: true
                        TabButton {
                            text: "Fichier"
                            onClicked: tabView.currentIndex = 0
                        }
                        TabButton {
                            text: "Camera"
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
                                    fillMode: Image.PreserveAspectFit
                                }
                                Column {
                                    visible: image.source.toString() === ""
                                    anchors.centerIn: parent
                                    spacing: 10
                                    IconSvg {
                                        width: 64
                                        height: 64
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        source: Icons.fileDocument
                                        opacity: .5
                                        color: 'black'
                                    }
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 140
                                        wrapMode: Label.Wrap
                                        font.pixelSize: 16
                                        horizontalAlignment: Label.AlignHCenter
                                        text: 'Clickez pour importer une image'
                                        opacity: .6
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (Qt.platform.os === 'ios') {
                                            imgPicker.openPicker()
                                        } else if (Qt.platform.os === 'android') {
                                            androidToolsLoader.item.openGallery()
                                        }
                                        else {
                                            fileDialog.open()
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
                                                onErrorOccurred: function(id, error, message) {
                                                    console.log(id, error, message)
                                                }
                                            }
                                            videoOutput: tabView.currentIndex === 1 ? videoOutput : null
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
                                if (Qt.application.os === "windows" || Qt.application.os === "osx"
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
                            text: "Nouveau"
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 120
                            visible: tabView.currentIndex === 1 && accessCam.item?.image_view.visible === true
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
                            visible: image.source.toString() !== "" || accessCam.active
                            onClicked: {
                                if (image.source.toString() !== "") {
                                    imgAnalysisSurface.loading = true
                                    let data = {
                                        "images": [imgTool.getBase64(
                                                image.source.toString().replace(
                                                    Qt.platform.os === "windows" ? "file:///" : "file://", ""))],
                                        "disease_details": ["cause", "treatment", "common_names", "classification", "description", "url" ],
                                        "modifiers": ["similar_images"],
                                        "language": "fr",
                                    }
                                    request("POST",
                                            "https://plant.id/api/v2/health_assessment",
                                            data).then(function (r) {
                                                let datas = JSON.parse(r)
//                                                console.log(r)
                                                planteDeseasePopup.analyseResults = datas
                                                imgAnalysisSurface.loading = false
                                                identifierLayoutView.currentIndex = 2
                                                console.log(datas.health_assessment.diseases[0]['similar_images'])
                                                if (datas.is_plant && planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability < 0.7 ) {
                                                    identifedPlantListView.model
                                                            = datas.health_assessment.diseases
                                                } else {
                                                    identifedPlantListView.model = []
                                                }
                                            }).catch(function (e) {
                                                imgAnalysisSurface.loading = false
                                                console.log(JSON.stringify(e))
                                            })
                                } else {
                                    let path = StandardPaths.writableLocation(StandardPaths.PicturesLocation).toString().replace(Qt.application.os === "windows" ? "file:///" : "file://", "")
                                    let ln = (Math.random() % 10 * 100000).toFixed(0)
                                    let filePath = path + "/" + ln + '.jpg'
                                    imgAnalysisSurface.savedImagePath = filePath
                                    accessCam.item.imgCapture.captureToFile(filePath)
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
                            font.pixelSize: 24
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: planteDeseasePopup.analyseResults?.is_plant  ?? false
                            text: qsTr(planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.7 ?
                                           "<font color='green'> Votre plante est en bonne santé</font>" :
                                           (planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.4) ? "Votre plante semble en bonne santé" : "<font color='red'>Votre plante est malade</font>" )
//                            text: "Plante en bonne sante ? <b><font color='%1'>%2</font></b>".arg(
//                                      planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "green" : "red").arg(
//                                      planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "Oui" : "Non")
                        }
                        Label {
                            font.pixelSize: 16
                            font.weight: Font.Light
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: desease.analyseResults?.is_plant && planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability < 0.4
                            text: "Quelques maladies détectées"
                        }
                        Label {
                            font.pixelSize: 28
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: {
                                if(desease !== undefined)
                                    return !desease.analyseResults?.is_plant
                                else return false
                            }

                            text: "Ceci n'est pas une plante"
                        }
                    }

                    delegate: ItemDelegate {
                        text: modelData["name"]
                        height: 60
                        width: identifedPlantListView.width
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            color: "teal"
                            radius: width / 2
                            width: 50
                            height: width
                            Label {
                                anchors.centerIn: parent
                                text: "%1%".arg(
                                          (modelData["probability"] * 100).toFixed(
                                              0))
                                color: "white"
                                font.weight: Font.Bold
                            }
                        }
                        onClicked: {
                            resultDeseaseDetailPopup.desease_data = modelData
                            resultDeseaseDetailPopup.open()
                        }
                    }
                }
            }
            Item {
                ListView {
                    id: lView
                    anchors.fill: parent
                    anchors.margins: 10
                    model: 10
                    clip: true
                    delegate: Rectangle {
                        height: 50
                        width: lView.width
                        color: index % 2 === 0 ? Qt.darker("gray", .55) : "white"
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 10
                            font.pixelSize: 14
                            text: "Maladie " + index
                        }
                    }
                }
            }
        }
    }
    function fetch(opts) {
        return new Promise(function (resolve, reject) {
            var xhr = new XMLHttpRequest()
            xhr.onload = function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status == 200 || xhr.status == 201) {
                        var res = xhr.responseText.toString()
                        resolve(res)
                    } else {
                        let r = {
                            "status": xhr.status,
                            "statusText": xhr.statusText,
                            "content": xhr.responseText
                        }
                        reject(r)
                    }
                } else {
                    let r = {
                        "status": xhr.status,
                        "statusText": xhr.statusText,
                        "content": xhr.responseText
                    }
                    reject(r)
                }
            }
            xhr.onerror = function () {
                let r = {
                    "status": xhr.status,
                    "statusText": 'NO CONNECTION, ' + xhr.statusText + xhr.responseText
                }
                reject(r)
            }

            xhr.open(opts.method ? opts.method : 'GET', opts.url, true)

            if (opts.headers) {
                Object.keys(opts.headers).forEach(function (key) {
                    xhr.setRequestHeader(key, opts.headers[key])
                })
            }

            let obj = opts.params

            var data = obj ? JSON.stringify(obj) : ''

            xhr.send(data)
        })
    }

    function request(method, url, params) {
        let query = {
            "method": method,
            "url": url,
            "headers": {
                "Accept": 'application/json',
                "Api-Key": "aryQrOSbo6YrsMQGRx5VRpc1dOazmjDxO23jeitWxX43V7b3Xq",
                "Content-Type": 'application/json'
            },
            "params": params ?? null
        }
        return fetch(query)
    }
}
