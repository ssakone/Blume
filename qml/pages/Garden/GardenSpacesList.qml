import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../../components"
import "../../components_generic"

BPage {
    id: control
    header: AppBar {
        title: "Mes espaces"
    }

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        clip: true
        model: $Model.space
        spacing: 10
        delegate: GardenSpaceLine {
            width: parent.width
            height: 85
            title: libelle
            subtitle: description
            iconSource: type === 1 ? Icons.homeOutline : Icons.landFields
            onClicked: {
                let data = {
                    "name": libelle,
                    "type": type,
                    "description": description,
                    "status": model.status ?? 0,
                    "space_id": id
                }
                page_view.push(navigator.gardenSpaceDetails, data)
            }
        }
    }

    Drawer {
        id: addSpacePopup
        width: parent.width
        height: Qt.platform.os == "ios" ? parent.height - 45 : parent.height - 20
        edge: Qt.BottomEdge
        dim: true
        modal: true
        z: 1000
        background: Item {
            Rectangle {
                width: parent.width
                height: parent.height + 60
                radius: 18
            }
        }
        ClipRRect {
            anchors.fill: parent
            anchors.margins: -1
            radius: 18
            BPage {
                anchors.fill: parent
                header: AppBar {
                    title: "Nouvelle space"
                    statusBarVisible: false
                    leading.icon: Icons.close
                    leading.onClicked: {
                        addAlarmPopup.close()
                    }

                    noAutoPop: true
                }
                Column {
                    width: parent.width - padding
                    padding: 10
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    TextField {
                        id: spaceName
                        width: parent.width - (parent.padding * 2)
                        height: 50
                        placeholderText: "Nom de l'espace"
                    }

                    Column {
                        width: parent.width - 20
                        spacing: 5
                        Label {
                            text: "Une description"
                            opacity: .5
                        }
                        TextArea {
                            id: descriptionArea
                            width: parent.width
                            height: 100
                        }
                    }

                    Column {
                        width: parent.width - 20
                        spacing: 5
                        Label {
                            text: "Type d'espace"
                            opacity: .5
                        }
                        ComboBox {
                            id: typeSpace
                            width: parent.width
                            height: 50
                            model: ["Espace ouverte", "Espace fermer"]
                        }
                    }
                    NiceButton {
                        text: "Enregistrer"
                        width: 160
                        height: 60
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        onClicked: {
                            let data = {
                                "libelle": spaceName.text,
                                "description": descriptionArea.text,
                                "type": typeSpace.currentIndex
                            }

                            $Model.space.sqlCreate(data).then(function (rs) {
                                console.log(JSON.stringify(rs))
                                spaceName.text = ""
                                addSpacePopup.close()
                            }).catch(function (err) {
                                console.log("error", err)
                            })
                        }
                    }
                }
            }
        }
    }
    ButtonWireframe {
        height: 60
        width: 60
        fullColor: Theme.colorPrimary
        componentRadius: 30
        anchors {
            bottom: parent.bottom
            bottomMargin: 30

            right: parent.right
            rightMargin: 20
        }

        Text {
            text: "+"
            color: "white"
            font.pixelSize: 32
            anchors.centerIn: parent
        }

        onClicked: addSpacePopup.open()
    }
}
