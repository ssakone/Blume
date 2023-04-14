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
import "components"
import "components_js/Http.js" as Http

Popup {
    id: planteDeseasePopup
    dim: true
    modal: true
    property variant analyseResults
    width: appWindow.width
    height: appWindow.height
    parent: appWindow.contentItem
    padding: 0

    property variant form_schema: [{
            "group_title": "Exposition et température",
            "fields": [{
                    "label": "De combien d'ensoleillement bénéficie votre plante chaque jour ?",
                    "is_required": true,
                    "placeholder": "6h de lumière naturelle indirecte"
                }, {
                    "label": "Quelles sont les température de son environnement ?",
                    "is_required": false,
                    "placeholder": "Journée: +24°C, Nuit: +1°C"
                }]
        }, {
            "group_title": "Parasites et maladies",
            "fields": [{
                    "label": "Y a-t-il des toiles ou des insectes sur la plante ou dans la terre ?",
                    "is_required": false,
                    "placeholder": "Insectes blancs sous les feuilles"
                }, {
                    "label": "Quelles sont les température de son environnement ?",
                    "is_required": false,
                    "placeholder": "Journée: +24°C, Nuit: +1°C"
                }]
        }, {
            "group_title": "Arrosage",
            "fields": [{
                    "label": "A quelle fréquence arrosez-vous votre plante ?",
                    "is_required": false,
                    "placeholder": "1 à 2 fois par semaine"
                }, {
                    "label": "Quelle quantité d'eau utilisez-vous ?",
                    "is_required": false,
                    "placeholder": "Un verre et demi"
                }, {
                    "label": "Laissez-vous la terre sécher entre les arrosages ?",
                    "is_required": false,
                    "placeholder": "Oui, les premiers centimètres"
                }, {
                    "label": "Le fond du pot est-il percé ?",
                    "is_required": false,
                    "placeholder": "Oui"
                }]
        }, {
            "group_title": "Rempotage et engrais",
            "fields": [{
                    "label": "A quelle fréquence arrosez-vous votre plante ?",
                    "is_required": false,
                    "placeholder": "1 à 2 fois par semaine"
                }, {
                    "label": "Quelle quantité d'eau utilisez-vous ?",
                    "is_required": false,
                    "placeholder": "Un verre et demi"
                }, {
                    "label": "Laissez-vous la terre sécher entre les arrosages ?",
                    "is_required": false,
                    "placeholder": "Oui, les premiers centimètres"
                }, {
                    "label": "Le fond du pot est-il percé ?",
                    "is_required": false,
                    "placeholder": "Oui"
                }]
        }]

    onClosed: {
        if (accessCam.active)
            accessCam.active = false
        tabView.currentIndex = 0
        tabBar.currentIndex = 0
        image.source = ""
    }

    onOpened: {
        image.source = ""
    }

    PlantDeseaseDetails {
        id: resultDeseaseDetailPopup
    }

    PositionSource {
        id: gps
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
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
                        } else if (identifierLayoutView.currentIndex === 4) {
                            identifierLayoutView.currentIndex = 0
                        } else {
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
                        case 4:
                            return "FAQ"
                        case 5:
                            return "Contacter un expert"
                        default:
                            return "Non trouvé"
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
                                    image.source = "file://?" + Math.random()
                                    image.source = "file://" + path
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
                                            if (action === "analyser") {
                                                identifierLayoutView.currentIndex++
                                            } else if (action === "encyclopedie") {
                                                identifierLayoutView.currentIndex = 3
                                            } else if (action === "faq") {
                                                identifierLayoutView.currentIndex = 4
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
                                            androidToolsLoader.item.openGallery(
                                                        )
                                        } else {
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
                                                     planteDeseasePopup.analyseResults = datas
                                                     imgAnalysisSurface.loading = false
                                                     identifierLayoutView.currentIndex = 2
                                                     console.log(datas.health_assessment.diseases[0]['similar_images'])
                                                     if (datas.is_plant
                                                             && planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability < 0.7) {
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
                            visible: planteDeseasePopup.analyseResults?.is_plant
                                     ?? false
                            text: qsTr(planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.7 ? "<font color='green'> Votre plante est en bonne santé</font>" : (planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability > 0.4) ? "Votre plante semble en bonne santé" : "<font color='red'>Votre plante est malade</font>")
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
                            visible: desease.analyseResults?.is_plant
                                     && planteDeseasePopup.analyseResults?.health_assessment.is_healthy_probability < 0.4
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
                                if (desease !== undefined)
                                    return !desease.analyseResults?.is_plant
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
                            resultDeseaseDetailPopup.desease_data = modelData
                            resultDeseaseDetailPopup.open()
                        }
                    }
                }
            }
            Item {
                id: itemListAllDeseases
                property variant fetched_deseases: []

                PlantDeseaseDetails {
                    id: deseaseDetailPopup
                    header_hidden: true
                    parent: parent
                }

                Component.onCompleted: {
                    Http.fetch({
                                   "method": 'GET',
                                   "url": "https://blume.mahoudev.com/items/Maladies?fields[]=*.*"
                               }).then(response => {
                                           let data = JSON.parse(response).data
                                           console.log(data)
                                           fetched_deseases = data
                                       })
                }

                ListModel {
                    id: maladiesModel

                    ListElement {
                        nom: "Oïdium"
                        sousDescription: "Champignon blanc sur les feuilles"
                        dangerosite: 0.5
                    }
                    ListElement {
                        nom: "Mildiou"
                        sousDescription: "Taches jaunes ou brunes sur les feuilles"
                        dangerosite: 0.6
                    }
                    ListElement {
                        nom: "Tavelure"
                        sousDescription: "Taches brunes sur les fruits et les feuilles"
                        dangerosite: 0.5
                    }
                    ListElement {
                        nom: "Rouille"
                        sousDescription: "Pustules orangées sur les feuilles"
                        dangerosite: 0.6
                    }
                    ListElement {
                        nom: "Pourriture grise"
                        sousDescription: "Moisissure grise sur les fruits"
                        dangerosite: 0.7
                    }
                    ListElement {
                        nom: "Anthracnose"
                        sousDescription: "Lésions noires sur les feuilles"
                        dangerosite: 0.4
                    }
                    ListElement {
                        nom: "Chancre"
                        sousDescription: "Lésions sur les branches et troncs"
                        dangerosite: 0.7
                    }
                    ListElement {
                        nom: "Fusariose"
                        sousDescription: "Pourriture des racines et du collet"
                        dangerosite: 0.8
                    }
                    ListElement {
                        nom: "Nécrose"
                        sousDescription: "Mort des tissus végétaux"
                        dangerosite: 0.6
                    }
                    ListElement {
                        nom: "Verticilliose"
                        sousDescription: "Flétrissement et décoloration des feuilles"
                        dangerosite: 0.7
                    }
                    ListElement {
                        nom: "Bactériose"
                        sousDescription: "Pourriture bactérienne des tissus"
                        dangerosite: 0.8
                    }
                    ListElement {
                        nom: "Virose"
                        sousDescription: "Infection virale des plantes"
                        dangerosite: 0.7
                    }
                    ListElement {
                        nom: "Jaunisse"
                        sousDescription: "Décoloration jaune des feuilles"
                        dangerosite: 0.5
                    }
                    ListElement {
                        nom: "Sclérotiniose"
                        sousDescription: "Pourriture des tiges et des racines"
                        dangerosite: 0.6
                    }
                    ListElement {
                        nom: "Phytophthora"
                        sousDescription: "Pourriture des racines"
                        dangerosite: 0.8
                    }
                    ListElement {
                        nom: "Rhizoctone"
                        sousDescription: "Pourriture des racines et du collet"
                        dangerosite: 0.7
                    }
                }

                ListView {
                    id: listView
                    anchors.fill: parent
                    anchors.margins: 10
                    model: itemListAllDeseases.fetched_deseases
                    clip: true
                    delegate: ItemDelegate {
                        required property variant modelData
                        required property int index

                        height: 70
                        width: listView.width
                        onClicked: {
                            let formated = {}
                            let desease_details = {
                                "common_names": modelData.noms_communs,
                                "treatment": {
                                    "prevention": modelData.traitement_preventif
                                                  || "",
                                    "chemical": modelData.traitement_chimique
                                                || "",
                                    "biological": modelData.traitement_biologique
                                                  || ""
                                },
                                "description": modelData.description,
                                "cause": modelData.cause
                            }

                            formated['name'] = modelData.nom_scientifique
                            formated['similar_images'] = modelData.images.map(
                                        item => ({
                                                     "url": "https://blume.mahoudev.com/assets/"
                                                            + item.directus_files_id
                                                 }))
                            formated['disease_details'] = desease_details

                            console.log(JSON.stringify(formated))
                            deseaseDetailPopup.desease_data = formated
                            deseaseDetailPopup.open()
                        }

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
                            text: modelData['nom_scientifique']
                        }

                        Label {
                            anchors.top: titleLabel.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pixelSize: 12
                            color: "gray"
                            text: modelData['noms_communs'] ? modelData['noms_communs'][0] : ""
                        }

                        ClipRRect {
                            id: dangerositeCercle
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            height: 50
                            width: 50
                            radius: 25
                            Image {
                                source: modelData['images'].length
                                        === 0 ? null : ("https://blume.mahoudev.com/assets/"
                                                        + modelData['images'][0].directus_files_id)
                            }
                        }
                    }
                }
            }

            Item {
                clip: true

                Flickable {
                    anchors.fill: parent
                    width: parent.width
                    height: parent.height
                    contentHeight: colHeadFaqSimple.height
                    ColumnLayout {
                        id: colHeadFaqSimple
                        anchors.fill: parent

                        spacing: 20

                        Label {
                            text: "Foire aux questions"
                            color: Theme.colorPrimary
                            font.pixelSize: 32
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Column {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            spacing: 1

                            Repeater {
                                model: 12
                                delegate: Accordion {
                                    header_color: "#eaeaeaea" // Theme.colorPrimary
                                    content_color_expanded: "white"
                                    header_radius: 0
                                    header: "Questions " + index

                                    contentItems: [
                                        Label {
                                            text: "Sed at orci accumsan, pretium lorem sed, varius erat. Nunc id urna vitae diam laoreet maximus in at sapien. Maecenas eu massa augue. Proin nisi risus, consectetur sit amet efficitur eget, pharetra in felis. Quisque pretium neque nulla, eu pretium est hendrerit nec. Cras quis scelerisque neque. Nunc dignissim sem nec est vehicula congue. Donec sapien metus, lacinia vel sapien vitae, consectetur dictum ipsum. Nulla sagittis ante eget sem vestibulum cursus. "
                                            wrapMode: Text.Wrap

                                            font.pixelSize: 14
                                            font.weight: Font.Light

                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 10
                                            Layout.rightMargin: 10
                                            Layout.bottomMargin: 20
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }

                ButtonWireframe {
                    text: "Contacter un expert"
                    componentRadius: 15
                    fullColor: Theme.colorPrimary
                    fulltextColor: "white"
                    onClicked: identifierLayoutView.currentIndex++
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20

                    anchors.right: parent.right
                    anchors.rightMargin: 20
                }
            }

            Item {
                Rectangle {
                    id: head
                    height: identifierLayoutView.height / 3
                    width: parent.width
                    color: Theme.colorPrimary

                    ColumnLayout {
                        anchors.fill: parent

                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Label {
                            text: "Demander à un botaniste"
                            color: "white"
                            font.pixelSize: 32
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Vous receverez un diagnostic et un plan de soin dans les trois jours après avoire rempli ce formulaire"
                            color: "white"
                            font.pixelSize: 16
                            font.weight: Font.Light
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                Flickable {
                    anchors.fill: parent
                    width: parent.width
                    height: parent.height

                    contentHeight: 2000

                    ColumnLayout {
                        id: colHeadFaqForm
                        anchors.fill: parent

                        Item {
                            Layout.preferredHeight: head.height - 60
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "white"
                            radius: 50

                            ColumnLayout {
                                anchors.fill: parent

                                anchors.topMargin: 30
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15

                                spacing: 30

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "Ajouter des images"
                                        font {
                                            pixelSize: 16
                                            weight: Font.Bold
                                        }

                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                    }

                                    Label {
                                        text: "Photographiez la plante entière ainsi que les parties qui semblent malades"
                                        font.weight: Font.Light
                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        Repeater {
                                            model: 4
                                            ImagePickerArea {
                                                Layout.preferredHeight: 70
                                                Layout.preferredWidth: 70
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "Décrivez le problème"
                                        font {
                                            pixelSize: 16
                                            weight: Font.Bold
                                        }

                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 120
                                        radius: 15
                                        border {
                                            width: 1
                                            color: "#ccc"
                                        }
                                        TextEdit {
                                            anchors.fill: parent
                                            padding: 7
                                            font {
                                                pixelSize: 14
                                                weight: Font.Light
                                            }
                                            wrapMode: Text.Wrap
                                            clip: true
                                        }
                                    }
                                }

                                Repeater {
                                    model: form_schema
                                    delegate: ColumnLayout {
                                        required property variant modelData

                                        Layout.fillWidth: true
                                        spacing: 15

                                        Row {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            IconSvg {
                                                source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                                                width: 30
                                                height: 30
                                                color: Theme.colorPrimary
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Label {
                                                text: modelData.group_title
                                                font {
                                                    pixelSize: 13
                                                    weight: Font.Bold
                                                    capitalization: Font.AllUppercase
                                                }
                                                color: Theme.colorPrimary
                                                anchors.verticalCenter: parent.verticalCenter
                                                Layout.fillWidth: true
                                                wrapMode: Text.Wrap
                                            }
                                        }

                                        Repeater {
                                            model: modelData.fields
                                            delegate: ColumnLayout {
                                                required property variant modelData
                                                Layout.fillWidth: true
                                                spacing: 7
                                                Label {
                                                    text: (modelData.is_required ? "* " : "")
                                                          + modelData.label
                                                    font {
                                                        pixelSize: 16
                                                        weight: Font.Bold
                                                    }
                                                    Layout.fillWidth: true
                                                    wrapMode: Text.Wrap
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 50
                                                    radius: 10
                                                    border {
                                                        width: 1
                                                        color: "#ccc"
                                                    }
                                                    TextInput {
                                                        id: textInput
                                                        anchors.fill: parent
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                        padding: 5

                                                        font {
                                                            pixelSize: 14
                                                            weight: Font.Light
                                                        }
                                                    }
                                                    Label {
                                                        text: modelData?.placeholder
                                                        color: "#aaa"
                                                        font {
                                                            pixelSize: 14
                                                            weight: Font.Light
                                                        }
                                                        visible: textInput.text === ""
                                                        anchors.fill: parent
                                                        anchors.leftMargin: 5
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                        wrapMode: Text.Wrap
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.preferredHeight: 70
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
