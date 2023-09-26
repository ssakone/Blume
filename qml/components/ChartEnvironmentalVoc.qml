import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import ThemeEngine 1.0

import "../components_generic/"
import "../components_themed/"

Item {
    id: chartEnvironmentalVoc
    width: 640
    height: 400

    property int scaleMin: 0
    property int scaleMax: 1500

    property int limitMin: -1
    property int limitMax: -1

    property int daysTarget: 14
    property int daysVisible: 0

    ////////////////////////////////////////////////////////////////////////////
    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice)
            return

        //console.log("chartEnvironmentalVoc // loadGraph() >> " + currentDevice)
        daysVisible = 0
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice)
            return

        //console.log("chartEnvironmentalVoc // updateGraph() >> " + currentDevice)
        if (itemDeviceEnvironmental.primary === "voc"
                || itemDeviceEnvironmental.primary === "hcho") {
            limitMin = 500
            limitMax = 1000
            scaleMax = 1500
        } else if (itemDeviceEnvironmental.primary === "co2") {
            limitMin = 850
            limitMax = 1500
            scaleMax = 2000
        } else if (itemDeviceEnvironmental.primary === "pm1"
                   || itemDeviceEnvironmental.primary === "pm25"
                   || itemDeviceEnvironmental.primary === "pm10") {
            limitMin = 250
            limitMax = 750
            scaleMax = 1000
        }

        chartEnvironmentalVoc.visible = currentDevice.countDataNamed(
                    "temperature", daysTarget)
    }

    ////////////////////////////////////////////////////////////////////////////
    Item {
        anchors.fill: parent
        anchors.topMargin: 0
        anchors.leftMargin: 20
        anchors.rightMargin: 16
        anchors.bottomMargin: 24

        Rectangle {
            id: vocLegendVert
            width: 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            color: Theme.colorSeparator

            Rectangle {
                // top
                width: 6
                height: 2
                color: Theme.colorSeparator
                anchors.top: parent.top
                anchors.right: parent.right
            }
            Rectangle {
                // limitMin
                width: 6
                height: 2
                color: Theme.colorSeparator
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (parent.height * (limitMin / scaleMax))

                Shape {
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 1
                    ShapePath {
                        strokeColor: Theme.colorSeparator
                        strokeWidth: isPhone ? 1 : 2
                        strokeStyle: ShapePath.DashLine
                        dashPattern: [1, 4]
                        startX: 0
                        startY: 0
                        PathLine {
                            x: chartEnvironmentalVoc.width
                            y: 0
                        }
                    }
                }
            }
            Rectangle {
                // limitMax
                width: 6
                height: 2
                color: Theme.colorSeparator
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (parent.height * (limitMax / scaleMax))

                Shape {
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 1
                    ShapePath {
                        strokeColor: Theme.colorSeparator
                        strokeWidth: isPhone ? 1 : 2
                        strokeStyle: ShapePath.DashLine
                        dashPattern: [1, 4]
                        startX: 0
                        startY: 0
                        PathLine {
                            x: chartEnvironmentalVoc.width
                            y: 0
                        }
                    }
                }
            }
            Rectangle {
                // bottom
                width: 6
                height: 2
                color: Theme.colorSeparator
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        ////////////////
        Rectangle {
            id: vocLegendHor
            height: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            color: Theme.colorSeparator
        }

        ////////////////
        Item {
            anchors.fill: parent
            anchors.bottomMargin: -24
            clip: true

            Item {
                // Flickable
                id: vocFlickable
                anchors.fill: parent
                anchors.bottomMargin: 26

                /*
                contentWidth: vocRow.width
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds
*/
                Row {
                    id: vocRow
                    height: parent.height
                    anchors.right: parent.right

                    spacing: 16

                    Repeater {
                        model: currentDevice.aioEnvData

                        Item {
                            id: barItem
                            height: parent.height
                            width: 16

                            property int valueMin
                            property int valueMean
                            property int valueMax

                            Component.onCompleted: loadValues()
                            function loadValues() {
                                if (itemDeviceEnvironmental.primary === "voc"
                                        || itemDeviceEnvironmental.primary === "hcho") {
                                    valueMin = modelData.vocMin
                                    valueMean = modelData.vocMean
                                    valueMax = modelData.vocMax
                                } else if (itemDeviceEnvironmental.primary === "co2") {
                                    valueMin = modelData.co2Min
                                    valueMean = modelData.co2Mean
                                    valueMax = modelData.co2Max
                                } else if (itemDeviceEnvironmental.primary === "pm25") {
                                    valueMin = modelData.pm25Min
                                    valueMean = modelData.pm25Mean
                                    valueMax = modelData.pm25Max
                                } else if (itemDeviceEnvironmental.primary === "pm10") {
                                    valueMin = modelData.pm10Min
                                    valueMean = modelData.pm10Mean
                                    valueMax = modelData.pm10Max
                                }

                                if (valueMax > scaleMax)
                                    valueMax = scaleMax
                                if (valueMean > scaleMax)
                                    valueMean = scaleMax
                            }

                            Connections {
                                target: itemDeviceEnvironmental
                                function onPrimaryChanged() {
                                    loadValues()
                                }
                            }

                            Rectangle {
                                height: barItem.height
                                width: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Theme.colorSeparator
                                opacity: 0.25
                            }

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom

                                radius: 13
                                width: 13
                                height: (valueMax / scaleMax) * barItem.height
                                Behavior on height {
                                    NumberAnimation {
                                        duration: 333
                                    }
                                }

                                color: {
                                    if (valueMax > limitMax)
                                        return Theme.colorOrange
                                    else if (valueMax > limitMin)
                                        return Theme.colorYellow
                                    else
                                        return Theme.colorGreen
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 333
                                    }
                                }

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    y: {
                                        if (valueMean >= scaleMax)
                                            return 1
                                        return (parent.height - ((valueMean / scaleMax)
                                                                 * parent.height))
                                    }
                                    visible: (valueMean > 0)
                                    width: parent.width - 2
                                    height: width
                                    radius: width
                                    color: "white"
                                    opacity: 0.8
                                }

                                /*
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.topMargin: 1
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    height: (modelData.hchoMax / scaleMax) * barItem.height
                                    width: 9
                                    radius: 9
                                    color: "white"
                                    opacity: 0.8
                                }
*/
                            }

                            Text {
                                anchors.top: parent.bottom
                                anchors.topMargin: 6
                                anchors.horizontalCenter: parent.horizontalCenter

                                rotation: -45
                                text: modelData.day
                                color: Theme.colorSubText
                                font.bold: modelData.today
                                font.pixelSize: (Theme.fontSizeContentSmall - 2)
                            }
                        }
                    }
                }
            }
        }

        ///////////////
    }
}
