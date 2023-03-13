import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtSensors
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Loader {
    id: plantBrowser

    property string entryPoint: "DeviceList"

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // Load the data
        plantDatabase.load()
        plantDatabase.filter("")

        if (status === Loader.Ready) {
            // Reset state
            item.resetPlantClicked()
            item.focusSearchBox()
        } else {
            // Load the plant browser
            active = true
        }

        // Change screen
        appContent.state = "PlantBrowser"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        loadScreen()
    }

    function backAction() {
        if (status === Loader.Ready) {
            item.backAction()
        }
    }

    function forwardAction() {
        if (status === Loader.Ready) {
            item.forwardAction()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        function backAction() {
            if (isPlantClicked()) {
                itemPlantBrowser.visible = true
                itemPlantBrowser.enabled = true
                itemPlantViewer.visible = false
                itemPlantViewer.enabled = false
                return
            }

            if (plantSearchBox.focus) {
                plantSearchBox.focus = false
                return
            }

            appContent.state = entryPoint
        }

        function forwardAction() {
            if (appContent.state === "PlantBrowser") {
                if (typeof plantScreen.currentPlant !== "undefined" && plantScreen.currentPlant) {
                    plantSearchBox.focus = false
                    itemPlantBrowser.visible = false
                    itemPlantBrowser.enabled = false
                    itemPlantViewer.visible = true
                    itemPlantViewer.enabled = true
                }
            } else {
                appContent.state = "PlantBrowser"
                focusSearchBox()
            }
        }

        function isPlantClicked() {
            if (itemPlantViewer.visible) return true
            return false
        }

        function resetPlantClicked() {
            plantScreen.currentPlant = null
            plantSearchBox.text = ""
            plantSearchBox.focus = false
            itemPlantBrowser.visible = true
            itemPlantBrowser.enabled = true
            itemPlantViewer.visible = false
            itemPlantViewer.enabled = false
            itemPlantViewer.contentY = 0
        }

        function focusSearchBox() {
            // Search focus is set on desktop
            if (isDesktop) {
                plantSearchBox.focus = true
            }
        }

        Component.onCompleted: {
            focusSearchBox()
        }

        ////////////////

        Item {
            id: itemPlantBrowser
            anchors.fill: parent

            Rectangle {
                anchors.fill: plantSearchBox
                anchors.margins: -12
                z: 4
                color: Theme.colorBackground
            }

            TextFieldThemed {
                id: plantSearchBox
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12

                z: 5
                height: 40
                placeholderText: qsTr("Search for plants")
                selectByMouse: true
                colorSelectedText: "white"

                //onDisplayTextChanged: plantDatabase.filter(displayText)

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("%1 plants").arg(((plantSearchBox.displayText) ? plantDatabase.plantCountFiltered : plantDatabase.plantCount))
                        font.pixelSize: Theme.fontSizeContentSmall
                        color: Theme.colorSubText
                    }

                    RoundButtonIcon {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        visible: plantSearchBox.text.length
                        highlightMode: "color"
                        source: "qrc:/assets/icons_material/baseline-backspace-24px.svg"

                        onClicked: plantSearchBox.text = ""
                    }

                    IconSvg {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                        color: Theme.colorText
                    }
                }
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: 64
                anchors.leftMargin: 0
                anchors.rightMargin: 0

                ListModel {
                    id: plantOptionModel

                    Component.onCompleted: {
                        let data = [
                            {

                                "name": qsTr("Plantes recommandees"),
                                "icon": "qrc:/assets/icons_custom/thumbs.png",
                                "image": "",
                                "action": "",
                                "style": "darkblue"
                            },
                            {

                                "name": qsTr("Identifier la plante"),
                                "icon": "qrc:/assets/icons_custom/plant_scan.png",
                                "image": "",
                                "action": "identify",
                                "style": "lightenYellow"
                            },
                            {

                                "name": qsTr("Posemetre"),
                                "icon": "qrc:/assets/icons_custom/posometre.svg",
                                "image": "",
                                "action": "posometre",
                                "style": "sunrise"
                            },
                            {

                                "name": qsTr("Plante fleuries"),
                                "icon": "",
                                "image": "qrc:/assets/img/fleure.jpg",
                                "action": "",
                                "style": ""
                            },
                            {

                                "name": qsTr("Orchidees"),
                                "icon": "",
                                "image": "qrc:/assets/img/orchidee.jpg",
                                "action": "",
                                "style": ""
                            },
                            {

                                "name": qsTr("Cactus et succulentes"),
                                "icon": "",
                                "image": "qrc:/assets/img/cactus.jpg",
                                "action": "",
                                "style": ""
                            },
                            {

                                "name": qsTr("Legumes"),
                                "icon": "",
                                "image": "qrc:/assets/img/legume.jpg",
                                "action": "",
                                "style": ""
                            },
                            {

                                "name": qsTr("Herbes"),
                                "icon": "",
                                "image": "qrc:/assets/img/herbe.jpeg",
                                "action": "",
                                "style": ""
                            },
                            {

                                "name": qsTr("Plantes a feuillage"),
                                "icon": "",
                                "image": "qrc:/assets/img/feuillage.jpg",
                                "action": "",
                                "style": ""
                            }
                        ]
                        data.forEach(((plant) => append(plant)))
                    }
                }

                SortFilterProxyModel {
                    id: plantFilter
                    sourceModel: independant
                    delayed: true
                    filters: [
                        RegExpFilter {
                            roleName: "name"
                            pattern: plantSearchBox.displayText
                        }
                    ]
                }

                ListModel {
                    id: independant
                }

                Component.onCompleted: {
                    plantDatabase.filter('');
                    plantDatabase.plants.forEach((i) => independant.append(i))
                    console.log(plantFilter.count)
                }

                Flickable {
                    anchors.fill: parent
                    contentHeight: _insideColumn.height
                    clip: true
                    Column {
                        id: _insideColumn
                        width: parent.width
                        Item {
                            width: parent.width
                            height: (3 * ((parent.width - (20)) / 3)) + 30
                            GridView {
                                id: gr
                                interactive: false
                                anchors.fill: parent
                                anchors.margins: 10
                                anchors.rightMargin: 0
                                anchors.leftMargin: 0
                                cellWidth: (parent.width - (10)) / 3
                                cellHeight: cellWidth
                                model: plantOptionModel
                                delegate: Item {
                                    width: (gr.width - (20)) / 3
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
                                                position: 0.04;
                                                color: {
                                                    switch(style) {
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
                                                position: 1.00;
                                                color: {
                                                    switch(style) {
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
                                                if (action === "posometre") {
                                                    posometrePop.open()
                                                }
                                                else if (action === "identify") {
                                                    identifierPop.open()
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

                        ListView {
                            id: plantList
                            topMargin: 0
                            bottomMargin: 12
                            spacing: 0
                            interactive: false
                            width: parent.width
                            height: count * 40

                            model: plantFilter
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 40

                                color: (index % 2) ? Theme.colorForeground :Theme.colorBackground

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 16

                                    Text {
                                        text: model.name
                                        color: Theme.colorText
                                        fontSizeMode: Text.Fit
                                        font.pixelSize: Theme.fontSizeContent
                                        minimumPixelSize: Theme.fontSizeContentSmall
                                    }
                                    Text {
                                        visible: model.nameCommon
                                        text: "« " + model.nameCommon + " »"
                                        color: Theme.colorSubText
                                        fontSizeMode: Text.Fit
                                        font.pixelSize: Theme.fontSizeContent
                                        minimumPixelSize: Theme.fontSizeContentSmall
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        plantScreen.currentPlant = model
                                        plantSearchBox.focus = false

                                        itemPlantBrowser.visible = false
                                        itemPlantBrowser.enabled = false
                                        itemPlantViewer.visible = true
                                        itemPlantViewer.enabled = true
                                        itemPlantViewer.contentX = 0
                                        itemPlantViewer.contentY = 0
                                    }
                                }
                            }

                            ItemNoPlants {
                                visible: (plantList.count <= 0)
                            }
                        }
                    }
                }
            }
        }

        Popup {
            id: posometrePop
            width: parent.width - 20
            height: width
            anchors.centerIn: parent
            dim: true
            modal: true
            onOpened: als.start()
            onClosed: als.stop()
            Column {
                anchors.centerIn: parent
                spacing: 20
                IconSvg {
                    width: 64
                    height: 64
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/icons_custom/posometre.svg"
                    color: 'black'
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Posometre"
                    font.weight: Font.Medium
                }
                Label {
                    id: alsV
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        switch (als.reading.lightLevel){
                        case 0:
                            return "Niveau inconnue"
                        case 1:
                            return "Sombre"
                        case 2:
                            return "Peu Sombre"
                        case 3:
                            return "Lumineux"
                        case 4:
                            return "Tres lumineux"
                        case 5:
                            return "Ensolleille"
                        }
                    }

                    font.pixelSize: 44
                }
                AmbientLightSensor {
                    id: als
                }
            }
        }

        Popup {
            id: identifierPop
            dim: true
            modal: true
            property variant plant_results
            width: appWindow.width
            height: appWindow.height
            parent: appWindow.contentItem
            padding: 0
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
                                        identifierPop.close()
                                    } else {
                                        identifierLayoutView.currentIndex--
                                    }
                                }
                            }

                            Behavior on opacity { OpacityAnimator { duration: 333 } }
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
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 10
                    currentIndex: 0
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10
                            Item {
                                id: imgAnalysisSurface
                                property string savedImagePath: ""
                                property bool loading: false
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                anchors.horizontalCenter: parent.horizontalCenter
                                Rectangle {
                                    anchors.fill: parent
                                    border.width: 1
                                    border.color: '#ccc'
                                    opacity: .2
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
                                     fillMode: Image.PreserveAspectFit
                                 }

                                CaptureSession {
                                    camera: Camera {
                                        id: camera
                                        Component.onCompleted: start()
                                    }
                                    imageCapture: ImageCapture {
                                         id: imageCapture
                                         onImageSaved: function (id, path) {
                                             console.log(path)
                                             image.source = "file://" + path
                                             analyserButton.clicked()
                                         }
                                         onImageCaptured: function (id, path) {
        //                                    //image.source = path
                                             //console.log(StandardPaths.writableLocation(StandardPaths.PicturesLocation))
                                         }
                                     }
                                    videoOutput: videoOutput
                                }

                                VideoOutput {
                                    id: videoOutput
                                    anchors.fill: parent
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
                                    let data = {
                                        "images": [
                                            imgTool.getBase64(image.source.toString().replace(Qt.platform.os === "windows" ? "file:///" : "file://", ""))
                                        ]
                                    }
                                    plantBrowser.request("POST", "https://plant.id/api/v2/identify", data).then(function (r) {
                                        let datas = JSON.parse(r)
                                        console.log(r)
                                        identifierPop.plant_results = datas
                                        imgAnalysisSurface.loading = false
                                        identifierLayoutView.currentIndex = 1
                                        if (datas.is_plant)
                                            identifedPlantListView.model = datas.suggestions
                                        else
                                            identifedPlantListView.model = []

                                    }).catch(function (e) {
                                        imgAnalysisSurface.loading = false
                                        console.log(JSON.stringify(e))
                                    })
                                }
                            }
                            Image2Base64 {
                                id: imgTool
                            }

                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 10
                                ButtonWireframe {
                                    text: "Camera"
                                    width: 120
                                    height: 45
                                    onClicked: {
                                        console.log(StandardPaths.writableLocation(StandardPaths.PicturesLocation))
                                        let path = StandardPaths.writableLocation(StandardPaths.PicturesLocation).toString().replace(Qt.application.os === "windows" ? "file:///" : "file://", "")
                                        let ln = (Math.random() % 10 * 100000).toFixed(0)
                                        let filePath = path + "/" + ln + '.jpg'
                                        imgAnalysisSurface.savedImagePath = filePath
                                        imageCapture.captureToFile(filePath)
                                    }
                                    //onClicked: fileDialog.open()
                                }
                                ButtonWireframe {
                                    text: "Ouvrir"
                                    width: 120
                                    height: 45
                                    onClicked: fileDialog.open()
                                }
                                ButtonWireframe {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Fermer"
                                    width: 120
                                    height: 45
                                    onClicked: identifierPop.close()
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
                                    visible: identifierPop.plant_results?.is_plant
                                    text: "Plante a <b><font color='green'>%2%</font></b>".arg((identifierPop.plant_results?.is_plant_probability * 100).toFixed(0))
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
                                text: modelData["plant_name"]
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
                                        text: "%1%".arg((modelData["probability"]*100).toFixed(0))
                                        color: "white"
                                        font.weight: Font.Bold
                                    }
                                }
                                onClicked:  {
                                    plantDatabase.filter(modelData["plant_details"]["scientific_name"])
                                    let ps = plantDatabase.plantsFiltered.filter(function (p){
                                        if (p.name.indexOf(modelData["plant_details"]["scientific_name"]) !== -1)
                                            return p
                                    })
                                    if (ps.length > 0)
                                    {
                                        plantScreen.currentPlant = ps[0]
                                        identifierPop.close()

                                        itemPlantBrowser.visible = false
                                        itemPlantBrowser.enabled = false
                                        itemPlantViewer.visible = true
                                        itemPlantViewer.enabled = true
                                        itemPlantViewer.contentX = 0
                                        itemPlantViewer.contentY = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////

        Flickable {
            id: itemPlantViewer
            anchors.fill: parent
            anchors.topMargin: plantSelector_desktop.visible ? plantSelector_desktop.height : 0
            anchors.bottomMargin: plantSelector_mobile.visible ? plantSelector_mobile.height : 0

            visible: false

            // 1: single column (single column view or portrait tablet)
            // 2: wide mode (wide view)
            property int uiMode: (singleColumn || (isTablet && screenOrientation === Qt.PortraitOrientation)) ? 1 : 2

            contentWidth: (uiMode === 1) ? -1 : plantScreen.width
            contentHeight: (uiMode === 1) ? plantScreen.height : -1

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            function setPlant() {
                plantScreen.currentPlant = currentDevice.plant

                if (typeof itemPlantViewer !== "undefined" || itemPlantViewer) {
                    itemPlantViewer.contentX = 0
                    itemPlantViewer.contentY = 0
                }
            }

            PlantScreen {
                id: plantScreen
            }
        }

        ////////////////////////////////////////////////////////////////////

        Rectangle {
            id: plantSelector_desktop
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            z: 5
            height: 52
            color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

            visible: (!singleColumn &&
                      appContent.state === "PlantBrowser" &&
                      screenPlantBrowser.entryPoint === "DevicePlantSensor" &&
                      isPlantClicked())

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: "You are previewing a plant."
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: 22
            }

            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                ButtonWireframeIcon {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorPrimary
                    Layout.fillWidth: true
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 320

                    text: qsTr("Choose this plant")
                    source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"

                    onClicked: {
                         selectedDevice.setPlantName(plantScreen.currentPlant.name)
                         appContent.state = "DevicePlantSensor"
                    }
                }
                ButtonWireframe {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorSubText
                    Layout.fillWidth: false

                    text: qsTr("Cancel")

                    onClicked: {
                        appContent.state = "DevicePlantSensor"
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: (isDesktop && !headerUnicolor)
                height: 2
                opacity: 0.5
                color: Theme.colorSeparator
            }
        }

        ////////

        Rectangle {
            id: plantSelector_mobile
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            z: 5
            height: 52
            color: Theme.colorForeground
            visible: (singleColumn &&
                      appContent.state === "PlantBrowser" &&
                      screenPlantBrowser.entryPoint === "DevicePlantSensor" &&
                      isPlantClicked())

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ButtonWireframeIcon {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorPrimary
                    Layout.fillWidth: true
                    Layout.minimumWidth: 128
                    Layout.maximumWidth: 999

                    text: qsTr("Choose this plant")
                    source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"

                    onClicked: {
                         selectedDevice.setPlantName(plantScreen.currentPlant.name)
                         appContent.state = "DevicePlantSensor"
                    }
                }
                ButtonWireframe {
                    height: 36

                    fullColor: true
                    primaryColor: Theme.colorSubText
                    Layout.fillWidth: false

                    text: qsTr("Cancel")

                    onClicked: {
                        appContent.state = "DevicePlantSensor"
                    }
                }
            }
        }


        ////////////////////////////////////////////////////////////////////
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
            xhr.onerror = function() {
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

