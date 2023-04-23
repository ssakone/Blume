import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
import "../components"
import "../components_generic"

Page {
    header: AppBar {
        title: "Demander à un botaniste"
    }

    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            id: head
            Layout.preferredHeight: 120
            Layout.fillWidth: true
            color: Theme.colorPrimary

            ColumnLayout {
                anchors.fill: parent

                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Label {
                    text: "Vous receverez un diagnostic et un plan de soin dans les trois jours après avoire rempli ce formulaire"
                    color: "white"
                    font.pixelSize: 16
                    font.weight: Font.Light
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: colHeadFaqForm.height
            topMargin: -60

            Column {
                id: colHeadFaqForm
                width: parent.width

                Rectangle {
                    width: parent.width
                    height: insideCol2.height
                    color: "white"
                    radius: 50

                    Column {
                        id: insideCol2
                        width: parent.width
                        padding: width < 500 ? 10 : width / 11
                        topPadding: 30
                        bottomPadding: 70

                        spacing: 30

                        Column {
                            width: parent.width
                            spacing: 10
                            Label {
                                text: "Ajouter des images"
                                font {
                                    pixelSize: 16
                                    weight: Font.Bold
                                }

                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Label {
                                text: "Photographiez la plante entière ainsi que les parties qui semblent malades"
                                font.weight: Font.Light
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 10
                                Item {
                                    Layout.fillWidth: true
                                }

                                Repeater {
                                    model: 4
                                    ImagePickerArea {
                                        width: 70
                                        height: 70
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Column {
                            width: parent.width - (2*parent.padding)
                            spacing: 15

                            Label {
                                text: "Décrivez le problème"
                                font {
                                    pixelSize: 16
                                    weight: Font.Bold
                                }

                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            TextArea {
                                width: parent.width
                                height: 120
                                padding: 7
                                topPadding: 10
                                font {
                                    pixelSize: 14
                                    weight: Font.Light
                                }
                                wrapMode: Text.Wrap
//                                clip: true
                                background: Rectangle {
                                    color: "#f5f5f5"
                                    radius: 15
                                    border {
                                        width: 1
                                        color: "#ccc"
                                    }
                                }
                            }

                        }

                        Repeater {
                            model: form_schema
                            delegate: Column {
                                required property variant modelData

                                width: parent.width - (2*parent.padding)
                                spacing: 15

                                Row {
                                    width: parent.width
                                    spacing: 10

                                    IconSvg {
                                        source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                                        width: 30
                                        height: 30
                                        color: Theme.colorPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Label {
                                        text: modelData.group_title
                                        font {
                                            pixelSize: 13
                                            weight: Font.Bold
                                            capitalization: Font.AllUppercase
                                        }
                                        color: Theme.colorPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        wrapMode: Text.Wrap
                                    }
                                }

                                Repeater {
                                    model: modelData.fields
                                    delegate: Column {
                                        required property variant modelData
                                        width: parent.width
                                        spacing: 7
                                        Label {
                                            text: (modelData.is_required ? "* " : "")
                                                  + modelData.label
                                            font {
                                                pixelSize: 16
                                                weight: Font.Bold
                                            }
                                            width: parent.width
                                            wrapMode: Text.Wrap
                                        }

                                        TextField {
                                            id: textInput
                                            placeholderText: modelData?.placeholder
                                            padding: 5

                                            width: parent.width
                                            height: 50

                                            verticalAlignment: Text.AlignVCenter

                                            font {
                                                pixelSize: 14
                                                weight: Font.Light
                                            }

                                            background: Rectangle {
                                                radius: 15
                                                color: "#f5f5f5"
                                                border {
                                                    color: "#ccc"
                                                    width: 1
                                                }
                                            }
                                        }

                                    }
                                }
                            }
                        }

                        Item {
                            height: 70
                        }
                    }
                }
            }
        }
    }
}
