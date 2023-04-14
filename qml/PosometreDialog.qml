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
import "components"

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Popup {
    id: posometrePop
    width: appWindow.width
    height: appWindow.height
    parent: appWindow.contentItem
    padding: 0
    dim: true
    modal: true
    onOpened: switch (Qt.platform.os) {
              case "android":
                  als.start()
                  break;
              case "ios":
                  cameraLoader.active = true
                  cameraLoader.item.camera.start()
                  posometreTimer.start()
                  break;
              }

    function start() {
        videoOutput1.grabToImage(image => p_camera.getGamma(image))
    }

    onClosed: {
        switch (Qt.platform.os) {
          case "android":
              als.stop()
              break
          case "ios":
              timer2.stop()
              break
          }

    }

    property variant sensor: als.reading

    background: Rectangle {
        color: Theme.colorPrimary
        radius: 0
    }

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

    Page {
        anchors.fill: parent
        header: Rectangle {
            height: Qt.platform.os == 'ios' ? 90 : 65
            color: "#00c395"
            ColorImage {
                source: Icons.arrowLeft
                sourceSize.width: 28
                sourceSize.height: 28
                anchors.verticalCenterOffset: Qt.platform.os == 'ios' ? 15 : 0
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                x: 15
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        posometrePop.close()
                    }
                }
            }

            Label {
                anchors.verticalCenterOffset: Qt.platform.os == 'ios' ? 15 : 0
                anchors.verticalCenter: parent.verticalCenter
                text: "Posometre"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: "white"
                leftPadding: 60
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            Column {
                Layout.fillWidth: true
                Label {
                    width: parent.width - 50
                    padding: 16
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi non eros fringilla, scelerisque est aliquam, facilisis odio."
                    wrapMode: Label.Wrap
                }
            }

            Rectangle {
                id: indicatorRect

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                color: "white"
                clip: true
                Rectangle {
                    id: gl
                    width: 60
                    height: parent.height - 40
                    radius: width / 2
                    anchors.centerIn: parent
                    clip: true
                    color: "#e8e8e8"
                    Item {
                        id: root
                        property real value: 0.0
                        property real radius: width / 2
                        anchors.bottom: parent.bottom
                        width: 60
                        height: (sensor.lightLevel * gl.height) / 6

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
                    width: parent.width / 3
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

                        Text {
                            text: label
                            color: "black"
                            Layout.alignment: Qt.AlignVCenter
                            anchors.verticalCenter: parent.verticalCenter
                            x: 10
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
                    sourceComponent:  Component {
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

            AmbientLightSensor {
                id: als
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
            label: "Ensolleilé"
        }
        ListElement {
            level: 4
            l_color: "yellow"
            textColor: 'black'
            label: "Très lumineux"
        }
        ListElement {
            level: 3
            l_color: "orange"
            textColor: 'black'
            label: "Lumineux"
        }
        ListElement {
            level: 2
            l_color: "white"
            textColor: 'black'
            label: "Normal"
        }
        ListElement {
            level: 1
            l_color: "gray"
            textColor: 'black'
            label: "Sombre"
        }
    }
}
