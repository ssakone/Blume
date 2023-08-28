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
import PosometreCalculator

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import "../components"
import "../components_generic"

BPage {
    id: posometrePop
    padding: 0

    header: AppBar {
        title: qsTr("Light sensor")
    }
    background: Rectangle {
        color: $Colors.colorSecondary
    }

    AmbientLightSensor {
        id: als
    }

    Component.onCompleted: {
        switch (Qt.platform.os) {
        case "android":
            als.start()
            break
        case "ios":
            cameraLoader.active = true
            cameraLoader.item.camera.start()
            posometreTimer.start()
            break
        default:
            als.start()
        }
    }
    function start() {
        videoOutput1.grabToImage(image => p_camera.getGamma(image))
    }

    property variant sensor: als.reading

    //    background: Rectangle {
    //        color: Theme.colorPrimary
    //        radius: 0
    //    }
    Timer {
        id: timer2
        repeat: true
        running: false
        interval: 600
        onTriggered: posometrePop.start()
    }

    Timer {
        id: posometreTimer
        interval: 600
        running: false
        onTriggered: {
            timer2.start()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Column {
            Layout.fillWidth: true
            Label {
                text: qsTr("Farmers can use a light meter to measure the amount of light available to plants to adjust their location or light exposure to maximize growth and production.")
                font.pixelSize: 18
                color: "white"
                width: parent.width - 25
                padding: 12
                wrapMode: Label.Wrap
            }
        }

        Rectangle {
            id: indicatorRect

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            color: $Colors.colorSecondary
            clip: true

            ColorImage {
                source: "qrc:/assets/img/bg_plant.svg"
                anchors.fill: parent
                color: $Colors.colorPrimary
                opacity: 0.3
            }

            Rectangle {
                id: gl
                width: 60
                height: parent.height - 40
                radius: width / 2
                anchors.centerIn: parent
                clip: true
                color: "#e8e8e8"
                layer.enabled: true
                layer.effect: Glow {
                    color: 'white'
                    radius: ((sensor?.lightLevel ?? 0) * 16) / 6
                    Behavior on radius {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
                Item {
                    id: root
                    property real value: 0.0
                    property real radius: width / 2
                    anchors.bottom: parent.bottom
                    width: 60
                    height: ((sensor?.lightLevel ?? 0) * gl.height) / 6

                    Behavior on height {
                        SmoothedAnimation {}
                    }

                    Rectangle {
                        width: 60
                        height: gl.height
                        radius: width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        clip: true
                        opacity: 6
                        y: parent.height - gl.height
                        visible: true
                        border.width: 2
                        border.color: "gray"
                        gradient: Gradient {
                            GradientStop {
                                position: 0.4
                                color: "yellow"
                            }
                            GradientStop {
                                position: 1
                                color: "teal"
                            }
                        }
                    }
                    layer.enabled: radius > 0
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: root.width
                            height: root.height
                            radius: root.radius
                        }
                    }
                }
            }
            ListView {
                id: indicatorBar
                height: parent.height - 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 40
                anchors.right: gl.right
                width: parent.width / 2.4
                model: indicator_model
                anchors.bottom: parent.bottom
                interactive: false
                clip: true
                opacity: .9

                delegate: Item {
                    id: indicatorLevel
                    required property string label
                    required property int level
                    required property color l_color
                    required property color textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: indicatorBar.width - 2
                    height: gl.height / 6

                    Label {
                        text: label
                        color: "white"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        height: 1
                        width: parent.width
                        color: "#cecece"
                        anchors.bottom: parent.bottom
                    }
                }
            }
            VideoOutput {
                id: videoOutput1
                x: 10000
                y: 10000
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectCrop
            }

            Loader {
                id: cameraLoader
                width: 1
                height: 1
                active: Qt.platform.os === "ios"
                sourceComponent: Component {
                    CaptureSession {
                        Component.onCompleted: camera.start()
                        camera: Camera {
                            id: camera
                        }
                        videoOutput: videoOutput1
                    }
                }
            }
        }
    }

    PosometreCamera {
        id: p_camera
        onLighnessValue: function (value) {
            sensor = {
                "lightLevel": value
            }
        }
    }

    ListModel {
        id: indicator_model
        ListElement {
            level: 5
            l_color: "red"
            textColor: 'white'
            label: qsTr("Sunny")
        }
        ListElement {
            level: 4
            l_color: "yellow"
            textColor: 'black'
            label: qsTr("Very bright")
        }
        ListElement {
            level: 3
            l_color: "orange"
            textColor: 'black'
            label: qsTr("Luminous")
        }
        ListElement {
            level: 2
            l_color: "white"
            textColor: 'black'
            label: qsTr("Normal")
        }
        ListElement {
            level: 1
            l_color: "gray"
            textColor: 'black'
            label: qsTr("Dark")
        }
    }
}
