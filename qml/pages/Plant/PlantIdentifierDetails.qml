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
import "../../"

Page {
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

    header: AppBar {
        title: plant_data.plant_name
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        ListModel {
            id: model_images
        }

        Rectangle {
            height: resultIdentifierDetailPop.height / 3
            Layout.fillWidth: true
            clip: true
            Image {
                source: details['wiki_image']['value']
                fillMode: Image.PreserveAspectCrop
            }
        }

        ColumnLayout {

            Layout.leftMargin: 20

            spacing: 10

            ColumnLayout {
                spacing: 3
                Label {
                    text: plant_data['plant_name']
                    font.pixelSize: 28
                    color: "white"
                    font.weight: Font.DemiBold
                }

                RowLayout {
                    Layout.maximumWidth: resultIdentifierDetailPop.width - 40

                    Repeater {
                        model: details['common_names']
                        delegate: Label {
                            required property int index
                            required property variant modelData

                            text: modelData + (index < details['common_names'].length ? ", " : "")
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            ScrollView {
                width: resultIdentifierDetailPop.width - 40

                RowLayout {
                    spacing: 20

                    Rectangle {
                        Layout.preferredHeight: 80
                        width: edibility_col.width + 20
                        color: "white" //Material.color(Material.Grey, Material.Shade100)
                        radius: 10

                        ColumnLayout {
                            id: edibility_col
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                Text {
                                    text: qsTr("Commestibilité")
                                    font.pixelSize: 16
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                IconImage {
                                    source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                                    width: 25
                                    height: 25
                                    visible: details['edible_parts'] !== null
                                    color: Theme.colorPrimary
                                }
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                Repeater {
                                    model: details['edible_parts']
                                    delegate: Text {
                                        required property int index
                                        required property variant modelData
                                        text: modelData
                                        font.pixelSize: 14
                                        Layout.margins: 20
                                    }
                                }
                            }

                            RowLayout {
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
                    }
                    Rectangle {
                        Layout.preferredHeight: 80
                        width: propagation_methods_col.width + 20
                        color: "white"
                        radius: 10
                        visible: details['propagation_methods'] !== null

                        ColumnLayout {
                            id: propagation_methods_col
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Text {
                                text: qsTr("Méthode de propagation")
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignHCenter
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignCenter
                                Repeater {
                                    model: details['propagation_methods']
                                    delegate: Text {
                                        required property int index
                                        required property variant modelData
                                        text: modelData
                                        font.pixelSize: 14
                                        Layout.margins: 20
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Label {
                text: details['wiki_description']['value']
                color: "white"
                Layout.maximumWidth: resultIdentifierDetailPop.width - 40
                wrapMode: Text.Wrap
            }

            RowLayout {

                Label {
                    text: "Plus d'informations sur Wikipédia"
                    color: "white"
                    font.pixelSize: 16
                }

                IconSvg {
                    source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                    color: "white"
                    width: 25

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally(details['url'])
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
