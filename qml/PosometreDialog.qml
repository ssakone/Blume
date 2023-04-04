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
        ListElement { level: 5; l_color: "red"; label: "Ensolleilé" }
        ListElement { level: 4; l_color: "yellow"; label: "Très lumineux"  }
        ListElement { level: 3; l_color: "orange"; label: "Lumineux"  }
        ListElement { level: 2; l_color: "white"; label: "Normal"  }
        ListElement { level: 1; l_color: "gray"; label: "Sombre" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Column {
            Layout.alignment: Qt.AlignHCenter
            IconSvg {
                width: 64
                height: 64
                source: "qrc:/assets/icons_custom/posometre.svg"
                color: 'black'
            }

            Label {
                text: "Posometre"
                font.weight: Font.Medium
            }

        }

        ShaderEffect {
            id: shaderEffect
            property real averageBrightness: 0.0
            property variant source: preview

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                void main() {
                    lowp vec4 color = texture2D(source, qt_TexCoord0);
                    lowp float luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
                    averageBrightness += luminance;
                    gl_FragColor = vec4(color.rgb * qt_Opacity, color.a * qt_Opacity);
                }
            "
            width: preview.width
            height: preview.height
            visible: false
        }

        Image {
            id: preview
            width: 320
            height: 240
            visible: false
            x: parent.width - width
            y: parent.height - height
        }

        Text {
            id: brightnessText
            x: 10
            y: 10
            text: "Luminosité moyenne : " + (shaderEffect.averageBrightness / (preview.width * preview.height)).toFixed(2)
        }

        Loader {
            id: accessCam
            asynchronous: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            active: true

            Component {
                id: cameraView
                Item {
                    id: control
                    property alias camera: cam
                    property alias imgCapture: imageCapture
                    anchors.fill: accessCam
                    CaptureSession {
                        camera: Camera {
                            id: cam
                        }

                        imageCapture: ImageCapture {
                            id: imageCapture
                            onImageCaptured: function (id, path) {
                                preview.source = imageCapture.preview + "?" + Math.random();
                            }

                            onErrorOccurred: function(id, error, message) {
                            }
                            Component.onCompleted: cam.start()
                        }
                        videoOutput: videoOutput
                    }

                    Rectangle {
                        width: (parent.width / 2) + 40
                        height: width
                        radius: width / 3
                        y: 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.color: "#00c395"
                        border.width: 6
                        ClipRRect {
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: parent.radius
                            VideoOutput {
                                id: videoOutput
                                width: control.width + 50
                                height: width
                                anchors.centerIn: parent
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: imageCapture.capture()
                        }
                    }
                }
            }
            sourceComponent: cameraView
        }



        Rectangle {
            id: indicatorRect

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            color: Qt.rgba(0, 0, 0, 0)
            radius: 20
            clip: true

            ListView {
                id: indicatorBar
                Layout.fillHeight: true
                height: parent.height + 20
                model: indicator_model

                delegate: RowLayout {
                    required property string label
                    required property int level
                    required property color l_color

                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true

                    Item {
                        width: 20
                        Layout.fillWidth: true
                    }
                    Rectangle {

                        id: indicatorLevel
                        height: Math.min((indicatorRect.height / indicator_model.count), 50) + 1 // To clip because of radius on parent Rectangle
                        width: indicator_width + 50 // To ensure overflow_x
                        Layout.fillWidth: true
                        color: (sensor != null && level <= sensor.lightLevel) ? l_color : Qt.rgba(0, 0, 0, 0)
                        radius: 5

                        Rectangle {
                            height: 1
                            width: parent.width
                            color: "white"
                            Layout.alignment: Qt.AlignBottom
                        }

                    }
                    Item {
                        width: 10
                        Layout.fillWidth: true
                    }

                    Text {
                        text: label
                        color: "white"
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
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
//                    console.log(JSON.stringify(als.reading))
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
