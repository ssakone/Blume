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
    header: AppBar {
        title: "Blume"
        isHomeScreen: true
    }
    footer: BottomTabBar {}

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 0

        Column {
            Layout.fillWidth: true
            padding: 25
            topPadding: 5
            Label {
                text: qsTr("My Garden")
                font {
                    pixelSize: 36
                    family: "Courrier"
                    weight: Font.Bold
                }
            }
            Label {
                text: qsTr("Manage your personal garden efficiently")
                opacity: .5
                font {
                    pixelSize: 16
                    family: "Courrier"
                    weight: Font.Bold
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 20
            spacing: 20

            Repeater {
                model: [{
                        "icon": Icons.flowerTulip,
                        "title": qsTr("My plants"),
                        "action": "plants"
                    }, {
                        "icon": Icons.viewDashboardOutline,
                        "title": qsTr("Rooms"),
                        "action": "spaces"
                    }, {
                        "icon": Icons.alarm,
                        "title": qsTr("History"),
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
            Layout.fillWidth: true
            text: qsTr("Pending tasks")
            padding: 15
            opacity: .7
            font {
                pixelSize: 16
                weight: Font.Medium
            }
        }

        ListView {
            id: activityList
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            spacing: 15
            clip: true
            model: 2
            delegate: GardenActivityLine {
                title: qsTr("Watering")
                subtitle: "3 plante"
                onClicked: console.log("Clicked")
                icon.source: Icons.water
                width: activityList.width
                height: 80
            }
        }
    }
}
