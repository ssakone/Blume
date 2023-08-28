import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import MaterialIcons
import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    id: root

    property bool isSubmiting: false
    property string errorText: ""
    property color shade: Qt.rgba(15, 200, 15, 0.7)

    header: AppBar {}

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

        IconSvg {
            source: "qrc:/assets/logos/logo.svg"
            Layout.preferredHeight: 70
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignHCenter
        }

        ButtonWireframeIcon {
            text: qsTr("Sign in with Google")
            source: Icons.google
            backgroundBorderWidth: 1
            primaryColor: $Colors.colorPrimary
            secondaryColor: root.shade
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter
        }

        ButtonWireframeIcon {
            text: qsTr("Sign in with Apple")
            source: Icons.apple
            primaryColor: $Colors.colorPrimary
            secondaryColor: root.shade
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 25
            Layout.bottomMargin: 25
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: $Colors.gray500
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                text: qsTr("OR")
                color: $Colors.gray500
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: $Colors.gray500
                Layout.alignment: Qt.AlignVCenter
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20

            Column {
                Layout.fillWidth: true
                spacing: 7

                Label {
                    text: qsTr("Email or username")
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
                    text: qsTr("Password")
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
                        source: Icons.lock
                        color: $Colors.colorPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

            }

            Label {
                text: qsTr("Forgot password ?")
                color: $Colors.colorPrimary
                font {
                    weight: Font.DemiBold
                }
            }

            NiceButton {
                text: qsTr("Connexion")
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                Layout.topMargin: 10

                foregroundColor: $Colors.white
                backgroundColor: $Colors.colorPrimary
            }
        }


        Item {
            Layout.fillHeight: true
        }
    }

}
