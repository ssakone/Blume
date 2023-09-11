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
                        text: "Welcome !"
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
                            text: "and detects the health status of your plants"
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

            Item {
                ColumnLayout {
                    anchors.fill: parent

                    Rectangle {
                        id: head
                        Layout.preferredHeight: 250
                        Layout.fillWidth: true
                        color: $Colors.colorPrimary


                        Image {
                            source: "qrc:/assets/img/plant_pot.png"
                            width: parent.width
                            fillMode: Image.PreserveAspectCrop
                        }
                    }


                    Column {
                        id: colHeadFaqForm
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            width: parent.width
                            height: insideCol2.height + 70
                            color: $Colors.colorTertiary
                            radius: 50
                            IconSvg {
                                source: "qrc:/assets/icons_custom/tulipe_right.svg"
                                height: 180
                                anchors {
                                    right: parent.right
                                    bottom: parent.bottom
                                    bottomMargin: 200
                                }
                            }

                            IconSvg {
                                source: "qrc:/assets/icons_custom/tulipe_left.svg"
                                height: 180
                                width: 70
                                anchors {
                                    left: parent.left
                                    bottom: parent.bottom
                                    bottomMargin: 40
                                }
                            }

                            Column {
                                id: insideCol2
                                width: parent.width
                                padding: width < 500 ? 10 : width / 11
                                topPadding: 30
                                bottomPadding: 70
                                anchors.verticalCenter: parent.verticalCenter

                                spacing: 15

                                IconSvg {
                                    width: 150
                                    height: 150
                                    source: "qrc:/assets/logos/blume.svg"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Label {
                                    text: qsTr("Register or sign up to your Blume account to get access to all features")
                                    width: (parent.width - parent.padding * 2) / 1.4
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.Wrap
                                    font {
                                        weight: Font.Light
                                        pixelSize: 15
                                    }
                                }

                                NiceButton {
                                    text: qsTr("Log in")
                                    width: 180
                                    height: 50
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    onClicked: {
                                        page_view.pop()
                                        page_view.push(navigator.signInPage)
                                    }
                                }
                                NiceButton {
                                    text: qsTr("Sign un")
                                    width: 180
                                    height: 50
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    foregroundColor: $Colors.colorPrimary
                                    backgroundColor: $Colors.white
                                    backgroundBorderWidth: 1
                                    backgroundBorderColor: $Colors.colorPrimary
                                    onClicked: {
                                        page_view.pop()
                                        page_view.push(navigator.registerPage)
                                    }
                                }
                            }
                        }
                    }

                }

            }

            Item {}

            onCurrentIndexChanged: {
                console.log("\n\n Passer ", currentIndex, count - 1 )
                console.log("Current state ", appContent.state)
                if (currentIndex < 0) {
                    currentIndex = 0
                }
                else if (currentIndex >= count - 1) {
                    appContent.state = "Navigator"
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
            text: qsTr("Passer")
            color: $Colors.colorPrimary
            rightPadding: 20
            MouseArea {
                anchors.fill: parent
                onClicked: swipeView.currentIndex = swipeView.count - 1
            }
        }
    }
}
