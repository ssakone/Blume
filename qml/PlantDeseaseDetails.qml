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

            ScrollView {
//                width: resultDeseaseDetailPop.width
                height: resultDeseaseDetailPop.height

                ScrollView {
//                    width: resultDeseaseDetailPop.width
                    height: resultDeseaseDetailPop.height - 65
                    leftPadding: 10
                    rightPadding: 10

                    ColumnLayout {
                        spacing: 10

                        Rectangle {
                            height: resultDeseaseDetailPop.height / 3
                             width: resultDeseaseDetailPop.width
        //                    Layout.fillWidth: true
                            clip: true
                            Image {
                                source: desease_data['similar_images'][0]['url']
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        ColumnLayout {
                            spacing: 3
                            Label {
                                text: desease_data['name']
                                font.pixelSize: 28
                                color: "white"
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
                            wrapMode: Text.Wrap
                            Layout.maximumWidth: resultDeseaseDetailPop.width - 40
                        }

                        Label {
                            text: "Cause"
                            font.pixelSize: 24
                        }


                        ColumnLayout {
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            Layout.bottomMargin: 20

                            Rectangle {
                                Layout.preferredHeight: 50
                                width: resultDeseaseDetailPop.width - 40
                                color: "white"
                                radius: 10

                                Text {
                                    text: details['cause'] || "Inconnue"
                                    font.pixelSize: 14
                                    color: Material.color(Material.Grey, Material.Shade800)

                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: 20
                                }
                            }
                        }

                        Label {
                            text: "Traitements"
                            font.pixelSize: 24
                        }


                        ColumnLayout {
                            id: treatment_col
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20

                            spacing: 5
                            Rectangle {
                                Layout.preferredHeight: treat_prevention_col.height
                                width: resultDeseaseDetailPop.width - 40
                                radius: 10

                                ColumnLayout {
                                    id: treat_prevention_col
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    RowLayout {
                                        Layout.alignment: Qt.AlignLeft
                                        IconImage {
                                            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                            width: 25
                                            height: 25
                                            color: Theme.colorPrimary
                                        }
                                        Text {
                                            text: qsTr("Prévention")
                                            font.pixelSize: 16
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 2
                                        Repeater {
                                            model: details['treatment']['prevention']
                                            delegate: Text {
                                                required property int index
                                                required property variant modelData
                                                text: '  - ' + modelData
                                                color: Material.color(Material.Grey, Material.Shade800)
                                                font.pixelSize: 14
                                                wrapMode: Text.Wrap
                                                Layout.maximumWidth: treat_prevention_col.parent.width - 10
                                                Layout.bottomMargin: 10
                                                Layout.leftMargin: 5
                                            }
                                        }
                                    }

                                }
                            }
                            Rectangle {
                                Layout.preferredHeight: treat_chemical_col.height
                                width: resultDeseaseDetailPop.width - 40
                                radius: 10

                                ColumnLayout {
                                    id: treat_chemical_col
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    RowLayout {
                                        Layout.alignment: Qt.AlignLeft
                                        IconImage {
                                            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                            width: 25
                                            height: 25
                                            color: Theme.colorPrimary
                                        }
                                        Text {
                                            text: qsTr("Traitement chimique")
                                            font.pixelSize: 16
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 2
                                        Repeater {
                                            model: details['treatment']['chemical']
                                            delegate: Text {
                                                required property int index
                                                required property variant modelData
                                                text: '  - ' + modelData
                                                color: Material.color(Material.Grey, Material.Shade800)
                                                font.pixelSize: 14
                                                wrapMode: Text.Wrap
                                                Layout.maximumWidth: treat_prevention_col.parent.width - 10
                                                Layout.bottomMargin: 10
                                                Layout.leftMargin: 5
                                            }
                                        }
                                    }

                                }
                            }

                            Rectangle {
                                Layout.preferredHeight: treat_prevention_col.height
                                width: resultDeseaseDetailPop.width - 40
                                radius: 10

                                ColumnLayout {
                                    id: treat_biological_col
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    RowLayout {
                                        Layout.alignment: Qt.AlignLeft
                                        IconImage {
                                            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                            width: 25
                                            height: 25
                                            color: Theme.colorPrimary
                                        }
                                        Text {
                                            text: qsTr("Traitement biologique")
                                            font.pixelSize: 16
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 2
                                        Repeater {
                                            model: details['treatment']['biological']
                                            delegate: Text {
                                                required property int index
                                                required property variant modelData
                                                text: '  - ' + modelData
                                                color: Material.color(Material.Grey, Material.Shade800)
                                                font.pixelSize: 14
                                                wrapMode: Text.Wrap
                                                Layout.maximumWidth: treat_biological_col.parent.width - 10
                                                Layout.bottomMargin: 10
                                                Layout.leftMargin: 5
                                            }
                                        }
                                    }

                                }
                            }
                        }





                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
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

        }



}
