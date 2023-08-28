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

    header: AppBar {
        title: "Registration"
    }

    background: Rectangle {
        color: $Colors.colorPrimary
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Alert {
            Layout.fillWidth: true
            Layout.minimumHeight: 40
            time: 5000
            visible: errorText !== ""
            text: errorText
            callback: function() {
                root.errorText = "";
            }
        }

        Item {
            Layout.fillHeight: true
        }

        ClipRRect {
            Layout.preferredWidth: 150
            Layout.preferredHeight: 150
            Layout.alignment: Qt.AlignHCenter
            IconSvg {
                anchors.fill: parent
                source: "qrc:/assets/logos/blume.svg"
            }
        }

        Column {
            Layout.fillWidth: true
            padding: 10
            spacing: 25

            Column {
                width: parent.width - 2*parent.padding

                TextField {
                    id: emailField
                    width: parent.width
                    height: 60
                    leftPadding: 40
                    font.pixelSize: 16
                    font.weight: Font.Light
                    placeholderText: "Email"

                    IconSvg {
                        source: Icons.account
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        width: 30
                        height: width
                    }
                }

                TextField {
                    id: pwdField
                    width: parent.width
                    height: 60
                    leftPadding: 40
                    font.pixelSize: 16
                    font.weight: Font.Light
                    placeholderText: "Password"

                    IconSvg {
                        source: Icons.security
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        width: 30
                        height: width
                    }
                }

            }

            Column {
                width: parent.width - 2*parent.padding
                spacing: 10

                ButtonWireframe {
                    width: parent.width
                    height: 60
                    primaryColor: $Colors.colorPrimary
                    componentRadius: 20
                    text: qsTr("Create my account")
                    onClicked: handleSignIn()
                    BusyIndicator {
                        anchors.fill: parent
                        running: isSubmiting
                    }
                }

                ButtonWireframe {
                    width: parent.width
                    height: 60
                    primaryColor: $Colors.colorPrimary
                    fullColor: true
                    componentRadius: 20
                    text: qsTr("Already have an account")
                    onClicked: page_view.pop()

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.componentRadius
                        color: Qt.rgba(0, 0, 0, 0)
                        border {
                            width: 1
                            color: "white"
                        }
                    }
                }

                Label {
                    text: "Forgot password ?"
                    font.underline: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

            }
        }


        Item {
            Layout.fillHeight: true
        }

    }
}
