import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtSensors
import SortFilterProxyModel
import QtMultimedia
import ImageTools
import Qt.labs.platform

import ThemeEngine 1.0

Popup {
    id: desease
    property variant analyseResults
    width: appWindow.width
    height: appWindow.height
    parent: appWindow.contentItem
    padding: 0

    onClosed: camera.stop()
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
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
                                desease.close()
                            } else {
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
                    text: identifierLayoutView.currentIndex === 0 ? "Etat de la plante" : "Resultat"
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
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 10
            currentIndex: 0
            Item {
                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    spacing: 10

                    Item {
                        id: imgAnalysisSurface
                        property string savedImagePath: ""
                        property bool loading: false
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            anchors.fill: parent
                            border.width: 1
                            border.color: '#ccc'
                            opacity: .3
                        }
                        Column {
                            visible: image.source.toString() === ""
                            anchors.centerIn: parent
                            spacing: 10
                            IconSvg {
                                width: 64
                                height: 64
                                anchors.horizontalCenter: parent.horizontalCenter

                                source: "qrc:/assets/icons_custom/plant_scan.png"
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

                        Image {
                            id: image
                            anchors.fill: parent
                            smooth: false
                            antialiasing: false
                            fillMode: Image.PreserveAspectFit
                        }

                        Loader {
                            id: cameraLoader
                            anchors.fill: parent
                            active: desease.visible
                            sourceComponent: Item {
                                property alias imgCapture: imageCapture
                                anchors.fill: parent
                                Component.onCompleted: camera.start()
                                CaptureSession {
                                    camera: Camera {
                                        id: camera
                                    }
                                    imageCapture: ImageCapture {
                                        id: imageCapture
                                        onImageSaved: function (id, path) {
                                            console.log(path)
                                            image.source = "file://" + path
                                            analyserButton.clicked()
                                        }
                                    }
                                    videoOutput: videoOutput
                                }

                                VideoOutput {
                                    id: videoOutput
                                    anchors.fill: parent
                                }
                            }
                        }

                        BusyIndicator {
                            running: parent.loading
                            anchors.centerIn: parent
                        }

                        FileDialog {
                            id: fileDialog
                            nameFilters: ["Image file (*.png *.jpg *.jpeg *.gif)"]
                            onAccepted: image.source = selectedFile
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: fileDialog.open()
                        }
                    }

                    ButtonWireframe {
                        id: analyserButton
                        Layout.alignment: Qt.AlignHCenter
                        text: "Analyser"
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 45
                        visible: image.source.toString() !== ""
                        onClicked: {
                            imgAnalysisSurface.loading = true
                            console.log("Image URL ", image.source.toString())
                            let data = {
                                "images": [imgTool.getBase64(
                                        image.source.toString().replace(
                                            Qt.platform.os === "windows" ? "file:///" : "file://",
                                            ""))]
                            }
                            request("POST",
                                    "https://plant.id/api/v2/health_assessment",
                                    data).then(function (r) {
                                        let datas = JSON.parse(r)
                                        console.log(r)
                                        desease.analyseResults = datas
                                        imgAnalysisSurface.loading = false
                                        identifierLayoutView.currentIndex = 1
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
                        }
                    }
                    Image2Base64 {
                        id: imgTool
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        ButtonWireframe {
                            text: "Camera"
                            Layout.preferredHeight: 45
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: {
                                let path = StandardPaths.writableLocation(
                                        StandardPaths.PicturesLocation).toString(
                                        ).replace(
                                        Qt.application.os === "windows" ? "file:///" : "file://",
                                        "")
                                let ln = (Math.random(
                                              ) % 10 * 100000).toFixed(0)
                                let filePath = path + "/" + ln + '.jpg'
                                imgAnalysisSurface.savedImagePath = filePath
                                 cameraLoader.item.imgCapture.captureToFile(filePath)
                            }
                        }
                        ButtonWireframe {
                            text: "Charger une image"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: fileDialog.open()
                        }
                        ButtonWireframe {
                            text: "Fermer"
                            Layout.preferredHeight: 45
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: desease.close()
                        }
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
                            visible: desease.analyseResults?.is_plant  ?? false
                            text: "Plante en bonne sante <b><font color='%1'>%2</font></b>".arg(
                                      desease.analyseResults?.health_assessment.is_healthy_probability > 0.8 ? "green" : "red").arg(
                                      desease.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "Oui" : "Non")
                        }
                        Label {
                            font.pixelSize: 28
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: !desease.analyseResults?.is_plant
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
                    "statusText": 'NO CONNECTION, ' + xhr.statusText
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
