import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qaterial as Qaterial

import "../components"

Page {
    property bool isSubmitting: false
    property string error: ""

    padding: 20

    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.fillHeight: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Close my account")
                color: Qaterial.Colors.red400
                font {
                    weight: Font.Bold
                    pixelSize: 24
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("All the data related to your account will be erased. This action is irreversible")
                wrapMode: Label.Wrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                CheckBox {
                    id: agreement
                    enabled: !isSubmitting
                }
                Label {
                    text: qsTr("I understand what closing my account implies")
                    Layout.fillWidth: true
                     wrapMode: Label.Wrap
                }
            }

            BusyIndicator {
                running: isSubmitting
                visible: isSubmitting
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: error
                color: 'red'
                font.pixelSize: 14
                Layout.fillWidth: true
                wrapMode: Label.Wrap
            }


            NiceButton {
                enabled: agreement.checked && !isSubmitting
                bgGradient: $Colors.gradientPrimary
                text: isSubmitting ? "" : qsTr("Confirm account closing")
                icon.source: Qaterial.Icons.close
                radius: 10
                Layout.fillWidth: true
                height: 60
                onClicked: {
                    isSubmitting = true
                    http.deleteMyAccount()
                    .then(function(res) {
                        console.log(res)
                        isSubmitting = false
                        try {
                            const data = JSON.parse(res)
                            if(data.status === "ok") {
                                wipeAll()
                                logout()
                            } else {
                                error = "error"
                            }
                        } catch (e) {
                            error = qsTr("An error occured")
                        }

                    }) .catch(function(err) {
                        console.log(JSON.stringify(err))
                        isSubmitting = false
                        error = qsTr("An error occured")
                        if(res.status > 0) {
                            error = err.statusText
                        }
                    })
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
