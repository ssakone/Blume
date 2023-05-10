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
import "../../"
import "../../components/"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    id: pageControl
    property variant desease_data
    property variant details: desease_data["disease_details"] ?? {}
    property bool header_hidden: false

    padding: 0

    header: AppBar {
        title: desease_data.name ?? ""
    }

    Flickable {
        anchors.fill: parent
        contentHeight: _insideColumn.height

        Column {
            id: _insideColumn
            width: parent.width
            spacing: 10

            Rectangle {
                height: singleColumn ? 300 : pageControl.height / 3
                width: parent.width
                clip: true
                color: "#f0f0f0"

                SwipeView {
                    id: imageSwipeView
                    anchors.fill: parent
                    Repeater {
                        model: desease_data['similar_images']
                        delegate: Image {
                            source: modelData.url || modelData || ""
                        }
                    }
                }

                PageIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    currentIndex: imageSwipeView.currentIndex
                    count: 3
                }
            }

            Column {
                width: parent.width
                padding: 10
                topPadding: 0
                spacing: 10

                Column {
                    spacing: 3
                    width: parent.width
                    Label {
                        text: desease_data['name']
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        width: parent.width
                        wrapMode: Text.Wrap
                    }

                    RowLayout {
                        width: parent.width
                        Repeater {
                            model: details['common_names']
                            delegate: Label {
                                required property int index
                                required property variant modelData

                                text: (modelData?.name ?? modelData)
                                      + (index < details['common_names'].length ? ", " : "")
                            }
                        }
                    }
                }

                Text {
                    text: details['description']
                    font.pixelSize: 14
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    width: parent.width - 10
                }

                Label {
                    text: "Cause"
                    color: Theme.colorPrimary
                    font.pixelSize: 24
                    textFormat: Text.MarkdownText
                }

                Rectangle {
                    width: parent.width - 30
                    height: text_cause.implicitHeight + 15
                    color: "#f0f0f0"
                    radius: 10
                    anchors.horizontalCenter: parent.horizontalCenter

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

                Column {
                    width: parent.width - 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Repeater {
                        model: [{
                                "label": 'Traitement préventif',
                                "field": 'prevention'
                            }, {
                                "label": 'Traitement chimique',
                                "field": 'chemical'
                            }, {
                                "label": 'Traitement biologique',
                                "field": 'biological'
                            }]

                        Rectangle {
                            required property variant modelData
                            height: treat_prevention_col.height
                            width: parent.width - 10
                            radius: 10
                            color: "#f0f0f0f0"
                            anchors.horizontalCenter: parent.horizontalCenter

                            Column {
                                id: treat_prevention_col
                                width: parent.width
                                padding: 10

                                Row {
                                    width: parent.width
                                    spacing: 10
                                    IconImage {
                                        source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                        width: 25
                                        height: 25
                                        color: Theme.colorPrimary
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Text {
                                        text: qsTr(modelData.label)
                                        font.pixelSize: 16
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Label {
                                    text: (details['treatment']
                                           && typeof details['treatment'][modelData.field]
                                           === 'string') ? details['treatment'][modelData.field] : ""
                                    textFormat: Label.MarkdownText
                                    color: Material.color(Material.Grey,
                                                          Material.Shade900)
                                    font.pixelSize: 14
                                    font.weight: Font.Light
                                    wrapMode: Text.Wrap
                                    width: parent.width - 10
                                    padding: 10
                                }

                                Column {
                                    spacing: 2
                                    width: parent.width
                                    padding: 10
                                    leftPadding: 0
                                    visible: (details['treatment']
                                              && typeof details['treatment'][modelData.field])
                                             === 'object'
                                    Repeater {
                                        model: details['treatment'][modelData.field]
                                        delegate: Label {
                                            required property int index
                                            required property variant modelData
                                            text: qsTr(modelData)
                                            color: Material.color(
                                                       Material.Grey,
                                                       Material.Shade900)
                                            font.pixelSize: 14
                                            font.weight: Font.Light
                                            wrapMode: Text.Wrap
                                            width: parent.width - 10
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                NiceButton {
                    text: "Plus d'informations sur Wikipédia"
                    icon.source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                    height: 55
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        Qt.openUrlExternally(details['url'])
                    }
                }
            }
        }
    }
}
