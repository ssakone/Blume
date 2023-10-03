import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qaterial as Qaterial

import "../components"

Page {
    Flickable {
        anchors.fill: parent
        contentHeight: insideCol.height

        Column {
            id: insideCol
            width: parent.width
            spacing: 25
            topPadding: 20

            // Search bar row
            Column {
                width: parent.width - 30
                leftPadding: 15
                rightPadding: 15

                RowLayout {
                   width: parent.width
                   height: 50
                   anchors.leftMargin: 15
                   anchors.rightMargin: 15
                   spacing: 10

                    Avatar {
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: height
                        source: "qrc:/assets/img/jardinier.png"
                        onClicked: {
                            let data = userInfo || {}
                            data["pubkey"] = publicKey
                            view.push(userProfile, {
                                          "profile": data
                                      })
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                        radius: 25
                        color: Qaterial.Colors.gray100

                        border {
                            width: 1
                            color: Qaterial.Colors.gray300
                        }

                        Row {
                            leftPadding: 20
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter
                            IconImage {
                                width: 30
                                height: width
                                source: Qaterial.Icons.magnify
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: qsTr("Chercher un ami")
                                color: Qaterial.Colors.gray600
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    IconImage {
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: height
                        source: Qaterial.Icons.messageOutline
                        color: $Colors.colorPrimary
                    }
                }
            }


            Flickable {
                width: parent.width - 20
                height: 120
                contentWidth: storiesRow.width

                Row {
                    id: storiesRow
                    spacing: 15
                    leftPadding: 15
                    Repeater {
                        model: 5


                        Rectangle {
                            width: 200
                            height: 120
                            radius: 10
                            border {
                                width: 2
                                color: $Colors.colorPrimary
                            }

                            Qaterial.ClipRRect {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: parent.radius
                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/assets/img/garden.png"
                                }

                            }
                            Label {
                                text: "Jean le Duc"
                                padding: 4
                                leftPadding: 30
                                color: $Colors.colorPrimary
                                background: Rectangle {
                                    color: $Colors.colorTertiary
                                    radius: 5
                                }
                                anchors {
                                    top: parent.top
                                    topMargin: 3
                                    left: parent.left
                                    leftMargin: 5
                                }

                                Avatar {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 5
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: 20
                                    height: width
                                    avatarSize: height
                                    source: "qrc:/assets/img/jardinier.png"
                                }
                            }
                        }


                    }
                }
            }

            Column {
                id: postListColumn
                width: parent.width
                spacing: 20
                Repeater {
                    model: 4
                    Rectangle {
                        width: postListColumn.width
                        height: postColumn.height
                        radius: 20
                        border {
                            width: 2
                            color: $Colors.gray300
                        }

                        Column {
                            id: postColumn
                            width: parent.width - 20
                            padding: 10

                            Column {
                                width: parent.width

                                RowLayout {
                                    width: parent.width
                                    spacing: 10
                                    Avatar {
                                        Layout.preferredHeight: 70
                                        Layout.preferredWidth: height
                                        source: "qrc:/assets/img/jardinier.png"
                                        onClicked: {
                                            let data = userInfo || {}
                                            data["pubkey"] = publicKey
                                            view.push(userProfile, {
                                                          "profile": data
                                                      })
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Label {
                                            text: "Marry Clermont"
                                            color: $Colors.colorPrimary
                                            font.pixelSize: 14
                                        }
                                        Label {
                                            text: "Il y a 10h"
                                            color: $Colors.gray600
                                            font.pixelSize: 11
                                        }
                                    }

                                    Row {
                                        spacing: 7
                                        IconImage {
                                            source: "qrc:/assets/icons_custom/three-dots-inline.svg"
                                            color: $Colors.gra400
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        IconImage {
                                            source: Qaterial.Icons.heartPlusOutline
                                            color: $Colors.gra400
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width
                                    spacing: 10
                                    Label {
                                        color: Qaterial.Colors.gray600
                                        width: parent.width
                                        wrapMode: Label.Wrap
                                        text: "“Bonsoir à tous, j’espère que vous allez bien. Je vous présente mon nouveau jardin. Nous avons travailler sur l’aménagèrent de ce espace en 3 mois et 10 jours. je vous laisse admirer et laisser moi vos avis en commentaires."
                                    }
                                    Qaterial.ClipRRect {
                                        width: parent.width
                                        height: width * (9/16)
                                        Image {
                                            anchors.fill: parent
                                            source: "qrc:/assets/img/orchidee.jpg"
                                        }
                                    }
                                    RowLayout {
                                        width: parent.width
                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        Repeater {
                                            model: 3
                                            Rectangle {
                                                Layout.preferredHeight: 10
                                                Layout.preferredWidth: height
                                                radius: height/2
                                                border {
                                                    width: 1
                                                    color: $Colors.colorPrimary
                                                }
                                                color: $Colors.gray200
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    anchors.topMargin: 10
                                    Row {
                                        Layout.fillWidth: true
                                        spacing: 5
                                        IconImage {
                                            source: Qaterial.Icons.heart
                                            color: Qaterial.Colors.orange300
                                            width: 30
                                            height: width
                                        }
                                        Label {
                                            color: $Colors.gray600
                                            text: "8.5k"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    Label {
                                        color: $Colors.gray600
                                        text: "1000 commentaires"
                                        Layout.fillWidth: true
                                    }
                                    Label {
                                        color: $Colors.gray600
                                        text: "40 partages"
                                        Layout.fillWidth: true
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 50
                                    radius: 10
                                    border {
                                        width: 1
                                        color: Qaterial.Colors.gray200
                                    }
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        Row {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            IconImage {
                                                source: Qaterial.Icons.heartOutline
                                                color: Qaterial.Colors.gray600
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Rectangle {
                                                Layout.preferredHeight: parent.height
                                                width: 1
                                                color: Qaterial.Colors.gray200

                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            IconImage {
                                                source: Qaterial.Icons.messageOutline
                                                color: Qaterial.Colors.gray600
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Rectangle {
                                                Layout.preferredHeight: parent.height
                                                width: 1
                                                color: Qaterial.Colors.gray200

                                            }
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            IconImage {
                                                source: Qaterial.Icons.shareOutline
                                                color: Qaterial.Colors.gray600
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }

                }
            }
        }
    }

    footer: Rectangle {
        height: 65
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color: $Colors.colorPrimary
                    icon: Qaterial.Icons.homeOutline
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color: Qaterial.Colors.gray600
                    icon: Qaterial.Icons.shareOutline
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                onClicked: page_view.pop()
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 5
                    height: width
                    color: $Colors.colorPrimary
                    icon: "qrc:/assets/icons_custom/blume-circle-green.svg"
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color:Qaterial.Colors.gray600
                    icon: Qaterial.Icons.bellOutline
                }
            }
            Qaterial.SideSquacleButton {
                indicatorPosition: Qaterial.Style.Position.Top
                Layout.fillWidth: true
                leftInset: 0
                rightInset: 0
                Qaterial.Icon {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: width
                    color: Qaterial.Colors.gray600
                    icon: Qaterial.Icons.accountOutline
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            color: "#e0e0e0"
        }
    }

}
