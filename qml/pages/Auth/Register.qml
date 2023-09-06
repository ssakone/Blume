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

    function handleSignIn() {
        isSubmiting = true

        const payload = {
            "email": emailField.text,
            "password": pwdField.text
        }

        Http.login(payload).then(response => {
            isSubmiting = false
       })
        .catch(err => {
                   isSubmiting = false
                   console.log(JSON.parse(err.content).errors[0]?.message)
                   if(err.status === 0) errorText = "Veuillez vérifier votre connexion internet et reéssayez !"
                   else errorText = JSON.parse(err.content).errors[0]?.message
               })
    }

    header: Item {}

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
                        onClicked: page_view.pop()
                    }
                }
            }

        }


        Item {
            Layout.fillHeight: true
        }
    }


}
