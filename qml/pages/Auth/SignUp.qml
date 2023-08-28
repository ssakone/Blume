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

    function handleLogin() {
        isSubmiting = true
        const payload = {
            "email": emailField.text,
            "password": pwdField.text
        }

        Http.login(payload).then(response => {
            isSubmiting = false
            const access_token = JSON.parse(response)?.data?.access_token
            if(access_token) {
                 settingsManager.authAccessToken = access_token
             } else errorText = "Une erreur inattendue s'est produite !"

       })
        .catch(err => {
                   isSubmiting = false
                   if(err.status === 0) errorText = "Veuillez vérifier votre connexion internet et reéssayez !"
                   else errorText = JSON.parse(err.content).errors[0]?.message
               })
    }

    header: AppBar {
        title: ""
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
                    placeholderText: qsTr("Email")

                    IconSvg {
                        source: Icons.account
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30
                        height: width
                        color: "white"
                    }
                }

                TextField {
                    id: pwdField
                    width: parent.width
                    height: 60
                    leftPadding: 40
                    font.pixelSize: 16
                    font.weight: Font.Light
                    placeholderText: qsTr("Password")

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
                    text: qsTr("Log In")
                    onClicked: handleLogin()
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
                    text: qsTr("Sign Un")
                    onClicked: page_view.push(navigator.registerPage)

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
                    text: qsTr("Forgot password ?")
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
