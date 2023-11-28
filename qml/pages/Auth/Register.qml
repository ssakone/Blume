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
import Qaterial as Qaterial
import QtWebSockets

import MaterialIcons
import "../../components"
import "../../components_generic"

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

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: insideCol.height + 90

            Column {
                id: insideCol
                width: parent.width
                spacing: 25

                IconSvg {
                    source: "qrc:/assets/logos/logo.svg"
                    height: 70
                    width: height
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ButtonWireframeIcon {
                    text: qsTr("Sign in with Google")
                    source: Icons.google
                    backgroundBorderWidth: 1
                    primaryColor: $Colors.colorPrimary
                    secondaryColor: root.shade
                    height: 50
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ButtonWireframeIcon {
                    text: qsTr("Sign in with Apple")
                    source: Icons.apple
                    primaryColor: $Colors.colorPrimary
                    secondaryColor: root.shade
                    height: 50
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                RowLayout {
                    width: parent.width
                    anchors.topMargin: 25
                    anchors.bottomMargin: 25
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
                    width: parent.width
                    spacing: 20

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Nom")
                        }
                        TextField {
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
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Prénoms")
                        }
                        TextField {
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
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Email")
                        }
                        TextField {
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
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Username *")
                        }
                        TextField {
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
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 7

                        Label {
                            text: qsTr("Password *")
                        }
                        TextField {
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
                        }
                    }

                    Qaterial.Label {
                        id: errorLabel
                        visible: false
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Mot de passe incorrect"
                        color: "red"
                    }

                    NiceButton {
                        text: qsTr("Créer mon compte")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        Layout.topMargin: 10

                        foregroundColor: $Colors.white
                        backgroundColor: $Colors.colorPrimary
                    }

                }
            }
        }


    }

}
