import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import MaterialIcons
import "components"

Popup {
    id: identifierPop
    dim: true
    modal: true
    property variant plant_results
    width: appWindow.width
    height: appWindow.height
    parent: appWindow.contentItem
    padding: 0
    onClosed:  {
        tabBar.currentIndex = 0
    }

    PlantIdentifierDetails {
        id: resultIdentifierDetailPopup
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        Rectangle {
            color: "#00c395"
            Layout.preferredHeight: 65
            Layout.fillWidth: true
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Rectangle {
                    id: buttonBackBg
                    anchors.verticalCenter: parent.verticalCenter
                    width: 65
                    height: 65
                    radius: height
                    color: "transparent" //Theme.colorHeaderHighlight
                    opacity: 1
                    IconSvg {
                        id: buttonBack
                        width: 24
                        height: width
                        anchors.centerIn: parent

                        source: "qrc:/assets/menus/menu_back.svg"
                        color: Theme.colorHeaderContent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (identifierLayoutView.currentIndex === 0) {
                                identifierPop.close()
                            } else if (identifierLayoutView.currentIndex === 1) {
                                tabBar.currentIndex = 0
                                identifierLayoutView.currentIndex = 0
                            }
                            else {
                                identifierLayoutView.currentIndex--
                            }
                        }
                    }

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 333
                        }
                    }
                }
                Label {
                    text: identifierLayoutView.currentIndex === 0 ? "Identification de plante" : "Resultat"
                    font.pixelSize: 21
                    font.bold: true
                    font.weight: Font.Medium
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
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
                {
                    accessCam.active = false
                }
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
                        Material.foreground: Material.color(Material.Grey, Material.Shade50)
                        Material.accent: Material.color(Material.Grey, Material.Shade50)
                        Layout.fillWidth: true
                        TabButton {
                            text: "Fichier"
                        }
                        TabButton {
                            text: "Camera"
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
                                if (currentIndex === 0) {
                                    accessCam.active = false
                                } else {
                                    tm.start()
                                }
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
                                    onClicked: fileDialog.open()
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
                                                if (tabBar.currentIndex === 0) {
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
                                            videoOutput: tabBar.currentIndex === 1 ? videoOutput : null
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
                        Layout.leftMargin: 10

                        Item {
                            Layout.fillWidth: true
                        }

                        NiceButton {
                            id: control
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 120
                            Layout.alignment: Qt.AlignHCenter
                            visible: tabBar.currentIndex === 0
                            icon.source: Icons.imageArea
                            text: "Ouvrir"
                            onClicked: fileDialog.open()
                        }

                        NiceButton {
                            text: "Nouveau"
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 120
                            visible: tabBar.currentIndex === 1 && accessCam.item?.image_view.visible === true
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
                            Layout.preferredWidth: 180
                            Layout.preferredHeight: 60
                            visible: image.source.toString() !== "" || accessCam.active
                            onClicked: {
                                if (image.source.toString() !== "") {
                                    imgAnalysisSurface.loading = true
                                    let data = {
                                        "images": [imgTool.getBase64(
                                                image.source.toString().replace(
                                                    Qt.platform.os === "windows" ? "file:///" : "file://", ""))],
                                        "modifiers": ["crops_fast", "similar_images"],
                                        "plant_details": ["common_names", "taxonomy", "url", "wiki_description", "wiki_image", "wiki_images", "edible_parts", "propagation_methods"]
                                    }
                                    request("POST", "https://plant.id/api/v2/identify",
                                                         data).then(function (r) {
                                                             let datas = JSON.parse(r)
//                                                             console.log(r)
                                                             identifierPop.plant_results = datas
                                                             imgAnalysisSurface.loading = false
                                                             identifierLayoutView.currentIndex = 1
                                                             if (datas.is_plant)
                                                                 identifedPlantListView.model = datas.suggestions
                                                             else
                                                                 identifedPlantListView.model = []
                                                         }).catch(function (e) {
                                                             imgAnalysisSurface.loading = false
                                                             console.log('Erreur', JSON.stringify(e))
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
                            visible: identifierPop.plant_results?.is_plant ?? false
                            text: "Un de ces résultats devrait correspondre à vos recherches"
                        }
                        Label {
                            font.pixelSize: 28
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: !identifierPop.plant_results?.is_plant
                            text: "Ceci n'est pas une plante"
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


                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            color: "teal"
                            radius: 20
                            width: 80
                            height: width
                            clip: true
                            Image {
                                source: modelData["plant_details"]["wiki_image"]["value"]
                                height: parent.height
                                width: parent.width
                            }
                        }

                        onClicked: {
//                                identifierPop.close()
                            resultIdentifierDetailPopup.plant_data = modelData
                                resultIdentifierDetailPopup.open()
//                            plantDatabase.filter(modelData["plant_details"]["scientific_name"])
//                            let ps = plantDatabase.plantsFiltered.filter(function (p) {
//                                if (p.name.indexOf(modelData["plant_details"]["scientific_name"]) !== -1)
//                                    return p
//                            })
//                            if (ps.length > 0) {
//                                plantScreen.currentPlant = ps[0]
//                                identifierPop.close()

//                                itemPlantBrowser.visible = false
//                                itemPlantBrowser.enabled = false
//                                itemPlantViewer.visible = true
//                                itemPlantViewer.enabled = true
//                                itemPlantViewer.contentX = 0
//                                itemPlantViewer.contentY = 0
//                            }
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
