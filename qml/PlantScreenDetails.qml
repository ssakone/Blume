import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
//import PlantUtils 1.0
import "qrc:/js/UtilsPlantDatabase.js" as UtilsPlantDatabase
import "components"

Popup {
    id: plantScreenDetailsPopup
    width: appWindow.width
    height: appWindow.height

    x: -30

    property variant plant: ({})

    background: Rectangle {
        radius: 18
    }

    onOpened: console.log(" plant--- ",  plant.sites, plant.name_scientific, plant['name_scientific'], plant.sites !== null)

    Rectangle {
        color: "#00c395"
        height: 65
        width: plantScreenDetailsPopup.width
        y: -70
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
                        plantScreenDetailsPopup.close()
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

    ScrollView {
        height: plantScreenDetailsPopup.height
        ColumnLayout {
            width: plantScreenDetailsPopup.width - 10
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            spacing: 10

            Rectangle {
                Layout.minimumHeight: 110
                Layout.leftMargin: 25
                width: parent.width - 35
                color: Theme.colorPrimary
                radius: 15
                ColumnLayout {
                    id: col_header
                    anchors.fill: parent
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Label {
                        text: plant.name_scientific
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 15
                        color: Qt.rgba(0, 0, 0, 0) // '#72dae8'
                        Layout.leftMargin: 10
                        RowLayout {
                            Layout.preferredHeight: 40
                            Label {
                                text: "Nom botanique: "
                                font.pixelSize: 14
                                color: "white"
                            }
                            Label {
                                text: "Caldiusm"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                color: "white"
                            }

                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        Layout.leftMargin: 10
                        radius: 15
                        color: Qt.rgba(0, 0, 0, 0)
                        RowLayout {
                            Layout.preferredHeight: 40
                            Label {
                                text: "Nom commun: "
                                font.pixelSize: 14
                                color: "white"
                            }
                            Label {
                                text: "Caldiusm"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                color: "white"
                            }

                        }
                    }
                }
            }

            ScrollView {
                width: plantScreenDetailsPopup.width - 30
                RowLayout {
                   spacing: 7

                    Rectangle {
                        width: 120
                        height: 70
                        radius: 15
                        color: '#d3dbd8'
                        ColumnLayout {
                            anchors.fill: parent

                            spacing: 5
                            Label {
                                text: "Soin"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Medium"
                                font.pixelSize: 14
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Rectangle {
                        width: 120
                        height: 70
                        radius: 15
                        color: '#d3dbd8'
                        ColumnLayout {
                            anchors.fill: parent

                            spacing: 5
                            Label {
                                text: "Soin"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Medium"
                                font.pixelSize: 14
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Rectangle {
                        width: 120
                        height: 70
                        radius: 15
                        color: '#d3dbd8'
                        ColumnLayout {
                            anchors.fill: parent

                            spacing: 5
                            Label {
                                text: "Soin"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Medium"
                                font.pixelSize: 14
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }


                }

            }


            ColumnLayout {
                width: parent.width
                spacing: 0

                Rectangle {
                    width: parent.width
                    Layout.minimumHeight: 40

                    color: Theme.colorPrimary
                    radius: 5

                    RowLayout {
                        Layout.fillWidth: true
                        width: parent.width
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: "Type de plante"
                            color: "white"
                            font.pixelSize: 14

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                        Label {
                            text: plant["sites"]

                            color: "white"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    Layout.minimumHeight: 40


                    RowLayout {
                        width: parent.width
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: "Exposition au soleil"
                            font.pixelSize: 14
                            color: Theme.colorPrimary

                            width: parent.width / 2
                            Layout.alignment: Qt.AlignVCenter
                            Layout.maximumWidth: width
                        }
                        Label {
                            text: plant['exposition_au_soleil']
                            color: Theme.colorPrimary
                            font.pixelSize: 14
                            font.weight: Font.DemiBold

                            width: parent.width / 2
                            Layout.maximumWidth: width
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    Layout.minimumHeight: 40

                    color: Theme.colorPrimary
                    radius: 5

                    RowLayout {
                        Layout.fillWidth: true
                        width: parent.width
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: "Type de sol"
                            color: "white"
                            font.pixelSize: 14

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                        Label {
                            text: plant['type_de_sol']
                            color: "white"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    Layout.minimumHeight: 40


                    RowLayout {
                        width: parent.width
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: "Couleur"
                            font.pixelSize: 14
                            color: Theme.colorPrimary

                            width: parent.width / 2
                            Layout.alignment: Qt.AlignVCenter
                            Layout.maximumWidth: width
                        }
                        Label {
                            text: plant['couleur']
                            color: Theme.colorPrimary
                            font.pixelSize: 14
                            font.weight: Font.DemiBold

                            width: parent.width / 2
                            Layout.maximumWidth: width
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    Layout.minimumHeight: 40

                    color: Theme.colorPrimary
                    radius: 5

                    RowLayout {
                        Layout.fillWidth: true
                        width: parent.width
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: "Zonee de rusticité"
                            color: "white"
                            font.pixelSize: 14

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                        Label {
                            text: plant['zone_de_rusticite']
                            color: "white"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    Layout.minimumHeight: 40


                    RowLayout {
                        width: parent.width
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: "Toxicité"
                            font.pixelSize: 14
                            color: Theme.colorPrimary

                            width: parent.width / 2
                            Layout.alignment: Qt.AlignVCenter
                            Layout.maximumWidth: width
                        }
                        Label {
                            text: plant['toxicity'] ? 'Plante toxique' : 'Non toxique'
                            color: Theme.colorPrimary
                            font.pixelSize: 14
                            font.weight: Font.DemiBold

                            width: parent.width / 2
                            Layout.maximumWidth: width
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    Layout.minimumHeight: 40

                    color: Theme.colorPrimary
                    radius: 5

                    RowLayout {
                        Layout.fillWidth: true
                        width: parent.width
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: "PH"
                            color: "white"
                            font.pixelSize: 14

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                        Label {
                            text: plant['ph']
                            color: "white"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold

                            width: parent.width / 2
                            horizontalAlignment: Text.AlignLeft
                            Layout.maximumWidth: width
                            wrapMode: Text.Wrap
                        }
                    }
                }


            }

            ScrollView {
                width: plantScreenDetailsPopup.width
                ListView {
                    layoutDirection: Qt.Horizontal
                    spacing: 5
                    model: plant['images_plantes']
                    delegate: Label {
                        text: modelData
                    }
                }
            }

            ColumnLayout {
                width: plantScreenDetailsPopup.width - 30
                spacing: 5


                Accordion {
                    header: "Présentation des plantes"
                    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ut mi eu dui pellentesque convallis quis vitae enim. Aliquam cursus fringilla est, vel interdum eros lobortis at. Duis id libero sem. Praesent turpis sapien, hendrerit eu ipsum in, suscipit euismod velit. Nulla ultricies venenatis eros eu ultrices. Etiam ut mauris non purus convallis pretium. Aliquam eget justo vel tortor blandit pulvinar. Pellentesque malesuada id justo ut eleifend. Duis dolor quam, vulputate sed libero et, volutpat vestibulum nibh. Cras interdum leo vel lorem lacinia, ac accumsan tellus pulvinar. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Phasellus risus lectus, volutpat et erat convallis, iaculis elementum sem. "

                }


                Accordion {
                    header: "Présentation des plantes"
                    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ut mi eu dui pellentesque convallis quis vitae enim. Aliquam cursus fringilla est, vel interdum eros lobortis at. Duis id libero sem. Praesent turpis sapien, hendrerit eu ipsum in, suscipit euismod velit. Nulla ultricies venenatis eros eu ultrices. Etiam ut mauris non purus convallis pretium. Aliquam eget justo vel tortor blandit pulvinar. Pellentesque malesuada id justo ut eleifend. Duis dolor quam, vulputate sed libero et, volutpat vestibulum nibh. Cras interdum leo vel lorem lacinia, ac accumsan tellus pulvinar. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Phasellus risus lectus, volutpat et erat convallis, iaculis elementum sem. "

                }

                Accordion {
                    header: "Présentation des plantes"
                    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ut mi eu dui pellentesque convallis quis vitae enim. Aliquam cursus fringilla est, vel interdum eros lobortis at. Duis id libero sem. Praesent turpis sapien, hendrerit eu ipsum in, suscipit euismod velit. Nulla ultricies venenatis eros eu ultrices. Etiam ut mauris non purus convallis pretium. Aliquam eget justo vel tortor blandit pulvinar. Pellentesque malesuada id justo ut eleifend. Duis dolor quam, vulputate sed libero et, volutpat vestibulum nibh. Cras interdum leo vel lorem lacinia, ac accumsan tellus pulvinar. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Phasellus risus lectus, volutpat et erat convallis, iaculis elementum sem. "

                }

            }
        }

    }
}
