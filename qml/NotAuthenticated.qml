import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ThemeEngine

import "components"
import "components_generic"

Popup {
    id: root
    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    Timer {
        id: tm
        interval: 500
        onTriggered: {
            root.close()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 25

        Container {
            Layout.preferredHeight: (Math.min(root.width, root.width) / 1.5)
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignHCenter

            background: Rectangle {
                color: Theme.colorSecondary
                radius: height / 2
            }

            contentItem: Column {
                anchors.fill: parent
                padding: root.width > 500 ? 50 : 20
            }

            ColumnLayout {
                width: parent.width - 20
                spacing: 15

                IconSvg {
                    source: Icons.security
                    Layout.preferredHeight: 70
                    Layout.preferredWidth: 70
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "You should have an account before getting access to that !"
                    font {
                        weight: Font.Light
                        pixelSize: 18
                    }
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    Layout.alignment: Qt.AlignHCenter
                }
            }


        }

        RowLayout {
            width: parent.width

            ButtonWireframe {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                primaryColor: Theme.colorPrimary
                componentRadius: 20
                text: qsTr("Log In")
                onClicked: {
                    page_view.push(navigator.loginPage)
                    tm.start()
                }
            }
            ButtonWireframe {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                primaryColor: Theme.colorPrimary
                fullColor: true
                componentRadius: 20
                text: qsTr("Register")
                onClicked: {
                    page_view.push(navigator.registerPage)
                    tm.start()
                }
            }
        }
    }


}
