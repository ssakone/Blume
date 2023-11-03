import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageTools

import QtQuick.Controls.Material
import ThemeEngine 1.0
import "../components"
import "../components_generic"
import "../components_js/Http.js" as Http

BPage {
    id: control

    ColumnLayout {
        anchors.fill: parent
        SwipeView {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true


            Rectangle {
                color: $Colors.gray50
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 50
                    anchors.bottomMargin: 50
                    Label {
                        text: qsTr("Welcome !")
                        color: $Colors.green700
                        font {
                            pixelSize: 24
                            weight: Font.DemiBold
                        }
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    IconSvg {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: "qrc:/assets/img/welcome.svg"
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            Label {
                                text: qsTr("Blume")
                                color: $Colors.green700
                                font {
                                    pixelSize: 18
                                    weight: Font.DemiBold
                                }
                                anchors.bottom: parent.bottom
                            }

                            Label {
                                text: qsTr(" identifies your plants")
                                font {
                                    pixelSize: 16
                                    weight: Font.Light
                                }
                                anchors.bottom: parent.bottom
                            }

                        }


                        Label {
                            text: qsTr("and detects the health status of your plants")
                            font {
                                pixelSize: 16
                                weight: Font.Light
                            }
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                }

            }

            Rectangle {
                color: $Colors.green50
                clip: true

                Rectangle {
                    anchors {
                        bottom: parent.top
                        bottomMargin: -370
                        horizontalCenter: parent.horizontalCenter
                    }

                    height: 1200
                    width: height / 2.9
                    radius: height * 0.9

                    gradient: $Colors.gradientPrimary
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 50
                        bottomMargin: 50
                    }
                    spacing: 25
                    Column {
                        Layout.fillWidth: true

                        Label {
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Blume is working")
                            color: $Colors.white
                            font.pixelSize: 18
                        }
                        Label {
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("with the following sensors")
                            color: $Colors.white
                            font.pixelSize: 18
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    IconSvg {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        source: "qrc:/assets/tutorial/sensors.svg"
                    }
                    Container {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                        contentItem: Column {
                            padding: 10
                            spacing: 15
                        }

                        background: Rectangle {
                            color: $Colors.colorTertiary
                            radius: 10
                        }
                        Label {
                            text: qsTr("It also works great with a couple of")
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Row {
                            width: parent.width
                            leftPadding: 30
                            spacing: 15
                            Rectangle {
                                width: 25
                                height: width
                                anchors.verticalCenter: parent.verticalCenter

                                IconSvg {
                                    anchors.centerIn: parent
                                    source: Icons.checkBoxOutline
                                    color: $Colors.colorPrimary
                                }
                            }
                            Label {
                                text: qsTr("Thermometers")
                                font.pixelSize: 16
                                color: $Colors.colorPrimary
                                width: parent.width - 2*parent.leftPadding
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            leftPadding: 30
                            spacing: 15
                            Rectangle {
                                width: 25
                                height: width
                                anchors.verticalCenter: parent.verticalCenter

                                IconSvg {
                                    anchors.centerIn: parent
                                    source: Icons.checkBoxOutline
                                    color: $Colors.colorPrimary
                                }
                            }
                            Label {
                                text: qsTr("Other sensors like air quality monitors and weather")
                                font.pixelSize: 16
                                color: $Colors.colorPrimary
                                width: parent.width - 3*parent.leftPadding
                                wrapMode: Text.Wrap
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                    }

                }
            }

            Rectangle {
                color: $Colors.gray50
                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 50
                        bottomMargin: 50
                    }
                    spacing: 25
                    Column {
                        Layout.fillWidth: true

                        Label {
                            id: _insideText1
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Recognizing plant")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            horizontalAlignment: Text.AlignLeft
                            anchors.left: _insideText1.left
                            text: qsTr("DISEASE !")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.Bold
                            }
                        }
                    }

                    ClipRRect {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15

                        Image {
                            anchors.fill: parent
                            source: "qrc:/assets/img/scan-disease.png"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 60
                        Layout.fillWidth: true
                        Layout.leftMargin: 25
                        Layout.rightMargin: 25
                        Layout.bottomMargin: 35
                        color: "#DBFFEE"
                        radius: 10

                        Row {
                            spacing: 35
                            padding: 7
                            leftPadding: 12
                            rightPadding: 12

                            ClipRRect {
                                width: 60
                                height: 40
                                radius: 15
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    source: "qrc:/assets/img/orchidee.jpg"
                                    fillMode: Image.PreserveAspectCrop
                                    anchors.fill: parent
                                }
                            }


                            Column {
                                Label {
                                    text: qsTr("Abutilon pictum")
                                    font {
                                        pixelSize: 18
                                        weight: Font.DemiBold
                                    }
                                    color: $Colors.colorPrimary
                                }
                                Label {
                                    text: qsTr("Erable à fleur lanterne")
                                    color: $Colors.colorPrimary
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                color: $Colors.gray50
                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 50
                        bottomMargin: 50
                    }
                    spacing: 25
                    Column {
                        Layout.fillWidth: true

                        Label {
                            id: _insideText2
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Identify")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            horizontalAlignment: Text.AlignLeft
                            anchors.left: _insideText2.left
                            text: qsTr("PLANT !")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.Bold
                            }
                        }
                    }

                    ClipRRect {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                        radius: 15

                        Image {
                            anchors.fill: parent
                            source: "qrc:/assets/img/scan-plant.png"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 60
                        Layout.fillWidth: true
                        Layout.leftMargin: 25
                        Layout.rightMargin: 25
                        Layout.bottomMargin: 35
                        color: "#DBFFEE"
                        radius: 10

                        Row {
                            spacing: 35
                            padding: 7
                            leftPadding: 12
                            rightPadding: 12

                            ClipRRect {
                                width: 60
                                height: 40
                                radius: 10
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    source: "qrc:/assets/img/orchidee.jpg"
                                    fillMode: Image.PreserveAspectCrop
                                    anchors.fill: parent
                                }
                            }


                            Column {
                                Label {
                                    text: qsTr("Alternia")
                                    font {
                                        pixelSize: 18
                                        weight: Font.DemiBold
                                    }
                                    color: $Colors.colorPrimary
                                }
                                Label {
                                    text: qsTr("Champignon")
                                    color: $Colors.colorPrimary
                                }
                            }
                        }
                    }
                }
            }

            Item {}

            onCurrentIndexChanged: {
                if (currentIndex < 0) {
                    currentIndex = 0
                }
                else if (currentIndex >= count - 1) {
                    pesistedAppSettings.didTutorialOpen = true
                }
            }
        }
    }

    RowLayout {
        width: parent.width

        anchors {
            bottom: parent.bottom
            bottomMargin: 15
        }

        Item {
            Layout.fillWidth: true
        }

        PageIndicator {
            count: swipeView.count - 1
            currentIndex: swipeView.currentIndex
            leftPadding: 25
            spacing: 15
            delegate: Rectangle {
                width: 15
                height: width
                radius: height/2
                color: index === swipeView.currentIndex ? $Colors.colorBlue : $Colors.colorPrimary
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Skip")
            color: $Colors.colorPrimary
            rightPadding: 20
            MouseArea {
                anchors.fill: parent
                onClicked: swipeView.currentIndex = swipeView.count - 1
            }
        }
    }
}
