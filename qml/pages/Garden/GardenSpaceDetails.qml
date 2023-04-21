import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../../components"
import "../../components_generic"

BPage {
    id: control
    property string space_name: ""
    required property int space_id

    header: AppBar {
        title: "Espace - " + control.space_name
    }


    ColumnLayout {
        anchors.fill: parent

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _insideColumn.height

            Column {
                id: _insideColumn
                width: parent.width
                padding: 15
                topPadding: 25
                spacing: 10

                ColumnLayout {
                    width: parent.width - 30
                    spacing: 20

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        Repeater {
                            model: [{
                                    name: "Plante",
                                    count: 1
                                },
                                {
                                    name: "Alarme",
                                    count: 2
                                }]
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                color: "#e5e5e5"
                                radius: 15

                                Column {
                                    anchors.fill: parent
                                    padding: 20
                                    Label {
                                        text: modelData.count
                                        font {
                                            pixelSize: 32
                                            weight: Font.Bold
                                        }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Label {
                                        text: modelData.name + (modelData.count > 1 ? "s" : "")
                                        font {
                                            pixelSize: 32
                                            weight: Font.Bold
                                        }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }

                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 10
                        leftPadding: 10
                        rightPadding: 10

                        RowLayout {
                            width: parent.width - 20
                            Label {
                                text: "Liste des plantes"
                                Layout.fillWidth: true
                            }
                            Item {
                                Layout.fillWidth: true
                            }

                            ButtonWireframe {
                                text: "Ajouter"
                                Layout.fillWidth: true
                                componentRadius: 20
                                fullColor: Theme.colorPrimary
                                fulltextColor: "white"
                                leftPadding: 10
                                rightPadding: leftPadding
                            }
                        }

                        Repeater {
                            model: ["Aloe", "Vera", "Orchidée"]
                            GardenPlantLine {
                                width: parent.width - 20
                                title: modelData
                                subtitle: "Plante carnivore. Faire très attention. "
                                roomName: "Salon"
                                imageSource: "qrc:/assets/img/orchidee.jpg"
                            }

                        }
                    }



                    Column {
                        Layout.fillWidth: true
                        spacing: 10
                        leftPadding: 10
                        rightPadding: 10

                        RowLayout {
                            width: parent.width - 20
                            Label {
                                text: "Liste des plantes"
                                Layout.fillWidth: true
                            }
                            Item {
                                Layout.fillWidth: true
                            }

                            ButtonWireframe {
                                text: "Ajouter"
                                Layout.fillWidth: true
                                componentRadius: 20
                                fullColor: Theme.colorPrimary
                                fulltextColor: "white"
                                leftPadding: 10
                                rightPadding: leftPadding
                            }
                        }

                        Repeater {
                            model: ["Arrosage", "Rampotage"]
                            GardenActivityLine {
                                title: modelData
                                subtitle: "3 plantes"
                                onClicked: console.log("Clicked")
                                icon.source: Icons.water
                                width: parent.width - 20
                                height: 70
                            }

                        }
                    }
                }


            }

        }

    }


}
