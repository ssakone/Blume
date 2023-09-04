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


            Item {
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 50
                    anchors.bottomMargin: 50
                    Label {
                        text: "Welcome"
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

                        Label {
                            text: qsTr("Blume identifies your plants")
                            color: $Colors.green700
                            font {
                                pixelSize: 18
                                weight: Font.DemiBold
                            }
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Label {
                            text: "and detects the health status"
                            font {
                                pixelSize: 18
                                weight: Font.DemiBold
                            }
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                }

            }

            Rectangle {
                color: $Colors.green100

                Rectangle {
                    anchors {
                        bottom: parent.top
                        bottomMargin: -220
                        horizontalCenter: parent.horizontalCenter
                    }

                    height: 1200
                    width: height / 1.7
                    radius: height

                    color: $Colors.primary
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
                            radius: 20
                        }
                        Label {
                            text: qsTr("It also works great with a couple of")
                        }
                        Repeater {
                            model: 2

                            Row {
                                leftPadding: 15
                                spacing: 15
                                Rectangle {
                                    width: 25
                                    height: width
                                    border {
                                        width: 1
                                        color: $Colors.green400
                                    }
                                    anchors.verticalCenter: parent.verticalCenter

                                    IconSvg {
                                        anchors.centerIn: parent
                                        source: Icons.checkBoxOutline
                                        color: $Colors.colorPrimary
                                    }
                                }
                                Label {
                                    text: qsTr("Thermometer")
                                    font.pixelSize: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                    }

                }
            }

            Rectangle {
                color: $Colors.colorTertiary
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
                            text: qsTr("Recognizing plant")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Disease !")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.Bold
                            }
                        }
                    }

                    Image {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                        source: "qrc:/assets/img/orchidee.jpg"
                        fillMode: Image.PreserveAspectCrop
                    }

                    Rectangle {
                        Layout.preferredHeight: 60
                        Layout.fillWidth: true
                        Layout.leftMargin: 25
                        Layout.rightMargin: 25
                        color: $Colors.green100
                        radius: 10

                        Row {
                            spacing: 35
                            padding: 7
                            leftPadding: 12
                            rightPadding: 12

                            Image {
                                source: "qrc:/assets/img/orchidee.jpg"
                                fillMode: Image.PreserveAspectCrop
                                width: 80
                                height: 40
                                anchors.verticalCenter: parent.verticalCenter
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

            Rectangle {
                color: $Colors.colorTertiary
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
                            text: qsTr("Identify")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.DemiBold
                            }
                        }
                        Label {
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("PLANT !")
                            color: $Colors.colorPrimary
                            font {
                                pixelSize: 28
                                weight: Font.Bold
                            }
                        }
                    }

                    IconSvg {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                        source: "qrc:/assets/tutorial/welcome-plant-green-pot.png"
                        fillMode: Image.PreserveAspectCrop
                    }

                    Container {
                        Layout.fillWidth: true
                        Layout.leftMargin: 25
                        Layout.rightMargin: 25

                        background: Rectangle {
                            color: $Colors.green100
                            radius: 10
                        }

                        contentItem: Row {
                            spacing: 35
                            padding: 7
                            leftPadding: 12
                            rightPadding: 12
                        }

                        IconSvg {
                            source: "qrc:/assets/tutorial/welcome-plant-green-pot.png"
                            fillMode: Image.PreserveAspectCrop
                            width: 80
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter
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
                            Label {
                                text: qsTr("chinoise d'erable à l'intérieur")
                                color: $Colors.colorPrimary
                            }
                        }

                    }
                }
            }

            Item {
                id: root
                property color shade: Qt.rgba(15, 200, 15, 0.7)

                IconSvg {
                    source: "qrc:/assets/icons_custom/tulipe_left.svg"
                    height: 180
                    width: 70
                    anchors {
                        left: parent.left
                        top: parent.top
                        topMargin: 150
                    }
                    transform: Rotation {
                        angle: 10
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 25

                    Item {
                        Layout.fillHeight: true
                    }

                    IconSvg {
                        source: "qrc:/assets/logos/logo.svg"
                        Layout.preferredHeight: 120
                        Layout.preferredWidth: Layout.preferredHeight
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        Column {
                            Layout.fillWidth: true
                            spacing: 7

                            Label {
                                text: qsTr("Nom")
                            }
                            TextField {
                                id: nameInput
                                padding: 5
                                leftPadding: 40

                                width: parent.width
                                height: 50

                                verticalAlignment: Text.AlignVCenter

                                font {
                                    pixelSize: 14
                                    weight: Font.Light
                                }

                                background: Rectangle {
                                    radius: 15
                                    color: root.shade
                                    border {
                                        color: $Colors.colorPrimary
                                        width: 1
                                    }
                                }

                                IconSvg {
                                    anchors.leftMargin: 7
                                    source: Icons.account
                                    color: $Colors.colorPrimary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 7

                            Label {
                                text: qsTr("Prenom")
                            }
                            TextField {
                                id: pwdInput
                                padding: 5
                                leftPadding: 40

                                width: parent.width
                                height: 50

                                verticalAlignment: Text.AlignVCenter

                                font {
                                    pixelSize: 14
                                    weight: Font.Light
                                }

                                background: Rectangle {
                                    radius: 15
                                    color: root.shade
                                    border {
                                        color: $Colors.colorPrimary
                                        width: 1
                                    }
                                }

                                IconSvg {
                                    anchors.leftMargin: 10
                                    source: Icons.account
                                    color: $Colors.colorPrimary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 7

                            Label {
                                text: qsTr("Email")
                            }
                            TextField {
                                id: emailInput
                                padding: 5
                                leftPadding: 40

                                width: parent.width
                                height: 50

                                verticalAlignment: Text.AlignVCenter

                                font {
                                    pixelSize: 14
                                    weight: Font.Light
                                }

                                background: Rectangle {
                                    radius: 15
                                    color: root.shade
                                    border {
                                        color: $Colors.colorPrimary
                                        width: 1
                                    }
                                }

                                IconSvg {
                                    anchors.leftMargin: 10
                                    source: Icons.email
                                    color: $Colors.colorPrimary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 7

                            Label {
                                text: qsTr("Username")
                            }
                            TextField {
                                id: usernameInput
                                padding: 5
                                leftPadding: 40

                                width: parent.width
                                height: 50

                                verticalAlignment: Text.AlignVCenter

                                font {
                                    pixelSize: 14
                                    weight: Font.Light
                                }

                                background: Rectangle {
                                    radius: 15
                                    color: root.shade
                                    border {
                                        color: $Colors.colorPrimary
                                        width: 1
                                    }
                                }

                                IconSvg {
                                    anchors.leftMargin: 50
                                    source: Icons.tag
                                    color: $Colors.colorPrimary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                        }

                        NiceButton {
                            text: qsTr("S'inscrire")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            Layout.topMargin: 10

                            foregroundColor: $Colors.white
                            backgroundColor: $Colors.colorPrimary
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.margins: 10
                            Item {
                                Layout.fillWidth: true
                            }
                            Label {
                                text: qsTr("Passer")
                                color: $Colors.colorPrimary
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: swipeView.currentIndex++
                                }
                            }
                        }

                    }


                    Item {
                        Layout.fillHeight: true
                    }
                }

            }

            Item {}

            onCurrentIndexChanged: {
                if (currentIndex < 0) {
                    currentIndex = 0
                }
                else if (currentIndex === count - 1) {
                    page_view.push(navigator.gardenScreen)
                }
            }
        }

//        Container {
//            Layout.fillWidth: true

//            background: Rectangle {
//                color: $Colors.colorTertiary
//            }

//            contentItem: RowLayout {
//                Layout.fillWidth: true
//            }

//            Item {
//                Layout.fillWidth: true
//            }

//            PageIndicator {
//                count: swipeView.count
//                currentIndex: swipeView.currentIndex
//            }

//            Item {
//                Layout.fillWidth: true
//            }
//        }


    }

    PageIndicator {
        count: swipeView.count - 1
        currentIndex: swipeView.currentIndex

        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
    }
}
