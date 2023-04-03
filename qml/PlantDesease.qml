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
                    text: {
                        switch (identifierLayoutView.currentIndex) {
                        case 0:
                            return "Maladie des plantes"
                        case 1:
                            return "Analyse de plante"
                        case 2:
                            return "Resultat de l'analyse"
                        case 3:
                            return "Encyclopedie des plantes"
                        }
                    }

                    font.pixelSize: 21
                    font.bold: true
                    font.weight: Font.Medium
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }
                AppBarButton {
                    icon:  Icons.camera
                    visible: (Qt.platform.os == 'ios' || Qt.platform.os == 'android') && identifierLayoutView.currentIndex === 1
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
                    Item {
                        width: parent.width
                        height: (3 * ((parent.width - (20)) / 3)) + 30
                        ListModel {
                            id: optionModel

                            Component.onCompleted: {
                                let data = [{
                                                "name": qsTr("Analyser une plantes"),
                                                "icon": Icons.magnifyScan,
                                                "image": "",
                                                "action": "analyser",
                                                "style": "darkblue"
                                            }, {
                                                "name": qsTr("Encyclopedie des maladies"),
                                                "icon": Icons.bookOpenOutline,
                                                "image": "",
                                                "action": "encyclopedie",
                                                "style": "lightenYellow"
                                            },]
                                data.forEach((plant => append(plant)))
                            }
                        }
                        GridView {
                            id: gr
                            y: 10
                            interactive: false
                            width: parent.width
                            height: parent.height - 20
                            cellWidth: (parent.width - (10)) / 2.5
                            cellHeight: cellWidth
                            model: optionModel
                            delegate: Item {
                                width: (gr.width - (20)) / 2.5
                                height: width
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.bottomMargin: 35
                                    anchors.rightMargin: 15
                                    anchors.leftMargin: 15
                                    radius: 10
                                    opacity: mArea.containsMouse ? .8 : 1
                                    gradient: Gradient {
                                        orientation: Qt.Horizontal
                                        GradientStop {
                                            position: 0.04
                                            color: {
                                                switch (style) {
                                                case "darkblue":
                                                    return "#2c718a"
                                                case "lightenYellow":
                                                    return "#93d1be"
                                                case "sunrise":
                                                    return "#ffc6a4"
                                                default:
                                                    return "#ccc"
                                                }
                                            }
                                        }
                                        GradientStop {
                                            position: 1.00
                                            color: {
                                                switch (style) {
                                                case "darkblue":
                                                    return "#143e44"
                                                case "lightenYellow":
                                                    return "#0ca780"
                                                case "sunrise":
                                                    return "#fc9185"
                                                default:
                                                    return "#ccc"
                                                }
                                            }
                                        }
                                    }
                                    IconSvg {
                                        width: 64
                                        height: 64
                                        visible: icon !== ""
                                        anchors.centerIn: parent

                                        source: icon
                                        color: 'white'
                                    }
                                    Image {
                                        id: img
                                        visible: image.toString() !== ""
                                        source: image
                                        anchors.fill: parent
                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: Item {
                                                width: img.width
                                                height: img.height
                                                Rectangle {
                                                    anchors.centerIn: parent
                                                    width: img.adapt ? img.width : Math.min(img.width, img.height)
                                                    height: img.adapt ? img.height : width
                                                    radius: 10
                                                }
                                            }
                                        }
                                    }
                                    MouseArea {
                                        id: mArea
                                        anchors.fill: parent
                                        enabled: action !== ""
                                        hoverEnabled: enabled
                                        onClicked: {
                                            if (action === "analyser") {
                                                identifierLayoutView.currentIndex++
                                            } else if (action === "encyclopedie") {
                                                identifierLayoutView.currentIndex = 3
                                            }
                                        }
                                    }
                                }
                                Label {
                                    width: parent.width - 10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 3
                                    height: 28
                                    wrapMode: Label.Wrap
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    horizontalAlignment: Label.AlignHCenter
                                    verticalAlignment: Label.AlignVCenter
                                    text: name
                                }
                            }
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
                                                    Qt.platform.os === "windows" ? "file:///" : "file://", ""))]
                                    }
                                    request("POST",
                                            "https://plant.id/api/v2/health_assessment",
                                            data).then(function (r) {
                                                let datas = JSON.parse(r)
                                                console.log(r)
                                                planteDeseasePopup.analyseResults = datas
                                                imgAnalysisSurface.loading = false
                                                identifierLayoutView.currentIndex = 2
                                                if (datas.is_plant) {
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
                            font.pixelSize: 28
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: planteDeseasePopup.analyseResults?.is_plant  ?? false
                            text: "Plante en bonne sante <b><font color='%1'>%2</font></b>".arg(
                                      planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "green" : "red").arg(
                                      planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "Oui" : "Non")
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
                    }
                }
            }
            Item {
                ListModel {
                    id: maladiesModel

                    ListElement { nom: "Oïdium"; sousDescription: "Champignon blanc sur les feuilles"; dangerosite: 0.5 }
                    ListElement { nom: "Mildiou"; sousDescription: "Taches jaunes ou brunes sur les feuilles"; dangerosite: 0.6 }
                    ListElement { nom: "Tavelure"; sousDescription: "Taches brunes sur les fruits et les feuilles"; dangerosite: 0.5 }
                    ListElement { nom: "Rouille"; sousDescription: "Pustules orangées sur les feuilles"; dangerosite: 0.6 }
                    ListElement { nom: "Pourriture grise"; sousDescription: "Moisissure grise sur les fruits"; dangerosite: 0.7 }
                    ListElement { nom: "Anthracnose"; sousDescription: "Lésions noires sur les feuilles"; dangerosite: 0.4 }
                    ListElement { nom: "Chancre"; sousDescription: "Lésions sur les branches et troncs"; dangerosite: 0.7 }
                    ListElement { nom: "Fusariose"; sousDescription: "Pourriture des racines et du collet"; dangerosite: 0.8 }
                    ListElement { nom: "Nécrose"; sousDescription: "Mort des tissus végétaux"; dangerosite: 0.6 }
                    ListElement { nom: "Verticilliose"; sousDescription: "Flétrissement et décoloration des feuilles"; dangerosite: 0.7 }
                    ListElement { nom: "Bactériose"; sousDescription: "Pourriture bactérienne des tissus"; dangerosite: 0.8 }
                    ListElement { nom: "Virose"; sousDescription: "Infection virale des plantes"; dangerosite: 0.7 }
                    ListElement { nom: "Jaunisse"; sousDescription: "Décoloration jaune des feuilles"; dangerosite: 0.5 }
                    ListElement { nom: "Sclérotiniose"; sousDescription: "Pourriture des tiges et des racines"; dangerosite: 0.6 }
                    ListElement { nom: "Phytophthora"; sousDescription: "Pourriture des racines"; dangerosite: 0.8 }
                    ListElement { nom: "Rhizoctone"; sousDescription: "Pourriture des racines et du collet"; dangerosite: 0.7 }
                }

                ListView {
                    id: listView
                    anchors.fill: parent
                    anchors.margins: 10
                    model: maladiesModel
                    clip: true
                    delegate: Rectangle {
                        height: 70
                        width: listView.width
                        Rectangle {
                            anchors.bottom: parent.bottom
                            height: 1
                            color: "#ccc"
                            width: parent.width - 20
                            opacity: .4
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: index !== maladiesModel.count - 1
                        }

                        Label {
                            id: titleLabel
                            anchors.top: parent.top
                            anchors.topMargin: 15
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pixelSize: 21
                            font.weight: Font.Medium
                            text: nom
                        }

                        Label {
                            anchors.top: titleLabel.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pixelSize: 12
                            color: "gray"
                            text: sousDescription
                        }

                        Rectangle {
                            id: dangerositeCercle
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            height: 30
                            width: 30
                            radius: 15
                            color: listView.getColorForDangerosite(dangerosite)
                        }
                    }
                    function getColorForDangerosite(dangerosite) {
                        return Qt.rgba(1.0, 1.0 - dangerosite, 1.0 - dangerosite, 1.0)
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
