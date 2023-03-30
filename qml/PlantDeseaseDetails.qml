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
    id: resultDeseaseDetailPop
    dim: true
    modal: true
//    property variant uploaded_images: []
    property variant desease_data
    property variant details: desease_data["disease_details"]
    width: appWindow.width
    height: appWindow.height
    padding: 0

    background: Rectangle {
        color: Theme.colorPrimary
    }

    onOpened: {
        let data = desease_data['similar_images']
//        data = data.concat(desease_data['similar_images'])
//        data.forEach(item => model_images.append(item) )

        console.warn("Data in ", JSON.stringify(desease_data))
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
                            resultDeseaseDetailPop.close()
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
            height: resultDeseaseDetailPop.height / 3
            Layout.fillWidth: true
            clip: true
            Image {
                source: desease_data['similar_images'][0]['url']
                fillMode: Image.PreserveAspectCrop
            }
        }


        ColumnLayout {
//            width: resultDeseaseDetailPop.width - 40

            Layout.leftMargin: 20

            spacing: 10

            ColumnLayout {
                spacing: 3
                Label {
                    text: desease_data['name']
                    font.pixelSize: 28
                    color: Material.color(Material.Grey, Material.Shade800)
                    font.weight: Font.DemiBold
                }

                RowLayout {
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


            Text {
                text: details['description']
                color: "white"
            }

            Rectangle {
                Layout.preferredHeight: 80
                Layout.fillWidth: true
                width: propagation_methods_col.width + 20
                color: "white"
                radius: 10
                visible: details['cause'] !== null

                ColumnLayout {
                    id: propagation_methods_col
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        text: qsTr("Cause")
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignCenter
                        Repeater {
                            model: details['cause']
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

            Label {
                text: "Traitements"
                font.pixelSize: 24
            }

            Flickable {
                Layout.fillWidth: true
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout {

                    Rectangle {
                        Layout.preferredHeight: 80
                        Layout.fillWidth: true
                        width: treat_prevention_col.width + 40
                        color: "white"
                        radius: 10

                        ColumnLayout {
                            id: treat_prevention_col
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                Text {
                                    text: qsTr("Prévention")
                                    font.pixelSize: 16
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                IconImage {
                                    source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                    width: 25
                                    height: 25
                                    color: Theme.colorPrimary
                                }
                            }

                            ColumnLayout {
//                                Layout.alignment: Qt.AlignHCenter
                                Repeater {
                                    model: details['treatment']['prevention']
                                    delegate: Text {
                                        required property int index
                                        required property variant modelData
                                        text: '- ' + modelData
                                        font.pixelSize: 14
                                        Layout.margins: 20
                                    }
                                }
                            }

                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: 80
                        Layout.fillWidth: true
                        width: treat_chemical_col.width + 20
                        color: "white"
                        radius: 10

                        ColumnLayout {
                            id: treat_chemical_col
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                Text {
                                    text: qsTr("Traitement chimique")
                                    font.pixelSize: 16
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                IconImage {
                                    source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                    width: 25
                                    height: 25
                                    color: Theme.colorPrimary
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignHCenter
                                Repeater {
                                    model: details['treatment']['chemical']
                                    delegate: Text {
                                        required property int index
                                        required property variant modelData
                                        text: '- ' + modelData
                                        font.pixelSize: 14
                                        Layout.margins: 20
                                    }
                                }
                            }

                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: 80
                        Layout.fillWidth: true
                        width: treat_biological_col.width + 20
                        color: "white"
                        radius: 10

                        ColumnLayout {
                            id: treat_biological_col
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                Text {
                                    text: qsTr("Traitement biologique")
                                    font.pixelSize: 16
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                IconImage {
                                    source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                    width: 25
                                    height: 25
                                    color: Theme.colorPrimary
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignHCenter
                                Repeater {
                                    model: details['treatment']['biological']
                                    delegate: Text {
                                        required property int index
                                        required property variant modelData
                                        text: '- ' + modelData
                                        font.pixelSize: 14
                                        Layout.margins: 20
                                    }
                                }
                            }

                        }
                    }

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
