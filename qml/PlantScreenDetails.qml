import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
//import PlantUtils 1.0
import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase
import "components"
import "components_generic"
import "components_js/Http.js" as Http
import SortFilterProxyModel

Popup {
    id: plantScreenDetailsPopup

    property string alertMsg: ""

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    padding: 0

    property var plant: {
        ""
    }

    QtObject {
        id: _plant
        property string frequence_arrosage: ""
        property string exposition_au_soleil: ""
        property string taill_adulte: ""
        property string type_de_sol: ""
        property string couleur: ""
        property string periode_de_floraison: ""
        property string zone_de_rusticite: ""
        property string frequence_fertilisation: ""
        property string frequence_rampotage: ""
        property string frequence_nettoyage: ""
        property string frequence_vaporisation: ""
        property string description: ""
        property string comment_cultiver: ""
        property string description_luminosite: ""
        property string description_sol: ""
        property string description_temperature_humidite: ""
        property string description_mise_en_pot_et_rampotage: ""
        property string description_multiplication: ""
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

    function translate(from, to) {
        console.log("\n CALL TRANSLATE ", from, to)
        let data = ["00" + ": " + plant["care_level"] ?? "", "01" + ": " + plant["frequence_arrosage"] ?? "", "02" + ": " + plant["exposition_au_soleil"]
                    ?? "", "03" + ": " + plant["taill_adulte"] ?? "", "05" + ": " + plant["type_de_sol"] ?? "", "06" + ": "
                    + plant["couleur"] ?? "", "07" + ": " + plant["periode_de_floraison"] ?? "", "08" + ": " + plant["zone_de_rusticite"] ?? "", "09"
                    + ": " + plant["frequence_arrosage"] ?? "", "10" + ": " + plant["frequence_fertilisation"] ?? "", "11" + ": " + plant["frequence_rampotage"]
                    ?? "", "12" + ": " + plant["frequence_nettoyage"] ?? "", "13" + ": " + plant["frequence_vaporisation"] ?? "", "14" + ": "
                    + plant["description"] ?? "", "15" + ": " + plant["comment_cultiver"] ?? "", "16" + ": " + plant["description_luminosite"] ?? "", "17"
                    + ": " + plant["description_sol"] ?? "", "18" + ": " + plant["description_temperature_humidite"] ?? "", "19" + ": " + plant["mise_en_pot_et_rampotage"]
                    ?? "", "20" + ": " + plant["description_multiplication"] ?? ""]
        let query = {
            "method": "POST",
            "url": "https://api.deepl.com/v2/translate",
            "headers": {
                "Accept": 'application/json',
                "Authorization": "DeepL-Auth-Key 66fcbbd7-a786-d323-d0f2-4c032091000e",
                "Content-Type": 'application/json'
            },
            "params": {
                "text": data,
                "target_lang": to,
                "preserve_formatting": true,
                "source_lang": from
            }
        }

        Http.fetch(query).then(function (res) {
            console.log("\n GOT TRANSLATES")
            res = res.replace("\r\n", " ")
            let new_data = JSON.parse(res).translations

            let datas = {}
            for (var i = 0; i < new_data.length; i++) {
                let item = new_data[i]
                let sp = item.text.split(": ")
                datas[sp[0]] = sp[1] === "undefined" ? "" : sp[1]
            }

            new_data = datas
            console.log(JSON.stringify(new_data))
            _plant.frequence_arrosage = new_data['01']
            _plant.exposition_au_soleil = new_data['02']
            _plant.taill_adulte = new_data['03']
            _plant.type_de_sol = new_data['05']
            _plant.couleur = new_data['06']
            _plant.periode_de_floraison = new_data['07']
            _plant.zone_de_rusticite = new_data['08']
            _plant.frequence_arrosage = new_data['09']
            _plant.frequence_fertilisation = new_data['10']
            _plant.frequence_rampotage = new_data['11']
            _plant.frequence_nettoyage = new_data['12']
            _plant.frequence_vaporisation = new_data['13']
            _plant.description = new_data['14']
            _plant.comment_cultiver = new_data['15']
            _plant.description_luminosite = new_data['16']
            _plant.description_sol = new_data['17']
            _plant.description_temperature_humidite = new_data['18']
            _plant.description_mise_en_pot_et_rampotage = new_data['19']
            _plant.description_multiplication = new_data['20']

            console.log(plant.type_de_sol)
        }).catch(function (err) {
            console.log("Erreur: ", JSON.stringify(err), err)
        })
    }

    onPlantChanged: {
        _plant.frequence_arrosage = plant.frequence_arrosage || ""
        _plant.exposition_au_soleil = plant.exposition_au_soleil || ""
        _plant.taill_adulte = plant.taill_adulte || ""
        _plant.type_de_sol = plant.type_de_sol || ""
        _plant.couleur = plant.couleur || ""
        _plant.periode_de_floraison = plant.periode_de_floraison || ""
        _plant.zone_de_rusticite = plant.zone_de_rusticite || ""
        _plant.frequence_arrosage = plant.frequence_arrosage || ""
        _plant.frequence_fertilisation = plant.frequence_fertilisation || ""
        _plant.frequence_rampotage = plant.frequence_rampotage || ""
        _plant.frequence_nettoyage = plant.frequence_nettoyage || ""
        _plant.frequence_vaporisation = plant.frequence_vaporisation || ""
        _plant.description = plant.description || ""
        _plant.comment_cultiver = plant.comment_cultiver || ""
        _plant.description_luminosite = plant.description_luminosite || ""
        _plant.description_sol = plant.description_sol || ""
        _plant.description_temperature_humidite = plant.description_temperature_humidite
                || ""
        _plant.description_mise_en_pot_et_rampotage = plant.description_mise_en_pot_et_rampotage
                || ""
        _plant.description_multiplication = plant.description_multiplication
                || ""

        console.log(settingsManager.appLanguage)
        if ("name_scientific" in plant) {
            switch (settingsManager.appLanguage) {
            case "Español":
                translate("FR", "ES")
                break
            case "Deutsch":
                translate("FR", "DE")
                break
            default:
                translate("FR", "EN")
                break
            }
        }

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

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header
            visible: !hideBaseHeader
            color: Theme.colorPrimary
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
                            anchors.fill: parent
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
                                            ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/" + plant['images_plantes'][0].directus_files_id) : ""
                                }
                                return ""
                            }

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

                                    Label {
                                        text: plant?.name_scientific ?? ""
                                        wrapMode: Text.Wrap
                                        font.pixelSize: 24
                                        font.weight: Font.DemiBold
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: col_header.height

                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10

                                        color: "#f0f0f0"
                                        radius: 15
                                        ColumnLayout {
                                            id: col_header
                                            width: parent.width
                                            anchors.topMargin: 10
                                            anchors.bottomMargin: 10

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                Layout.leftMargin: 10

                                                Label {
                                                    text: qsTr("Botanical name")
                                                    font.pixelSize: 14
                                                    font.weight: Font.Light
                                                    Layout.minimumWidth: 120
                                                }
                                                Label {
                                                    text: plant["nom_botanique"]
                                                          || ""
                                                    font.pixelSize: 20
                                                    font.weight: Font.DemiBold
                                                    horizontalAlignment: Text.AlignLeft
                                                    color: Theme.colorPrimary
                                                    wrapMode: Text.Wrap
                                                    Layout.fillWidth: true
                                                }
                                                Item {
                                                    Layout.fillWidth: true
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 1

                                                color: "black"
                                                opacity: 0.3
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                Layout.leftMargin: 10
                                                Layout.rightMargin: 10

                                                Label {
                                                    text: qsTr("Common names")
                                                    font.pixelSize: 14
                                                    font.weight: Font.Light
                                                    Layout.minimumWidth: 120
                                                }
                                                Label {
                                                    text: {
                                                        let res = ""
                                                        if (plant['noms_communs']) {
                                                            let common_names = plant['noms_communs']
                                                            let len = common_names?.length
                                                            console.log("noms_communs ",
                                                                        len,
                                                                        " -- ")
                                                            common_names?.forEach(
                                                                        (item, index) => res += (item.name ?? item + (len === index + 1 ? "" : ", ")))
                                                        }
                                                        return res
                                                    }
                                                    font.pixelSize: 14
                                                    font.weight: Font.DemiBold
                                                    wrapMode: Text.Wrap
                                                    horizontalAlignment: Text.AlignLeft
                                                    color: Theme.colorPrimary
                                                    Layout.fillWidth: true
                                                }
                                                Item {
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                    }

                                    ButtonWireframe {
                                        text: qsTr("Add to garden")
                                        fullColor: Theme.colorPrimary
                                        fulltextColor: "white"
                                        componentRadius: 20
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        onClicked: addToGarden()
                                    }

                                    Flickable {
                                        Layout.fillWidth: true
                                        //                            Layout.preferredWidth: _insideRow.width
                                        Layout.preferredHeight: 120
                                        contentWidth: _insideRow.width

                                        Row {
                                            id: _insideRow
                                            spacing: 10

                                            Rectangle {
                                                height: 120
                                                width: height + 30
                                                color: "#f0f0f0"
                                                radius: 20
                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.topMargin: 10
                                                    spacing: 7

                                                    IconSvg {
                                                        source: "qrc:/assets/icons/svg/shovel.svg"
                                                        color: Theme.colorPrimary

                                                        Layout.preferredWidth: 30
                                                        Layout.preferredHeight: 30
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }

                                                    Label {
                                                        text: qsTr("Care")
                                                        font.pixelSize: 18
                                                        font.weight: Font.ExtraBold
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }

                                                    Label {
                                                        text: {
                                                            if (!plant['care_level'])
                                                                return qsTr("Not set")
                                                            else if (plant['care_level'] === "hard")
                                                                return qsTr("Hard")
                                                            else if (plant['care_level']
                                                                     === "medium")
                                                                return qsTr("Medium")
                                                            else if (plant['care_level'] === "easy")
                                                                return qsTr("Easy")
                                                        }

                                                        font.pixelSize: 14

                                                        wrapMode: Text.Wrap
                                                        horizontalAlignment: Text.AlignHCenter

                                                        Layout.fillWidth: true
                                                        Layout.leftMargin: 10
                                                        Layout.rightMargin: 10
                                                    }

                                                    Item {
                                                        Layout.fillHeight: true
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                height: 120
                                                width: height + 30
                                                color: "#f0f0f0"
                                                radius: 20
                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.topMargin: 10
                                                    spacing: 7

                                                    IconSvg {
                                                        source: "qrc:/assets/icons/svg/water-plus-outline.svg"
                                                        color: Theme.colorPrimary

                                                        Layout.preferredWidth: 30
                                                        Layout.preferredHeight: 30
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }

                                                    Label {
                                                        text: qsTr("Watering")
                                                        font.pixelSize: 18
                                                        font.weight: Font.ExtraBold
                                                        Layout.alignment: Qt.AlignHCenter
                                                    }

                                                    Label {
                                                        text: {
                                                            if (!plant['frequence_arrosage'])
                                                                return "Not set"
                                                            else
                                                                return _plant.frequence_arrosage
                                                        }
                                                        font.pixelSize: 14

                                                        wrapMode: Text.Wrap
                                                        horizontalAlignment: Text.AlignHCenter

                                                        Layout.fillWidth: true
                                                        Layout.leftMargin: 10
                                                        Layout.rightMargin: 10
                                                        Layout.bottomMargin: 10
                                                    }

                                                    Item {
                                                        Layout.fillHeight: true
                                                    }
                                                }
                                            }

                                            Container {
                                                height: 120

                                                background: Rectangle {
                                                    color: "#f0f0f0"
                                                    radius: 20
                                                }
                                                contentItem: Row {}

                                                Column {
                                                    padding: 10
                                                    spacing: 7

                                                    IconSvg {
                                                        source: "qrc:/assets/icons_material/duotone-brightness_4-24px.svg"
                                                        color: Theme.colorPrimary

                                                        height: 30
                                                        width: height
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }

                                                    Label {
                                                        text: qsTr("Sun")
                                                        font.pixelSize: 18
                                                        font.weight: Font.ExtraBold
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }

                                                    Label {
                                                        text: _plant.exposition_au_soleil
                                                              || ""

                                                        font.pixelSize: 14

                                                        wrapMode: Text.Wrap
                                                        horizontalAlignment: Text.AlignHCenter

                                                        //                                            width: parent.width
                                                        anchors.leftMargin: 10
                                                        anchors.rightMargin: 10
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        TableLine {
                                            color: "#e4f0ea"
                                            title: qsTr("Type of plant")
                                            description: _plant.type_de_sol
                                                         || ""
                                        }

                                        TableLine {
                                            title: qsTr("Color")
                                            description: _plant.couleur || ""
                                        }

                                        TableLine {
                                            color: "#e4f0ea"
                                            title: qsTr("Toxicity")
                                            description: plant['toxicity'] ? 'Toxic' : 'Non-toxic'
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: qsTr("See more...")
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: page_view.push(
                                                                   navigator.plantShortDescriptionsPage,
                                                                   {
                                                                       "plant": _plant
                                                                   })
                                                }
                                            }
                                        }
                                    }

                                    Container {
                                        Layout.fillWidth: singleColumn
                                        Layout.alignment: Qt.AlignHCenter
                                        background: Rectangle {
                                            color: Theme.colorPrimary
                                            opacity: 0.1
                                            radius: 10
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: page_view.push(
                                                               navigator.plantFrequenciesPage,
                                                               {
                                                                   "plant": _plant
                                                               })
                                            }
                                        }

                                        contentItem: Flow {
                                            padding: 10
                                            width: singleColumn ? _insideColumn3.width
                                                                  - 20 : parent.width
                                            spacing: 10
                                        }

                                        Repeater {
                                            model: ListModel {
                                                ListElement {
                                                    title: qsTr("Watering frequency")
                                                    field: 'frequence_arrosage'
                                                    icon: 'wateringCan'
                                                }
                                                ListElement {
                                                    title: qsTr("Fertilization frequency")
                                                    field: 'frequence_fertilisation'
                                                    icon: 'floorPlan'
                                                }
                                                ListElement {
                                                    title: qsTr("Paddling frequency")
                                                    field: 'frequence_rampotage'
                                                    icon: 'beeFlower'
                                                }
                                                ListElement {
                                                    title: qsTr("Cleaning frequency")
                                                    field: 'frequence_nettoyage'
                                                    icon: 'brush'
                                                }
                                                ListElement {
                                                    title: qsTr("Spray frequency")
                                                    field: 'frequence_vaporisation'
                                                    icon: 'filterVariantPlus'
                                                }
                                            }

                                            Row {
                                                spacing: 5

                                                IconSvg {
                                                    source: Icons[model.icon]
                                                    color: Theme.colorPrimary
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: 20
                                                    height: width
                                                }
                                                Column {
                                                    width: 130
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    Label {
                                                        text: model.title
                                                        color: Theme.colorPrimary
                                                    }
                                                    Label {
                                                        text: _plant[model.field]
                                                              ?? ""
                                                        color: $Colors.gray600
                                                        width: parent.width
                                                        elide: Text.ElideMiddle
                                                        visible: text !== ""
                                                    }
                                                }
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
                                                    color: Theme.colorPrimary
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Label {
                                                    text: qsTr("Photos galery")
                                                    color: Theme.colorPrimary
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
                                            }

                                            RowLayout {
                                                Layout.preferredHeight: 30
                                                Layout.fillWidth: true

                                                Item {
                                                    Layout.fillWidth: true
                                                }

                                                Repeater {
                                                    model: plant['images_plantes']
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

                                    Column {
                                        Layout.fillWidth: true

                                        spacing: 3

                                        Accordion {
                                            header: qsTr("Plant description")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['description']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                }
                                            ]
                                        }

                                        Accordion {
                                            header: qsTr("How to farm")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['comment_cultiver']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                }
                                            ]
                                        }

                                        Accordion {
                                            header: qsTr("Brightness")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['description_luminosite']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                }
                                            ]
                                        }

                                        Accordion {
                                            header: qsTr("Ground")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['description_sol']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                }
                                            ]
                                        }

                                        Accordion {
                                            header: qsTr("Temperature & humidity")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['description_temperature_humidite']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                }
                                            ]
                                        }

                                        Accordion {
                                            header: qsTr("Potting and crawling")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['description_mise_en_pot_et_rampotage']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                }
                                            ]
                                        }

                                        Accordion {
                                            header: qsTr("Multiplication")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['description_multiplication']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                }
                                            ]
                                        }

                                        Accordion {
                                            header: qsTr("Parasites and diseases")
                                            contentItemsLayouted: [
                                                Label {
                                                    text: _plant['description']
                                                          || ""
                                                    wrapMode: Text.Wrap

                                                    font.pixelSize: 18
                                                    font.weight: Font.Light

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 10
                                                    Layout.rightMargin: 10
                                                },

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: plantScreenDetailsPopup.height / 3

                                                    color: "#f0f0f0"
                                                    radius: 10
                                                    clip: true

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        spacing: 2

                                                        RowLayout {
                                                            Layout.preferredHeight: 30
                                                            Layout.fillWidth: true

                                                            Item {
                                                                Layout.fillWidth: true
                                                            }

                                                            Repeater {
                                                                model: plant['images_maladies']
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

                                                        SwipeView {
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true

                                                            Repeater {
                                                                model: plant['images_maladies']
                                                                delegate: Image {
                                                                    source: "https://blume.mahoudev.com/assets/" + model.modelData.directus_files_id
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            ]
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
