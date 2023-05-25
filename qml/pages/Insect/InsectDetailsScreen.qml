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
    id: root
    required property variant insect_data
    property variant details: insect_data["details"]
    property bool fullScreen: false

    onFullScreenChanged: {
        if(fullScreen) fullScreenPop.close()
        else fullScreenPop.open()
    }

    header: AppBar {
        title: insect_data['name']
    }

    FullScreenPopup {
        id: fullScreenPop
        onSwithMode: fullScreen = !fullScreen
        source: details['image']['value'] || ""
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _insideCol1.height
            clip: true

            Column {
                id: _insideCol1
                width: parent.width

                Rectangle {
                    height: root.height / 3
                    width: parent.width
                    clip: true
                    color: "#e5e5e5"
                    Image {
                        anchors.fill: parent
                        source: details['image']['value'] || ""
                        fillMode: Image.PreserveAspectCrop
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: fullScreen = !fullScreen
                    }
                }
                Column {
                    width: parent.width - 20
                    spacing: 15

                    Column {
                        width: parent.width
                        spacing: 15
                        padding: 10

                        ColumnLayout {
                            width: parent.width
                            spacing: 3
                            Label {
                                text: insect_data['name']
                                font.pixelSize: 28
                                color: Theme.colorPrimary
                                font.weight: Font.DemiBold
                                width: parent.width
                                wrapMode: Text.Wrap
                            }

                            Row {
                                Layout.fillWidth: true

                                Repeater {
                                    model: details['common_names']
                                    delegate: Label {
                                        required property int index
                                        required property variant modelData

                                        text: modelData
                                              + (index < details['common_names'].length ? ", " : "")
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            width: parent.width

                            Repeater {
                                model: Object.keys(details['taxonomy'])
                                delegate: TableLine {
                                    required property string modelData
                                    required property int index
                                    color: index % 2 ? "#e4f0ea" : "#edeff2"
                                    title: qsTr(modelData.toLocaleUpperCase())
                                    description: details['taxonomy'][modelData]?.toLocaleUpperCase(
                                                     ) || ""
                                }
                            }
                        }

                        Label {
                            text: details['description']['value']
                            wrapMode: Text.Wrap
                            width: parent.width
                            font {
                                weight: Font.Light
                                pixelSize: 16
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: root.height / 2

                            color: "#f0f0f0"
                            radius: 10
                            clip: true

                            Label {
                                text: qsTr("No image available")
                                font.pixelSize: 22
                                anchors.centerIn: parent
                                visible: details['images'].length === 0
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 5

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

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
                                            model: details['images']
                                            delegate: Image {
                                                required property var modelData
                                                source: modelData['value'] || ""
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
                                        model: details['images']
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

                        ButtonWireframeIcon {
                            text: qsTr("More informations on Wikipédia")
                            fullColor: true
                            fulltextColor: "white"
                            primaryColor: Theme.colorPrimary
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
}
