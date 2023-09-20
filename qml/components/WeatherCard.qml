import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components_generic"

Rectangle {
    width: parent.width - 20
    height: 180
    anchors.leftMargin: 10
    anchors.rightMargin: 20
    radius: 20

    color: Qt.rgba(255, 255, 255, 0.9)
    required property var weatherData
    required property var location
    required property string dateText

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 25

                Label {
                    text: location?.name?? ""
                }

                Image {
                    source: "http://" + weatherData?.condition?.icon?.slice(2)
                    width: 130
                    height: width
                }
            }


            Column {
                anchors.right: parent.right
                anchors.rightMargin: 25
                Label {
                    text: dateText
                    font {
                        pixelSize: 14
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: weatherData?.temp_c + "° C"
                    color: $Colors.colorPrimary
                    font {
                        pixelSize: 36
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: weatherData?.condition?.text?? ""
                    color: $Colors.colorPrimary
                    font {
                        pixelSize: 14
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Column {
                Layout.fillWidth: true
                IconSvg {
                    source: Icons.umbrella
                    color: $Colors.colorPrimary
                    width: 20
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: weatherData?.precip_mm?? "" + " mm"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: "Precipitation"
                    color: $Colors.colorPrimary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Column {
                Layout.fillWidth: true
                IconSvg {
                    source: Icons.water
                    color: $Colors.colorPrimary
                    width: 20
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: weatherData?.humidity + "%"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: "Humidité"
                    color: $Colors.colorPrimary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Column {
                Layout.fillWidth: true
                IconSvg {
                    source: Icons.windPower
                    color: $Colors.colorPrimary
                    width: 20
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: weatherData?.wind_kph?? "" + "km/h"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    text: "Vitesse du vent"
                    color: $Colors.colorPrimary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

        }
    }

    ColorImage {
        visible: isWeatherLoaded && weatherData === undefined
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 15
        source: Icons.weatherCloudy
        width: 50
        height: width
    }

}
