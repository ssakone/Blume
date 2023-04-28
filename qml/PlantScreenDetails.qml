import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
//import PlantUtils 1.0
import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase
import "components"

Popup {
    id: plantScreenDetailsPopup

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    padding: 0

    property variant plant: ({})

    ListModel {
        id: modelImagesPlantes
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header
            color: "#00c395"
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
                    text: "Retour"
                    font.pixelSize: 21
                    font.bold: true
                    font.weight: Font.Medium
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
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
                        Layout.fillWidth: true
                        Layout.preferredHeight: singleColumn ? 300 : plantScreenDetailsPopup.height / 3

                        visible: plant['images_plantes']?.length ?? 0 > 0
                        clip: true
                        color: "#f0f0f0"

                        Image {
                            anchors.fill: parent
                            source: plant['images_plantes']?.length
                                    ?? 0 > 0 ? ("https://blume.mahoudev.com/assets/" + plant['images_plantes'][0].directus_files_id) : ""
                            clip: true
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
                                        text: "Nom botanique: "
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

                                    Label {
                                        text: "Nom commun: "
                                        font.pixelSize: 14
                                        font.weight: Font.Light
                                        Layout.minimumWidth: 120
                                    }
                                    Label {
                                        text: {
                                            let res = ""
                                            if (plant['noms_communs']) {
                                                let common_names = plant['noms_communs']?.slice(
                                                        1)
                                                let len = common_names.length
                                                common_names.forEach(
                                                            (level, index) => res += (level + (len === index + 1 ? "" : ", ")))
                                            }
                                            return res
                                        }
                                        font.pixelSize: 16
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
                            text: "Ajouter à mon jardin"
                            fullColor: Theme.colorPrimary
                            fulltextColor: "white"
                            componentRadius: 20
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Rectangle {
                                Layout.minimumHeight: 120
                                Layout.fillWidth: true
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
                                        text: "Soin"
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
                                Layout.minimumHeight: 120
                                Layout.fillWidth: true
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
                                        text: "Arroser"
                                        font.pixelSize: 18
                                        font.weight: Font.ExtraBold
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Label {
                                        text: {
                                            if (!plant['frequence_arrosage'])
                                                return "Non renseigné"
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

                            Rectangle {
                                Layout.minimumHeight: 120
                                Layout.fillWidth: true
                                color: "#f0f0f0"
                                radius: 20
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: 10
                                    spacing: 7

                                    IconSvg {
                                        source: "qrc:/assets/icons_material/duotone-brightness_4-24px.svg"
                                        color: Theme.colorPrimary

                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Label {
                                        text: "Soleil"
                                        font.pixelSize: 18
                                        font.weight: Font.ExtraBold
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Label {
                                        text: plant['exposition_au_soleil']
                                              || ""

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
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            TableLine {
                                title: "Type de plante"
                                description: plant['taill_adulte'] || ""
                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: "Exposition au soleil"
                                description: plant['exposition_au_soleil'] || ""
                            }

                            TableLine {
                                title: "Type de sol"
                                description: plant['type_de_sol'] || ""
                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: "Couleur"
                                description: plant['couleur'] || ""
                            }

                            TableLine {
                                title: "Période de floraison"
                                description: plant['periode_de_floraison'] || ""
                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: "Zone de rusticité"
                                description: plant['zone_de_rusticite'] || ""
                            }

                            TableLine {
                                title: "PH"
                                description: plant['ph'] || ""
                            }

                            TableLine {
                                color: "#e4f0ea"
                                title: "Toxicité"
                                description: plant['toxicity'] ? 'Plante toxique' : 'Non toxique'
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: plantScreenDetailsPopup.height / 2

                            color: "#f0f0f0"
                            radius: 10
                            clip: true

                            Label {
                                text: "Aucun image disponible"
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
                                        text: "Galerie de photos"
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
                                            source: model['directus_files_id'] ? "https://blume.mahoudev.com/assets/"
                                                    + model['directus_files_id'] : ""
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
                                header: "Présentation des plantes"
                                contentItems: [
                                    Label {
                                        text: plant['description'] || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
                                        font.weight: Font.Light

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10
                                    }
                                ]
                            }

                            Accordion {
                                header: "Comment cultiver"
                                contentItems: [
                                    Label {
                                        text: plant['comment_cultiver'] || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
                                        font.weight: Font.Light

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10
                                    }
                                ]
                            }

                            Accordion {
                                header: "Luminosité"
                                contentItems: [
                                    Label {
                                        text: plant['description_luminosite']
                                              || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
                                        font.weight: Font.Light

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10
                                    }
                                ]
                            }

                            Accordion {
                                header: "Sol"
                                contentItems: [
                                    Label {
                                        text: plant['description_sol'] || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
                                        font.weight: Font.Light

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10
                                    }
                                ]
                            }

                            Accordion {
                                header: "Température & humidité"
                                contentItems: [
                                    Label {
                                        text: plant['description_temperature_humidite']
                                              || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
                                        font.weight: Font.Light

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10
                                    }
                                ]
                            }

                            Accordion {
                                header: "Mise en pot et rampotage"
                                contentItems: [
                                    Label {
                                        text: plant['description_mise_en_pot_et_rampotage']
                                              || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
                                        font.weight: Font.Light

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10
                                    }
                                ]
                            }

                            Accordion {
                                header: "Multiplication"
                                contentItems: [
                                    Label {
                                        text: plant['description_multiplication']
                                              || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
                                        font.weight: Font.Light

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 10
                                        Layout.rightMargin: 10
                                    }
                                ]
                            }

                            Accordion {
                                header: "Parasites et maladies"
                                contentItems: [
                                    Label {
                                        text: plant['description'] || ""
                                        wrapMode: Text.Wrap

                                        font.pixelSize: 14
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
