import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
//import PlantUtils 1.0
import "components"
import "components_generic"
import "components_themed"
import "popups"
import "components_js/Http.js" as Http

import SortFilterProxyModel
Popup {
    id: plantScreenDetailsPopup

    property string alertMsg: ""

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    padding: 0

    property var plant: null
    property var imagesURL: []

    Component.onCompleted: {
        console.log("\n\n imagesURL ", imagesURL)
    }

    property bool fullScreen: false
    property bool hideBaseHeader: false

    function generateUUID() {
        // Public Domain/MIT
        var d = new Date().getTime()
        //Timestamp
        var d2 = ((typeof performance !== 'undefined') && performance.now
                  && (performance.now() * 1000)) || 0
        //Time in microseconds since page-load or 0 if unsupported
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,
                                                              function (c) {
                                                                  var r = Math.random() * 16
                                                                  //random number between 0 and 16
                                                                  if (d > 0) {
                                                                      //Use timestamp until depleted
                                                                      r = (d + r) % 16 | 0
                                                                      d = Math.floor(d / 16)
                                                                  } else {
                                                                      //Use microseconds since page-load if supported
                                                                      r = (d2 + r) % 16 | 0
                                                                      d2 = Math.floor(d2 / 16)
                                                                  }
                                                                  return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16)
                                                              })
    }

    function addToGarden(onSuccess) {

        spaceSearchPop.show(function (space) {
            let data = {
                "libelle": plant?.name_scientific,
                "image_url": "-1",
                "remote_id": plant.id,
                "uuid": generateUUID()
            }
            data["plant_json"] = JSON.stringify(plant)

            $Model.plant.sqlCreate(data).then(function (new_plant) {
                let inData = {
                    "space_id": space.id,
                    "space_name": space.libelle,
                    "plant_json": new_plant["plant_json"],
                    "plant_id": new_plant.id
                }
                console.log("Continue...")
                $Model.space.plantInSpace.sqlCreate(inData).then(function () {
                    console.log("Created AGAIN...")
                    console.info("Done")
                    if (onSuccess)
                        onSuccess(new_plant, space)
                })
                plantScreenDetailsPopup.alertMsg = qsTr("Plant added to garden")
            }).catch(console.warn)
        })
    }

    function selectGardenSpace(onSuccess) {

        spaceSearchPop.show(function (space) {
            let data = {
                "libelle": plant?.name_scientific,
                "image_url": "-1",
                "remote_id": plant.id,
                "uuid": generateUUID()
            }
            data["plant_json"] = JSON.stringify(plant)

            if (onSuccess)
                onSuccess(plantScreenDetailsPopup.plant, space)
        }, currentPlantSpaces)
    }

    ListModel {
        id: currentPlantSpaces
    }

    onPlantChanged: {
        if (plantScreenDetailsPopup.plant.id) {
            $Model.space.listSpacesOfPlantRemoteID(
                        plantScreenDetailsPopup.plant.id).then(function (res) {
                            currentPlantSpaces.clear()
                            for (var i = 0; i < res?.length; i++) {
                                currentPlantSpaces.append(res[i])
                            }
                        })
        }
    }
    onFullScreenChanged: {
        if (fullScreen)
            fullScreenPop.close()
        else
            fullScreenPop.open()
    }

    ListModel {
        id: modelImagesPlantes
    }

    SpaceSearchPopup {
        id: spaceSearchPop
        width: parent.width
        height: Qt.platform.os === "ios" ? parent.height - 45 : parent.height - 20
    }

    FullScreenPopup {
        id: fullScreenPop
        onSwithMode: fullScreen = !fullScreen
        source: {
            if (plant['images_plantes']?.count !== undefined) {
                console.log("First agent")
                return plant['images_plantes']?.count
                        ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/"
                                    + plant['images_plantes']?.get(
                                        0).directus_files_id) : ""
            } else if (plant['images_plantes']?.length !== undefined) {
                console.log("Second agent")
                return plant['images_plantes']?.length
                        ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/"
                                    + plant['images_plantes'][0].directus_files_id) : ""
            }
            return ""
        }
    }

    Loader {
        anchors.fill: parent
        active: Boolean(plant)
        sourceComponent: ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    id: header
                    visible: !hideBaseHeader
                    color: $Colors.colorPrimary
                    Layout.preferredHeight: screenPaddingStatusbar + screenPaddingNotch + 52
                    Layout.preferredWidth: plantScreenDetailsPopup.width
                    RowLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            id: buttonBackBg
                            Layout.alignment: Qt.AlignVCenter
                            width: 65
                            height: 65
                            radius: height
                            color: "transparent" //$Colors.colorHeaderHighlight
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
                                    plantScreenDetailsPopup.close()
                                }
                            }

                            Behavior on opacity {
                                OpacityAnimator {
                                    duration: 333
                                }
                            }
                        }
                        Label {
                            text: qsTr("Back")
                            font.pixelSize: 21
                            font.bold: true
                            font.weight: Font.Medium
                            color: "white"
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Alert {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 40
                    time: 5000
                    visible: plantScreenDetailsPopup.alertMsg !== ""
                    text: plantScreenDetailsPopup.alertMsg
                    background {
                        color: $Colors.green600
                        radius: 0
                    }
                    textItem {
                        text: plantScreenDetailsPopup.alertMsg
                        color: "white"
                        font {
                            pixelSize: 16
                            weight: Font.Light
                        }
                    }

                    callback: function () {
                        plantScreenDetailsPopup.alertMsg = ""
                    }
                }
                Flickable {
                    y: header.height
                    contentHeight: mainContent.height
                    contentWidth: plantScreenDetailsPopup.width
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        ColumnLayout {
                            id: mainContent
                            width: parent.width

                            Rectangle {
                                property bool isFullScreen: false
                                Layout.fillWidth: true
                                Layout.preferredHeight: singleColumn ? 300 : plantScreenDetailsPopup.height / 3

                                clip: true
                                color: $Colors.green50

                                Label {
                                    text: "No image"
                                    font.pixelSize: 18
                                    anchors.centerIn: parent
                                }

                                Image {
                                    visible: Boolean(plant['images_plantes'])
                                    anchors.fill: parent
                                    source: {
                                        if (plant['images_plantes']?.count !== undefined) {
                                            console.log("First agent")
                                            return plant['images_plantes']?.count
                                                    ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/"
                                                                + plant['images_plantes']?.get(
                                                                    0).directus_files_id) : ""
                                        } else if (plant['images_plantes']?.length !== undefined) {
                                            console.log("Second agent ", plant['images_plantes'][0])
                                            return plant['images_plantes']?.length
                                                    ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/" + plant['images_plantes'][0].directus_files_id) : ""
                                        }
                                        return ""
                                    }

                                    clip: true
                                }

                                Image {
                                    visible: imagesURL
                                    source: imagesURL[0]
                                    anchors.fill: parent
                                    clip: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: fullScreen = !fullScreen
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                topPadding: -50

                                Rectangle {
                                    width: parent.width
                                    height: _insideColumn2.height
                                    radius: 40

                                    Column {
                                        id: _insideColumn2
                                        width: parent.width
                                        topPadding: 20
                                        leftPadding: 10
                                        rightPadding: 10

                                        ColumnLayout {
                                            id: _insideColumn3
                                            width: parent.width - 20
                                            spacing: 20

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 15

                                                Label {
                                                    text: plant?.name_scientific ?? ""
                                                    wrapMode: Text.Wrap
                                                    font.pixelSize: 24
                                                    color: $Colors.colorPrimary
                                                    font.weight: Font.DemiBold
                                                    Layout.alignment: Qt.AlignHCenter
                                                    Layout.fillWidth: true
                                                }

                                                Item {
                                                    Layout.fillWidth: true
                                                }

                                                Row {
                                                    Layout.fillWidth: true
                                                    spacing: 12
                                                    IconSvg {
                                                        source: "qrc:/assets/icons_custom/share.svg"
                                                        color: $Colors.colorPrimary
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                    IconSvg {
                                                        source: "qrc:/assets/icons_custom/blue-thumb.svg"
                                                        color: $Colors.colorPrimary
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                    IconSvg {
                                                        source: Icons.heart
                                                        color: $Colors.colorPrimary
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 15

                                                Label {
                                                    text: plant["nom_botanique"] ?? ""
                                                    wrapMode: Text.Wrap
                                                    font.pixelSize: 16
                                                    color: $Colors.colorPrimary
                                                    font.weight: Font.DemiBold
                                                    Layout.alignment: Qt.AlignHCenter
                                                    Layout.fillWidth: true
                                                }

                                                ButtonWireframe {
                                                    text: qsTr("Add to garden")
                                                    fullColor: true
                                                    primaryColor: "#DCA700"
                                                    fulltextColor: "white"
                                                    componentRadius: 20
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 35
                                                    padding: 3
                                                    leftPadding: 7
                                                    rightPadding: 7
                                                    onClicked: addToGarden()
                                                }

                                            }

                                            Column {
                                                Layout.fillWidth: true
                                                padding: 10

                                                Container {
                                                    width: parent.width - 20
                                                    background: Rectangle {
                                                        color:  $Colors.colorTertiary
                                                        radius: 10
                                                    }

                                                    contentItem: Column {
                                                        width: parent.width
                                                        padding: 10
                                                    }

                                                    Flickable {
                                                        width: parent.width - 20
                                                        height: 50
                                                        contentWidth: insideRow1.width
                                                        clip: true
                                                        Row {
                                                            id: insideRow1

                                                            RowLayout {
                                                                Layout.preferredWidth: 150
                                                                IconSvg {
                                                                    source: "qrc:/assets/icons_custom/double-forks.png"
                                                                    MouseArea {
                                                                        anchors.fill: parent
                                                                        onClicked: {
                                                                            plantScreenDetailsPopup.close()
                                                                            page_view.push(navigator.plantDetailsLinePage, {
                                                                                                                                                                              iconSource: "qrc:/assets/icons_custom/double-forks.png",
                                                                                                                                                                              titleText: qsTr("Commestibilité"),
                                                                                                                                                                              description: barDetailsColumn.gptDetails ? barDetailsColumn.gptDetails?.Commestible ?? qsTr("Inconnu") : '...'
                                                                                                                                                                              })
                                                                        }
                                                                    }
                                                                }

                                                                Column {
                                                                    Layout.fillWidth: true
                                                                    Label {
                                                                        text: qsTr("Commestibilité")
                                                                        font.pixelSize: 14
                                                                    }
                                                                    Label {
                                                                        width: 120
                                                                        wrapMode: Text.Wrap
                                                                        text:   barDetailsColumn.gptDetails ? barDetailsColumn.gptDetails?.Commestible ?? qsTr("Inconnu") : '...'
                                                                    }
                                                                }
                                                            }

                                                            RowLayout {
                                                                Layout.preferredWidth: 150
                                                                IconSvg {
                                                                    source: "qrc:/assets/icons_custom/death-head.svg"
                                                                    MouseArea {
                                                                        anchors.fill: parent
                                                                        onClicked: {
                                                                            plantScreenDetailsPopup.close()
                                                                            page_view.push(navigator.plantDetailsLinePage, {
                                                                                                      iconSource: "qrc:/assets/icons_custom/death-head.svg",
                                                                                                      titleText: qsTr("Toxicité"),
                                                                                                      description: barDetailsColumn.gptDetails ? barDetailsColumn.gptDetails?.Toxicité ?? qsTr("Inconnu") : '...'
                                                                                                      })
                                                                        }
                                                                    }
                                                                }

                                                                Column {
                                                                    Layout.fillWidth: true
                                                                    Label {
                                                                        wrapMode: Text.Wrap
                                                                        text: qsTr("Toxicité")
                                                                        font.pixelSize: 14
                                                                    }
                                                                    Label {
                                                                        width: 120
                                                                        text:  barDetailsColumn.gptDetails ? barDetailsColumn.gptDetails?.Toxicité ?? qsTr("Inconnu") : '...'
                                                                    }
                                                                }
                                                            }

                                                            RowLayout {
                                                                Layout.preferredWidth: 150
                                                                IconSvg {
                                                                    source: "qrc:/assets/icons_custom/co2.svg"
                                                                    MouseArea {
                                                                        anchors.fill: parent
                                                                        onClicked: {
                                                                            plantScreenDetailsPopup.close()
                                                                            page_view.push(navigator.plantDetailsLinePage, {
                                                                                                      iconSource: "qrc:/assets/icons_custom/co2.svg",
                                                                                                      titleText: qsTr("Absorption de CO2"),
                                                                                                      description:  barDetailsColumn.gptDetails ? qsTr("Faible") : '...'
                                                                                           })
                                                                        }
                                                                    }
                                                                }

                                                                Column {
                                                                    Layout.fillWidth: true
                                                                    Label {
                                                                        wrapMode: Text.Wrap
                                                                        text: qsTr("Absorption de CO2")
                                                                        font.pixelSize: 14
                                                                        width: parent.width
                                                                    }
                                                                    Label {
                                                                        width: 120
                                                                        text:  barDetailsColumn.gptDetails ? qsTr("Faible") : '...'
                                                                    }
                                                                }
                                                            }

                                                        }
                                                    }




                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 300
                                                color: "#FFE9A1"

                                                Flickable {
                                                    anchors.fill: parent
                                                    contentHeight: barDetailsColumn.height
                                                    clip: true
                                                    Column {
                                                        id: barDetailsColumn
                                                        width: parent.width
                                                        property var gptDetails: null
                                                        property bool isGptDetailsRunning: true

                                                        Component.onCompleted: {
                                                            Http.fetch({
                                                               "url": "http://34.41.96.172/question_answering?botanical_plant_name=" + plant["name_scientific"],
                                                                "method": "GET"
                                                               }).then(function(res) {
                                                                   barDetailsColumn.isGptDetailsRunning = false
                                                                   barDetailsColumn.gptDetails = JSON.parse(res)
                                                               }).catch(function(err) {
                                                                   console.log("FETCH ERROR", err?.status, typeof err?.status)
                                                                   control.isGptDetailsRunning = false
                                                               })

                                                        }

                                                        ColumnLayout {
                                                            width: parent.width
                                                            spacing: 10
                                                            RowLayout {
                                                                id: detailsBar
                                                                Layout.fillWidth: true
                                                                property int currentIndex: 0
                                                                spacing: 0
                                                                Repeater {
                                                                    model: [qsTr("Description"), qsTr("Usage"), qsTr("Blague"), qsTr("Quizz")]
                                                                    Label {
                                                                        text: modelData
                                                                        padding: 4
                                                                        leftPadding: 10
                                                                        rightPadding: 10
                                                                        Layout.fillWidth: true
                                                                        color: detailsBar.currentIndex === index ? "#9C7703" : "black"
                                                                        font {
                                                                            weight: Font.DemiBold
                                                                            pixelSize: 16
                                                                        }

                                                                        background: Rectangle {
                                                                            color: detailsBar.currentIndex === index ? "#FFE9A1" : $Colors.colorTertiary
                                                                        }
                                                                        MouseArea {
                                                                            anchors.fill: parent
                                                                            onClicked: {
                                                                                if(detailsBar.currentIndex !== index) detailsBar.currentIndex = index
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }

                                                            Item {
                                                                Layout.fillWidth: true
                                                                Layout.fillHeight: true

                                                                StackLayout {
                                                                    currentIndex: detailsBar.currentIndex
                                                                    anchors.fill: parent
                                                                    Item {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: true
                                                                        Label {
                                                                            width: 360
                                                                            wrapMode: Text.Wrap
                                                                            font.pixelSize: 16
                                                                            font.weight: Font.Light
                                                                            text: barDetailsColumn.gptDetails?.Description?? barDetailsColumn.gptDetails?.inconnu ?? ""
                                                                        }
                                                                    }
                                                                    Item {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: true
                                                                        Label {
                                                                            width: parent.width
                                                                            wrapMode: Text.Wrap
                                                                            font.pixelSize: 16
                                                                            font.weight: Font.Light
                                                                            text: barDetailsColumn.gptDetails?.Usage?? ""
                                                                        }
                                                                    }
                                                                    Item {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: true
                                                                        Label {
                                                                            width: parent.width
                                                                            wrapMode: Text.Wrap
                                                                            font.pixelSize: 16
                                                                            font.weight: Font.Light
                                                                            text: barDetailsColumn.gptDetails?.Blague?? ""
                                                                        }
                                                                    }
                                                                    Item {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: true
                                                                        Label {
                                                                            width: parent.width
                                                                            wrapMode: Text.Wrap
                                                                            font.pixelSize: 16
                                                                            font.weight: Font.Light
                                                                            text: "Cette section sera disponible prochainement"
                                                                        }
                                                                    }
                                                                }

                                                                BusyIndicator {
                                                                    anchors.topMargin: 50
                                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                                    running: barDetailsColumn.isGptDetailsRunning
                                                                }
                                                            }

                                                        }
                                                    }


                                                }

                                            }

                                            Column {
                                                Layout.fillWidth: true

                                                RowLayout {
                                                    width: parent.width
                                                    ButtonWireframe {
                                                        fullColor: true
                                                        primaryColor: "#087AE4"
                                                        fulltextColor: "white"
                                                        componentRadius: 10
                                                        Layout.preferredWidth: 90

                                                        Row {
                                                            spacing: 7
                                                            anchors.centerIn: parent
                                                            IconSvg {
                                                                source: Icons.heart
                                                                color: "white"
                                                            }
                                                            Label {
                                                                text: qsTr("Soin")
                                                                color: "white"
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }
                                                        }

                                                    }

                                                    Item {
                                                        Layout.fillWidth: true
                                                    }

                                                    ButtonWireframe {
                                                        fullColor: true
                                                        primaryColor: $Colors.colorPrimary
                                                        fulltextColor: "white"
                                                        componentRadius: 10
                                                        Layout.preferredWidth: 140

                                                        Row {
                                                            spacing: 7
                                                            anchors.centerIn: parent
                                                            IconSvg {
                                                                source: Icons.alert
                                                                color: "white"
                                                            }
                                                            Label {
                                                                text: qsTr("Blume AI")
                                                                color: "white"
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }
                                                        }

                                                    }

                                                }

                                                RowLayout {
                                                    width: parent.width
                                                    Label {
                                                        text: qsTr("Pour l'entretien")
                                                        color: "#505050"
                                                    }
                                                    Item {
                                                        Layout.fillWidth: true
                                                    }

                                                    Label {
                                                        text: qsTr("Pour plus d'informations")
                                                        color: "#505050"
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: plantScreenDetailsPopup.height / 2

                                                color: "#f0f0f0"
                                                radius: 10
                                                clip: true

                                                Label {
                                                    text: qsTr("No image available")
                                                    font.pixelSize: 22
                                                    anchors.centerIn: parent
                                                    visible: plant['images_plantes']
                                                             ?? true
                                                }

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    spacing: 5

                                                    Row {
                                                        Layout.fillWidth: true
                                                        Layout.leftMargin: 10
                                                        spacing: 10

                                                        IconSvg {
                                                            source: "qrc:/assets/icons_material/camera.svg"
                                                            width: 30
                                                            height: 30
                                                            color: $Colors.colorPrimary
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }

                                                        Label {
                                                            text: qsTr("Galerie de plantes")
                                                            color: $Colors.colorPrimary
                                                            font.pixelSize: 24
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                    }

                                                    SwipeView {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true

                                                        Repeater {
                                                            model: plant['images_plantes']
                                                            delegate: Image {
                                                                source: {
                                                                    return modelData['directus_files_id'] ? "https://blume.mahoudev.com/assets/" + modelData['directus_files_id'] : ""
                                                                }
                                                            }
                                                        }


                                                        Repeater {
                                                            model: imagesURL
                                                            delegate: Image {
                                                                source: {
                                                                    return modelData
                                                                }
                                                            }
                                                        }
                                                    }

                                                    RowLayout {
                                                        Layout.preferredHeight: 30
                                                        Layout.fillWidth: true

                                                        Item {
                                                            Layout.fillWidth: true
                                                        }

                                                        Repeater {
                                                            model: plant['images_plantes'] || imagesURL
                                                            delegate: Rectangle {
                                                                width: 10
                                                                height: 10
                                                                radius: 10
                                                                color: "black"
                                                            }
                                                        }

                                                        Item {
                                                            Layout.fillWidth: true
                                                        }
                                                    }
                                                }
                                            }

                                            Item {
                                                Layout.preferredHeight: 50
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }


}
