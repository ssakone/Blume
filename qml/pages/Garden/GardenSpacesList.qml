import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../../components"
import "../../components_generic"

BPage {
    id: control
    header: AppBar {
        title: "Mes espaces"
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
                spacing: 10

                ColumnLayout {
                    width: parent.width - 30
                    spacing: 20

                    SearchBar {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 10

                        Repeater {
                            model: ["Cuisine", "Salon", "Terasse"]
                            GardenSpaceLine {
                                width: parent.width
                                height: 80
                                title: modelData
                                subtitle: "Plante carnivore. Faire très attention. D'accord les gars ?"
                                iconSource: Icons.roomServiceOutline
                            }

                        }


                    }
                }
            }

        }

    }

    ButtonWireframe {
        height: 60
        width: 60
        fullColor: Theme.colorPrimary
        componentRadius: 30
        anchors {
            bottom: parent.bottom
            bottomMargin: 30

            right: parent.right
            rightMargin: 20
        }

        Text {
            text: "+"
            color: "white"
            font.pixelSize: 32
            anchors.centerIn: parent
        }
    }


}
