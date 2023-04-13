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
    property bool header_hidden: false

    parent: appWindow
    width: appWindow.width
    height: appWindow.height
    padding: 0

    background: Rectangle {
        color: "white"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        Rectangle {
            visible: !header_hidden
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


        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Rectangle {
                    height: resultDeseaseDetailPop.height / 3
                    width: resultDeseaseDetailPop.width
                    clip: true
                    color: "#f0f0f0"
                    Image {
                        source: desease_data['similar_images'][0]['url']
                        fillMode: Image.PreserveAspectCrop
                        anchors.fill: parent
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    spacing: 10

                    ColumnLayout {
                        spacing: 3
                        Label {
                            text: desease_data['name']
                            font.pixelSize: 32
                            font.weight: Font.Bold
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
                        wrapMode: Text.Wrap
                        Layout.maximumWidth: resultDeseaseDetailPop.width - 40
                    }

                    Label {
                        text: "Cause"
                        color: Theme.colorPrimary
                        font.pixelSize: 24
                        textFormat: Text.MarkdownText
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: text_cause.implicitHeight + 15
                        Layout.rightMargin: 20
                        Layout.bottomMargin: 20
                        color: "#f0f0f0"
                        radius: 10

                        TextEdit {
                            id: text_cause
                            text: details['cause'] || "Inconnue"
                            readOnly: true
                            font.pixelSize: 14
                            color: Material.color(Material.Grey, Material.Shade800)

                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: Text.Wrap
                            textFormat: Text.MarkdownText
                            textMargin: 10
                        }
                    }

                    Label {
                        text: "Traitements"
                        font.pixelSize: 24
                        color: Theme.colorPrimary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        Repeater {
                            model: [
                                {
                                    label: 'Traitement préventif',
                                    field: 'prevention'
                                },
                                {
                                    label: 'Traitement chimique',
                                    field: 'chemical'
                                },
                                {
                                    label: 'Traitement biologique',
                                    field: 'biological'
                                },
                            ]

                            Rectangle {
                                required property variant modelData
                                Layout.preferredHeight: treat_prevention_col.height
                                width: resultDeseaseDetailPop.width - 40
                                radius: 10
                                color: "#f0f0f0f0"

                                ColumnLayout {
                                    id: treat_prevention_col
                                    width: parent.width

                                    Item {
                                        Layout.preferredHeight: 10
                                    }

                                    RowLayout {
                                        Layout.alignment: Qt.AlignLeft
                                        IconImage {
                                            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                            width: 25
                                            height: 25
                                            color: Theme.colorPrimary
                                        }
                                        Text {
                                            text: qsTr(modelData.label)
                                            font.pixelSize: 16
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    TextEdit {
                                        text: (details['treatment'] && typeof details['treatment'][modelData.field] === 'string') ? details['treatment'][modelData.field] : ""
                                        textFormat: TextEdit.MarkdownText
                                        readOnly: true
                                        color: Material.color(Material.Grey, Material.Shade900)
                                        font.pixelSize: 14
                                        font.weight: Font.Light
                                        wrapMode: Text.Wrap
                                        textMargin: 10
                                        Layout.fillWidth: true

                                    }

                                    ColumnLayout {
                                        spacing: 2
                                        visible: (details['treatment'] && typeof details['treatment'][modelData.field]) === 'object'
                                        Repeater {
                                            model: details['treatment'][modelData.field]
                                            delegate: Text {
                                                required property int index
                                                required property variant modelData
                                                text: qsTr(modelData)
                                                color: Material.color(Material.Grey, Material.Shade900)
                                                font.pixelSize: 14
                                                font.weight: Font.Light
                                                wrapMode: Text.Wrap
                                                Layout.maximumWidth: treat_prevention_col.parent.width - 10
                                                Layout.bottomMargin: 10
                                                Layout.leftMargin: 5
                                            }
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
                        Layout.minimumHeight: 70
                        Layout.fillWidth: true
                    }
                }

            }

        }

    }



}
