import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
import "components"

Rectangle {
    id: faqPopup

    parent: appWindow.contentItem
    width: appWindow.width
    height: appWindow.height

    color: 'red'
//    padding: 0

    Rectangle {
        width: parent.width
        height: parent.height / 2

        ColumnLayout {
            anchors.fill: parent

            anchors.topMargin: header.height
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                text: "Demander à un botaniste"
                font.pixelSize: 24
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            Label {
                text: "Ut tincidunt mi non mauris dignissim tincidunt. Nam ornare gravida suscipit. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Maecenas pulvinar venenatis risus, vitae malesuada quam mattis eget. Aliquam sit amet lobortis ipsum. Mauris id dignissim metus. Integer sit amet commodo tortor. Ut laoreet tempus maximus. In nisi mi, rhoncus a varius at, viverra eu ante. Praesent quis mi non sem bibendum interdum. Maecenas a eros nisi. Sed magna dui, venenatis nec venenatis non, varius ac felis. "
                font.weight: Font.Light
                font.pixelSize: 16
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0


        Rectangle {
            id: header
            color: "#00c395"
            Layout.preferredHeight: 65
            Layout.preferredWidth: faqPopup.width
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    id: buttonBackBg
                    Layout.alignment: Qt.AlignVCenter
                    width: 65
                    height: 65
                    radius: height
                    color: "transparent" //Theme.colorHeaderHighlight
                    opacity: 1
                    IconSvg {
                        id: buttonBack
                        width: 24
                        height: width
                        anchors.centerIn: parent

                        source: "qrc:/assets/menus/menu_back.svg"
                        color: Theme.colorHeaderContent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            faqPopup.close()
                        }
                    }

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 333
                        }
                    }
                }
                Label {
                    text: "Retour"
                    font.pixelSize: 21
                    font.bold: true
                    font.weight: Font.Medium
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        Flickable {
            y: header.height
            contentHeight: mainContent.height
            contentWidth: faqPopup.width
            Layout.fillHeight: true
            Layout.fillWidth: true


            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Rectangle {
                anchors.fill: parent
                ColumnLayout {
                    id: mainContent
                    width: parent.width
                    spacing: 10

                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Layout.leftMargin: 10
                        Layout.rightMargin: 10

                        spacing: 20


                        Item {
                            Layout.preferredHeight: 20
                        }
                    }


                }
            }


        }
    }


}
