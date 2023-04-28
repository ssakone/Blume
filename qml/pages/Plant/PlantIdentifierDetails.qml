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
import "../../components"
import "../../components_generic"
import "../../"

BPage {
    id: resultIdentifierDetailPop
    property variant plant_data
    property variant details: plant_data["plant_details"]

    onVisibleChanged: {
        if (!visible)
            tabBar.currentIndex = 0
        else {
            let data = [details["wiki_image"]]
            data = data.concat(details['wiki_images'].map(item => item))
            data.forEach(item => model_images.append(item))
        }
    }

    background: Rectangle {
        color: Theme.colorPrimary
    }

    header: AppBar {}

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ListModel {
            id: model_images
        }

        Rectangle {
            Layout.preferredHeight: resultIdentifierDetailPop.height / 3
            Layout.fillWidth: true
            clip: true
            Image {
                anchors.fill: parent
                source: details['wiki_image']['value']
                fillMode: Image.PreserveAspectCrop
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _insideCol1.height
            clip: true

            Column {
                id: _insideCol1
                width: parent.width - 20
                padding: 10

                Column {
                    width: parent.width
                    spacing: 10

                    ColumnLayout {
                        width: parent.width
                        spacing: 3
                        Label {
                            text: plant_data['plant_name']
                            font.pixelSize: 28
                            color: "white"
                            font.weight: Font.DemiBold
                        }

                        Row {
                            Layout.fillWidth: true

                            Repeater {
                                model: details['common_names']
                                delegate: Label {
                                    required property int index
                                    required property variant modelData

                                    text: modelData + (index < details['common_names'].length ? ", " : "")
                                }
                            }

                        }
                    }

                    Flickable {
                        width: parent.width
                        height: _insideRow1.height
                        contentWidth: _insideRow1.width

                        Row {
                            id: _insideRow1
                            spacing: 20

                            Container {
                                width: resultIdentifierDetailPop.width / 2

                                background: Rectangle {
                                    color: "white"
                                    radius: 10
                                }
                                contentItem: Column {
                                    width: parent.width

                                }

                                Row {
                                    Text {
                                        text: qsTr("Commestibilité")
                                        font.pixelSize: 16
                                    }
                                    IconImage {
                                        source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                                        width: 25
                                        height: 25
                                        visible: details['edible_parts'] !== null
                                        color: Theme.colorPrimary
                                    }
                                }

                                Row {
                                    Repeater {
                                        model: details['edible_parts']
                                        delegate: Text {
                                            required property int index
                                            required property variant modelData
                                            text: modelData
                                            font.pixelSize: 14
                                            padding: 5
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                }

                                Row {
                                    spacing: 5
                                    visible: details['edible_parts'] === null
                                    Layout.alignment: Qt.AlignCenter
                                    IconImage {
                                        source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                                        width: 25
                                        height: 25
                                        color: Material.color(Material.Red,
                                                              Material.Shade600)
                                    }
                                    Label {
                                        text: "Plante toxique"
                                        color: Material.color(Material.Red,
                                                              Material.Shade600)
                                        font.pixelSize: 18
                                    }
                                }

                            }

                            Container {
                                width: resultIdentifierDetailPop.width / 2
                                background: Rectangle {
                                    color: "white"
                                    radius: 10
                                }
                                contentItem: Column {
                                    width: parent.width
                                    padding: 5
                                }

                                Row {
                                    IconImage {
                                        source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                                        width: 25
                                        height: 25
                                        visible: details['propagation_methods'] !== null
                                        color: Theme.colorPrimary
                                    }
                                    Text {
                                        text: qsTr("Méthode de propagation")
                                        font.pixelSize: 16
                                    }
                                }

                                Row {
                                    Repeater {
                                        model: details['propagation_methods']
                                        delegate: Text {
                                            required property int index
                                            required property variant modelData
                                            text: modelData
                                            font.pixelSize: 14
                                            padding: 5
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        text: details['wiki_description']['value']
                        wrapMode: Text.Wrap
                        width: parent.width
                        font {
                            weight: Font.Light
                            pixelSize: 16
                        }
                    }

                    ButtonWireframeIcon {
                        text: "Plus d'informations sur Wikipédia"
                        fulltextColor: Theme.colorPrimary
                        primaryColor: "white"
                        fullColor: true
                        font.pixelSize: 16
                        source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                        onClicked: Qt.openUrlExternally(details['url'])
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }


        }
    }

}
