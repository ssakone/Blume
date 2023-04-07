import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtSensors
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform
import "components"

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Popup {
    id: posometrePop
    width: parent.width - 20
    height: width + 50
    anchors.centerIn: parent
    dim: true
    modal: true
    onOpened: als.start()
    onClosed: als.stop()

    property variant sensor: als.reading
    property int indicator_height: 35 //(width / indicator_total_levels) - 100
    property int indicator_width: 100
    property real averageBrightness: 0.0

    background: Rectangle {
        color: Theme.colorPrimary
        radius: 20
    }

    ListModel {
        id: indicator_model
        ListElement { level: 5; l_color: "red"; textColor: 'white'; label: "Ensolleilé" }
        ListElement { level: 4; l_color: "yellow"; textColor: 'black'; label: "Très lumineux"  }
        ListElement { level: 3; l_color: "orange"; textColor: 'black'; label: "Lumineux"  }
        ListElement { level: 2; l_color: "white"; textColor: 'black'; label: "Normal"  }
        ListElement { level: 1; l_color: "gray"; textColor: 'black'; label: "Sombre" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Column {
            Layout.alignment: Qt.AlignHCenter
            IconSvg {
                width: 64
                height: 64
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/assets/icons_custom/posometre.svg"
                color: 'black'
            }

            Label {
                text: "Posometre"
                anchors.horizontalCenter: parent.horizontalCenter
                font.weight: Font.Medium
            }
        }

        Rectangle {
            id: indicatorRect

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            color: "white"
            border.color: 'gray'
            radius: 20
            clip: true

            ListView {
                id: indicatorBar
                height: parent.height
                width: parent.width
                model: indicator_model
                anchors.bottom: parent.bottom
                interactive: false
                clip: true

                delegate: Rectangle {
                    id: indicatorLevel
                    required property string label
                    required property int level
                    required property color l_color
                    required property color textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: indicatorBar.width - 2
                    height: Math.min((indicatorRect.height / indicator_model.count), 50) + 1
                    //Layout.fillWidth: true //
                    visible: sensor != null  && level <= sensor.lightLevel
                    color: (sensor != null  && level <= sensor.lightLevel) ? l_color : Qt.rgba(0, 0, 0, 0)
                    radius: 0
                    ColorImage {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 15
                        source: Icons.torch
                        color: textColor
                        visible: level === sensor.lightLevel
                    }

                    Text {
                        text: label
                        color: textColor
                        Layout.alignment: Qt.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                    }

                    Rectangle {
                        height: 1
                        width: parent.width
                        color: "white"
                        anchors.bottom: parent.bottom
                    }
                }
            }
        }


//        Label {
//            id: alsV
//            anchors.horizontalCenter: parent.horizontalCenter
//            wrapMode: Label.WordWrap
////            width: parent.width - 20
//            horizontalAlignment: Label.AlignHCenter
//            text: {
//                if (als.reading != null){
//                   console.log(JSON.stringify(als.reading))
//                    switch (als.reading.lightLevel) {
//                        case 0:
//                            return "Niveau inconnue"
//                        case 1:
//                            return "Sombre"
//                        case 2:
//                            return "Peu Sombre"
//                        case 3:
//                            return "Lumineux"
//                        case 4:
//                            return "Tres lumineux"
//                        case 5:
//                            return "Ensolleille"
//                    }
//                }
//                return "Information sensor indisponible"
//            }

//            font.pixelSize: 44
//        }
        AmbientLightSensor {
            id: als
        }
    }
}
