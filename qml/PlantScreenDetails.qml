import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
//import PlantUtils 1.0
import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase
import "components"
import "components_generic"
import SortFilterProxyModel

Popup {
    id: plantScreenDetailsPopup

    property string alertMsg: ""

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    padding: 0

    property variant plant: ({})
    property bool fullScreen: false

    function generateUUID() {
        // Public Domain/MIT
        var d = new Date().getTime()
        //Timestamp
        var d2 = ((typeof performance !== 'undefined')
                  && performance.now
                  && (performance.now(
                          ) * 1000)) || 0
        //Time in microseconds since page-load or 0 if unsupported
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
                    /[xy]/g, function (c) {
                        var r = Math.random(
                                    ) * 16
                        //random number between 0 and 16
                        if (d > 0) {
                            //Use timestamp until depleted
                            r = (d + r) % 16 | 0
                            d = Math.floor(
                                        d / 16)
                        } else {
                            //Use microseconds since page-load if supported
                            r = (d2 + r) % 16 | 0
                            d2 = Math.floor(
                                        d2 / 16)
                        }
                        return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(
                                    16)
                    })
    }

    function addToGarden(onSuccess) {

        spaceSearchPop.show(function (space){
            let data = {
                "libelle": plant?.name_scientific,
                "image_url": "-1",
                "remote_id": plant.id,
                "uuid": generateUUID()
            }
            data["plant_json"] = JSON.stringify(
                        plant)

            $Model.plant.sqlCreate(data).then(
                        function (new_plant) {
                            console.log('\n\n NEW PLANT ', typeof new_plant, JSON.stringify(new_plant))
                            let inData = {
                                "space_id": space.id,
                                "space_name": space.libelle,
                                "plant_json": new_plant["plant_json"],
                                "plant_id": new_plant.id
                            }
                            console.log("Continue...", )
                            $Model.space.plantInSpace.sqlCreate(
                                        inData).then(
                                        function () {
                                            console.log("Created AGAIN...")
                                            console.info("Done")
                                            if(onSuccess) onSuccess(new_plant, space)
                                        })
                            plantScreenDetailsPopup.alertMsg = qsTr("Plant added to garden")
                        }).catch(console.warn)
        })
    }

    function selectGardenSpace(onSuccess) {

        spaceSearchPop.show(function (space){
            let data = {
                "libelle": plant?.name_scientific,
                "image_url": "-1",
                "remote_id": plant.id,
                "uuid": generateUUID()
            }
            data["plant_json"] = JSON.stringify(
                        plant)

            if(onSuccess) onSuccess(plantScreenDetailsPopup.plant, space)
        }, currentPlantSpaces)
    }

    ListModel {
        id: currentPlantSpaces
    }

    onPlantChanged: {
        if(plantScreenDetailsPopup.plant.id) {
            $Model.space.listSpacesOfPlantRemoteID(plantScreenDetailsPopup.plant.id).then(function (res){
                currentPlantSpaces.clear()
                for(let i=0; i<res?.length; i++) {
                    currentPlantSpaces.append(res[i])
                }
            })
        }

    }
    onFullScreenChanged: {
        if(fullScreen) fullScreenPop.close()
        else fullScreenPop.open()
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
            if(plant['images_plantes']?.count !== undefined) {
                console.log("First agent")
                return plant['images_plantes']?.count
                                                   ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/" + plant['images_plantes']?.get(0).directus_files_id) : ""
            }
            else if(plant['images_plantes']?.length !== undefined) {
                console.log("Second agent")
                return plant['images_plantes']?.length
                                                   ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/" + plant['images_plantes'][0].directus_files_id) : ""
            }
            return ""

        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header
            color: Theme.colorPrimary
            Layout.preferredHeight: 65
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

            callback: function() {
                plantScreenDetailsPopup.alertMsg = "";
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
                    spacing: 10

                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Rectangle {
                        property bool isFullScreen: false
                        Layout.fillWidth: true
                        Layout.preferredHeight: singleColumn ? 300 : plantScreenDetailsPopup.height / 3

                        clip: true
                        color: "#f0f0f0"


                        Label {
                            text: "No image"
                            font.pixelSize: 18
                            anchors.centerIn: parent
//                            visible: (plant['images_plantes']?.length ?? ( plant['images_plantes']?.count ?? 0) ) > 0
                        }

                        Image {
                            anchors.fill: parent
                            source: {
                                if(plant['images_plantes']?.count !== undefined) {
                                    console.log("First agent")
                                    return plant['images_plantes']?.count
                                                                       ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/" + plant['images_plantes']?.get(0).directus_files_id) : ""
                                }
                                else if(plant['images_plantes']?.length !== undefined) {
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

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Layout.leftMargin: 10
                        Layout.rightMargin: 10

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
                                        text: plant["nom_botanique"] || ""
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
                                                console.log("noms_communs ", len, " -- ")
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
                                                    return "Non renseigné"
                                                else if (plant['care_level'] === "hard")
                                                    return "Difficile"
                                                else if (plant['care_level'] === "medium")
                                                    return "Moyen"
                                                else if (plant['care_level'] === "easy")
                                                    return "Facile"
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
                                                    return plant['frequence_arrosage']
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
                                            text: plant['exposition_au_soleil']
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
                                description: plant['type_de_plante'] || ""
                            }

                            TableLine {
                                title: qsTr("Dimensions")
                                description: plant['taill_adulte'] || ""
                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: qsTr("Sun exposure")
                                description: plant['exposition_au_soleil'] || ""
                            }

                            TableLine {
                                title: qsTr("Ground type")
                                description: plant['type_de_sol'] || ""
                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: qsTr("Color")
                                description: plant['couleur'] || ""
                            }

                            TableLine {
                                title: qsTr("Flowering period")
                                description: plant['periode_de_floraison'] || ""
                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: qsTr("Hardiness area")
                                description: plant['zone_de_rusticite'] || ""
                            }

                            TableLine {
                                title: "PH"
                                description: plant['ph'] || ""
                            }

//                            TableLine {
//                                title: qsTr("Watering frequency")
//                                description: plant['frequence_arrosage'] || ""
//                            }

//                            TableLine {
//                                color: "#e4f0ea"
//                                title: qsTr("Fertilization frequency")
//                                description: plant['frequence_fertilisation'] || ""
//                            }

//                            TableLine {
//                                title: qsTr("Paddling frequency")
//                                description: plant['frequence_rampotage'] || ""
//                            }

//                            TableLine {
//                                color: "#e4f0ea"
//                                title: qsTr("Cleaning frequency")
//                                description: plant['frequence_nettoyage'] || ""
//                            }

//                            TableLine {
//                                title: qsTr("Spray frequency")
//                                description: plant['frequence_vaporisation'] || ""
//                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: qsTr("Toxicity")
                                description: plant['toxicity'] ? 'Toxic' : 'Non-toxic'
                            }

                            TableLine {
                                title: qsTr("Lifecycle")
                                description: plant['cycle_de_vie'] || ""
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
                                visible: plant['images_plantes'] ?? true
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
                                                return modelData['directus_files_id'] ? "https://blume.mahoudev.com/assets/"
                                                                                    + modelData['directus_files_id'] : ""
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
                                        text: plant['description'] || ""
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
                                        text: plant['comment_cultiver'] || ""
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
                                        text: plant['description_luminosite']
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
                                        text: plant['description_sol'] || ""
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
                                        text: plant['description_temperature_humidite']
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
                                        text: plant['mise_en_pot_et_rampotage']
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
                                        text: plant['description_multiplication']
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
                                        text: plant['description'] || ""
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
                                                        source: "https://blume.mahoudev.com/assets/"
                                                                + model.modelData.directus_files_id
                                                    }
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                        }

                        Item {
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }
}
