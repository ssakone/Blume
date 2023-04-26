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
import "../../"
import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    id: planteDeseaseControl
    property variant analyseResults
    padding: 0

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
        title: {
            switch (identifierLayoutView.currentIndex) {
            case 0:
                return "Maladie des plantes"
            case 1:
                return "Analyse de plante"
            case 2:
                return "Resultat de l'analyse"
            default:
                return "Non trouvé"
            }
        }
        noAutoPop: true
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
        actions: [
            AppBarButton {
                icon: Icons.camera
                visible: (Qt.platform.os == 'ios'
                          || Qt.platform.os == 'android')
                         && identifierLayoutView.currentIndex === 1
                onClicked: {
                    if (Qt.platform.os === 'ios') {
                        imgPicker.openCamera()
                    } else {
                        androidToolsLoader.item.openCamera()
                    }
                }
                height: 64
                width: 64
            }
        ]
    }

    Component {
        id: faqPage
        Faq {}
    }

    Component {
        id: askMore
        AskHelp {}
    }

    Component {
        id: insectIndentifier
        InsectIdentifier {}
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
                if (currentIndex !== 1) {
                    if (accessCam.active) {
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
                                                "name": qsTr("Détecter une maladie"),
                                                "icon": Icons.magnifyScan,
                                                "image": "",
                                                "action": "analyser",
                                                "style": "darkblue"
                                            }, {
                                                "name": qsTr("Identifier un insecte"),
                                                "icon": Icons.bug,
                                                "image": "",
                                                "action": "insect",
                                                "style": "lightBlue"
                                            }, {
                                                "name": qsTr("Encyclopedie des maladies"),
                                                "icon": Icons.bookOpenOutline,
                                                "image": "",
                                                "action": "encyclopedie",
                                                "style": "lightenYellow"
                                            }, {
                                                "name": qsTr("Contacter des experts"),
                                                "icon": Icons.helpCircle,
                                                "image": "",
                                                "action": "faq",
                                                "style": "lightenYellow"
                                            }]
                                data.forEach((plant => append(plant)))
                            }
                        }
                        GridView {
                            id: gr
                            y: 10
                            interactive: false
                            width: parent.width
                            height: parent.height - 20
                            cellWidth: gr.width > 800 ? gr.width / 5 : (gr.width > 500 ? gr.width/ 4 : gr.width /3)
                            cellHeight: cellWidth
                            model: optionModel
                            delegate: Item {
                                width: gr.cellWidth
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
                                                case "lightBlue":
                                                    return "lightblue"
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
                                                case "lightBlue":
                                                    return "lightblue"
                                                case "sunrise":
                                                    return "#fc9185"
                                                default:
                                                    return "#ccc"
                                                }
                                            }
                                        }
                                    }
                                    IconSvg {
                                        width: parent.width / 2
                                        height: width
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
                                                    width: img.adapt ? img.width : Math.min(
                                                                           img.width,
                                                                           img.height)
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
                                            switch (action) {
                                            case "analyser":
                                                identifierLayoutView.currentIndex++
                                                break
                                            case "encyclopedie":
                                                page_view.push(
                                                            plantDeseaseEncyclopedie)
                                                break
                                            case "faq":
                                                page_view.push(faqPage)
                                                break
                                            case "insect":
                                                page_view.push(
                                                            insectIndentifier)
                                                break
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
                        visible: Qt.platform.os !== 'ios'
                                 && Qt.platform.os !== 'android'
                        Material.background: "#00c395"
                        Material.foreground: Material.color(Material.Grey,
                                                            Material.Shade50)
                        Material.accent: Material.color(Material.Grey,
                                                        Material.Shade50)
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
                                ItemNoImage {
                                    visible: image.source.toString() === ""
                                    anchors.fill: parent
                                    spacing: 10
                                    padding: 25

                                    title: 'Identifier une maladie'
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
                            text: "Nouveau"
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
                                        "disease_details": ["cause", "treatment", "common_names", "classification", "description", "url"],
                                        "modifiers": ["similar_images"],
                                        "language": "fr",
                                        "longitude": gps.position.coordinate.longitude,
                                        "latitude": gps.position.coordinate.latitude
                                    }
                                    Http.request("POST",
                                                 "https://plant.id/api/v2/health_assessment",
                                                 data).then(function (r) {
                                                     let datas = JSON.parse(r)
                                                     //                                                console.log(r)
                                                     planteDeseaseControl.analyseResults = datas
                                                     imgAnalysisSurface.loading = false
                                                     identifierLayoutView.currentIndex = 2
                                                     console.log(datas.health_assessment.diseases[0]['similar_images'])
                                                     if (datas.is_plant
                                                             && planteDeseaseControl.analyseResults?.health_assessment.is_healthy_probability < 0.7) {
                                                         identifedPlantListView.model
                                                                 = datas.health_assessment.diseases
                                                     } else {
                                                         identifedPlantListView.model = []
                                                     }
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
                            visible: planteDeseaseControl.analyseResults?.is_plant
                                     ?? false
                            text: qsTr(planteDeseaseControl.analyseResults?.health_assessment.is_healthy_probability > 0.7 ? "<font color='green'> Votre plante est en bonne santé</font>" : (planteDeseaseControl.analyseResults?.health_assessment.is_healthy_probability > 0.4) ? "Votre plante semble en bonne santé" : "<font color='red'>Votre plante est malade</font>")
                            //                            text: "Plante en bonne sante ? <b><font color='%1'>%2</font></b>".arg(
                            //                                      planteDeseaseControl.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "green" : "red").arg(
                            //                                      planteDeseaseControl.analyseResults?.health_assessment.is_healthy_probability > 0.6 ? "Oui" : "Non")
                        }
                        Label {
                            font.pixelSize: 16
                            font.weight: Font.Light
                            width: 300
                            wrapMode: Label.Wrap
                            horizontalAlignment: Label.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Qt.AlignVCenter
                            visible: {
                                if (planteDeseaseControl.analyseResults?.is_plant !== undefined) {
                                    return planteDeseaseControl.analyseResults?.health_assessment.is_healthy_probability < 0.4
                                }
                                return false
                            }

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
                                if (planteDeseaseControl
                                        ?? undefined !== undefined)
                                    return !planteDeseaseControl.analyseResults?.is_plant
                                else
                                    return false
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
                            page_view.push(resultDeseaseDetailPage, {
                                               "desease_data": modelData
                                           })
                        }
                    }
                }
            }
        }
    }
}
