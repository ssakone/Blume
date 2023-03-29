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
import "components"

Popup {
    id: resultIdentifierDetailPop
    dim: true
    modal: true
    property variant plant_data
    property variant details: plant_data["plant_details"]
    width: appWindow.width
    height: appWindow.height
    padding: 0
    onClosed:  {
        tabBar.currentIndex = 0
    }
    background: Rectangle {
        color: Theme.colorPrimary
    }

    onOpened: {
        let data = [details["wiki_image"]]
        data = data.concat(details['wiki_images'].map(item => item ))
        data.forEach(item => model_images.append(item) )

//        console.warn("Data in ", data)
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        Rectangle {
            color: "#00c395"
            Layout.preferredHeight: 65
            Layout.fillWidth: true
            Row {
                anchors.verticalCenter: parent.verticalCenter
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
                            resultIdentifierDetailPop.close()
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
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

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
// How to make a carousel ?
//        Rectangle {
//            height: 50
//            Layout.fillWidth: true
//            RowLayout {
//                Layout.alignment: Qt.AlignHCenter
//                height: parent.height
//                Repeater {
//                    model: model_images
//                    delegate: IconImage {
//                        required property variant value
//                        source: value
//                        width: 50
//                        height: 50
//                        fillMode: Image.PreserveAspectCrop
//                        Component.onCompleted: console.log(value)
//                    }
//                }
//            }
//        }


        ColumnLayout {
            Layout.fillHeight: true
//            Layout.fillWidth: true
            width: resultIdentifierDetailPop.width - 40

            Layout.leftMargin: 20
//            Layout.rightMargin: 20


            spacing: 15

            Label {
                text: plant_data['plant_name']
                font.pixelSize: 28
                color: Material.color(Material.Grey, Material.Shade800)
                font.weight: Font.DemiBold
            }

            RowLayout {
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


            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                RowLayout {
                    Layout.fillWidth: true
                    clip: true
                    Rectangle {
                        Layout.preferredHeight: 80
                        Layout.preferredWidth: 230
                        color: "white" //Material.color(Material.Grey, Material.Shade100)
                        radius: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            width: parent.width

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
                                    color: Material.color(Material.Red, Material.Shade600)
                                }
                                Label {
                                    text: "Plante toxique"
                                    color: Material.color(Material.Red, Material.Shade600)
                                    font.pixelSize: 18
                                }
                            }


                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: 80
                        Layout.preferredWidth: 230
                        color: "white"
                        radius: 10
                        visible: details['propagation_methods'] !== null

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            width: parent.width
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

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: 50
                    }
                }

            }


            Rectangle {
                Layout.fillWidth: true
                width: 300 //resultIdentifierDetailPop.width - 200

                Text {
                    text: details['wiki_description']['value']
                    color: "white"
//                    Layout.alignment: Qt.AlignHCenter
                }
            }


            RowLayout {

                ButtonWireframe {
                    text: "Wikipédia"
                    Layout.preferredHeight: 45
                    fullColor: true
                    primaryColor: "white"
                    fulltextColor: Theme.colorPrimary
                    onClicked: Qt.openUrlExternally(details['url'])
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
