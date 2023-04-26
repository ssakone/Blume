import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    id: control
    header: AppBar {
        title: "Mon Jardin"
        titleLabel.horizontalAlignment: Text.AlignHCenter
        titleLabel.rightPadding: 60
        titleLabel.font {
            pixelSize: 18
            weight: Font.Medium
        }

        leading.icon: Icons.chevronLeft
        leading.iconSize: 36

        backgroundColor: "white"
        foregroundColor: "black"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 20

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10

            Repeater {
                model: [{
                        "icon": Icons.flowerTulip,
                        "title": "Mes plantes",
                        "action": "plants"
                    }, {
                        "icon": Icons.selectPlace,
                        "title": "Mes espaces",
                        "action": "spaces"
                    }, {
                        "icon": Icons.alarm,
                        "title": "Alarme",
                        "action": "alarm"
                    }]
                delegate: Rectangle {
                    Layout.preferredHeight: 80
                    Layout.fillWidth: true
                    color: "#ccc"
                    radius: 15
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        IconSvg {
                            source: modelData.icon
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        Label {
                            text: modelData.title
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            switch (modelData.action) {
                            case "plants":
                                page_view.push(navigator.gardenPlantsList)
                                break
                            case "spaces":
                                page_view.push(navigator.gardenSpacesList)
                                break
                            }
                        }
                    }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _insideColumn.height
            clip: true

            Column {
                id: _insideColumn
                width: parent.width
                padding: 15
                spacing: 10

                ColumnLayout {
                    width: parent.width - 30

                    Repeater {
                        model: 10
                        GardenActivityLine {
                            title: "Arrosage"
                            subtitle: "3 plantes"
                            time_inline: false
                            onClicked: console.log("Clicked")
                            icon.source: Icons.water
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                        }
                    }
                }
            }
        }
    }
}
