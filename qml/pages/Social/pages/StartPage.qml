import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageTools

import QtQuick.Controls.Material
import "../../../components"
import "../../../components_generic"

BPage {
    id: askPage
    property string currentObj: ""
    header: AppBar {
        title: ""
        onBackButtonClicked: {
            page_view.pop()
        }
        foregroundColor: $Colors.white
        color: $Colors.colorPrimary
    }

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
            Layout.topMargin: -60

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
                            view.pop()
                            view.push(loginPage)
                        }
                    }
                    NiceButton {
                        text: qsTr("Sign up")
                        width: 180
                        height: 50
                        anchors.horizontalCenter: parent.horizontalCenter

                        foregroundColor: $Colors.colorPrimary
                        backgroundColor: $Colors.white
                        backgroundBorderWidth: 1
                        backgroundBorderColor: $Colors.colorPrimary
                        onClicked: {
                            view.pop()
                            view.push(registerPage)
                        }
                    }
                }
            }
        }

    }
}
