import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import QtQuick.Shapes

import Qt5Compat.GraphicalEffects as QGE

import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    id: control
    header: AppBar {// backgroundColor: "transparent"
        // foregroundColor: "black"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            Rectangle {
                width: parent.width
                height: parent.height
                color: Theme.colorPrimary
            }

            Column {
                Layout.fillWidth: true
                padding: 25
                topPadding: 5
                Label {
                    text: qsTr("Mon Jardin")
                    font {
                        pixelSize: 36
                        family: "Courrier"
                        weight: Font.Bold
                    }
                }
                Label {
                    text: qsTr("Gerer votre jardin personnelle efficacement")
                    opacity: .5
                    font {
                        pixelSize: 16
                        family: "Courrier"
                        weight: Font.Bold
                    }
                }
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 60
                    spacing: 20
                    topPadding: 20
                    Label {
                        text: $Model.plant.count
                        font.pixelSize: 36
                        font.weight: Font.Medium
                        font.family: 'Roboto'
                        width: parent.width
                        horizontalAlignment: Label.AlignHCenter
                    }
                    Label {
                        text: "Nombre de plante(s)"
                        font.pixelSize: 14
                        font.weight: Font.Normal
                        font.family: 'Roboto'
                        opacity: .7
                        width: parent.width
                        horizontalAlignment: Label.AlignHCenter
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 20
            spacing: 20
            visible: false

            Repeater {
                model: [{
                        "icon": Icons.flowerTulip,
                        "title": "Mes plantes",
                        "action": "plants"
                    }, {
                        "icon": Icons.viewDashboardOutline,
                        "title": "Mes espaces",
                        "action": "spaces"
                    }, {
                        "icon": Icons.alarm,
                        "title": "Alarme",
                        "action": "alarm"
                    }]
                delegate: Rectangle {
                    id: _insideControl
                    property string foregroundColor: {
                        switch (modelData.action) {
                        case "alarm":
                            return $Colors.brown600
                        case "spaces":
                            return $Colors.cyan600
                        case "plants":
                            return $Colors.green600
                        }
                    }
                    Layout.preferredHeight: 100
                    Layout.fillWidth: true
                    radius: 2
                    layer.enabled: true
                    layer.effect: QGE.DropShadow {
                        radius: 4
                        color: $Colors.gray300
                        verticalOffset: 2
                    }
                    Rectangle {
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        color: _insideControl.foregroundColor
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutCubic
                        }
                    }

                    scale: _insideMouse.containsMouse
                           || _insideMouse.containsPress ? 1.05 : 1

                    color: _insideMouse.containsMouse
                           || _insideMouse.containsPress ? "white" : foregroundColor
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Item {
                            ColorImage {
                                anchors.centerIn: parent
                                width: 42
                                height: 42
                                source: modelData.icon
                                color: _insideMouse.containsMouse
                                       || _insideMouse.containsPress ? _insideControl.foregroundColor : $Colors.white
                            }
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        Label {
                            text: modelData.title
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: _insideMouse.containsMouse
                                   || _insideMouse.containsPress ? _insideControl.foregroundColor : $Colors.white
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    MouseArea {
                        id: _insideMouse
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"
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

        Label {
            padding: 10
            text: "Vos espaces"
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        ListView {
            id: activityList
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 15
            clip: true
            model: $Model.space
            delegate: GardenSpaceLine {
                width: parent.width
                height: 85
                title: libelle
                subtitle: description
                iconSource: type === 1 ? Icons.homeOutline : Icons.landFields
                onClicked: {
                    let data = {
                        "name": libelle,
                        "type": type,
                        "description": description,
                        "status": model.status ?? 0,
                        "space_id": id
                    }
                    page_view.push(navigator.gardenSpaceDetails, data)
                }
            }
        }
    }
}
