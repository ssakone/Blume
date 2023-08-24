import QtQuick
import QtQuick.Controls
import "../../components_generic"
import "../../components"

BPage {
    property int spaceID
    property string spaceName: ""
    property string spaceDescription: ""
    property bool isOutDoor: false
    property bool shouldCreate: spaceName === "" && spaceDescription === ""
    property var callback: function () {}

    background.opacity: 0.5
    header: AppBar {
        id: header
        title: shouldCreate ? qsTr("New room") : qsTr("Update room")
        statusBarVisible: false
        leading.icon: Icons.close

        ButtonWireframeIcon {
            visible: spaceID
            height: 36
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            primaryColor: $Colors.white
            secondaryColor: Qt.rgba(0, 0, 0, 0)

            background: Item {}

            source: Icons.trashCan
            sourceSize: 30

            onClicked: confirmRoomDeletionPopup.open()
        }
    }
    Column {
        width: parent.width - padding
        padding: 10
        spacing: 15
        anchors.horizontalCenter: parent.horizontalCenter

        Row {
            spacing: 7
            IconSvg {
                source: Icons.mapMarker
                color: $Colors.colorPrimary
                width: 20
                height: 20
            }

            Label {
                visible: shouldCreate
                text: qsTr("Choose the place")
                opacity: .5
            }
        }


        Flickable {
            visible: shouldCreate
            width: parent.width - 20
            height: rowPlaces.height
            contentWidth: rowPlaces.width

            Row {
                id: rowPlaces
                property int currentIndex: -1
                property variant model: [
                    {
                        title: qsTr("Salon"),
                        iconName: "qrc:/assets/icons_custom/salon.svg"
                    },
                    {
                        title: qsTr("Jardin"),
                        iconName: "qrc:/assets/icons_custom/garden.svg"
                    },
                    {
                        title: qsTr("Chambre"),
                        iconName: "qrc:/assets/icons_custom/bed.svg"
                    },
                    {
                        title: qsTr("Cuisine"),
                        iconName: Icons.scissorsCutting
                    }
                ]
                spacing: 10
                Repeater {
                    model: rowPlaces.model
                    delegate: Item {
                        width: 80
                        height: 80
                        ButtonWireframe {
                            width: parent.width
                            height: parent.height - 20
                            fullColor: true
                            primaryColor: index === rowPlaces.currentIndex ? $Colors.colorPrimary : $Colors.gray50
                            fulltextColor: index === rowPlaces.currentIndex ? "white" : $Colors.colorPrimary
                            componentRadius: 10


                            onClicked: {
                                rowPlaces.currentIndex = index
                                spaceNameItem.text = modelData
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.componentRadius
                                color: Qt.rgba(0, 0, 0, 0)
                                border {
                                    color: $Colors.gray300
                                    width: 1
                                }
                            }

                            IconSvg {
                                source: modelData.iconName
                                color: index === rowPlaces.currentIndex ? "white" : $Colors.colorPrimary
                                anchors.centerIn: parent
                            }
                        }

                        Label {
                            text: modelData.title
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            wrapMode: Text.Wrap
                            font {
                                weight: Font.DemiBold
                            }
                        }
                    }
                }
            }
        }

        Label {
            text: qsTr("Room name")
            opacity: .5
        }
        TextField {
            id: spaceNameItem
            text: spaceName
            width: parent.width - (parent.padding * 2)
            height: 50
            verticalAlignment: Text.AlignVCenter
            padding: 5
            background: Rectangle {
                radius: 10
                color: $Colors.green100
            }
        }

        Column {
            width: parent.width - 20
            spacing: 5
            Label {
                text: qsTr("Description")
                opacity: .5
            }
            TextArea {
                id: descriptionArea
                text: spaceDescription
                width: parent.width
                height: 100
                background: Rectangle {
                    radius: 10
                    color: $Colors.green100
                }
            }
        }

        Column {
            width: parent.width - 20
            spacing: 5

            Row {
                spacing: 7
                IconSvg {
                    source: Icons.wall
                    color: $Colors.colorPrimary
                    width: 20
                    height: 20
                }

                Label {
                    text: qsTr("Room type")
                    opacity: .5
                }
            }

            Flickable {
                width: parent.width
                height: typeSpace.height
                contentWidth: typeSpace.width

                Row {
                    id: typeSpace

                    property int currentIndex: isOutDoor ? 1 : 0
                    property variant model: [qsTr("Indoor"), qsTr("Outdoor")]

                    spacing: 20

                    Repeater {
                        model: typeSpace.model
                        delegate: ButtonWireframe {
                            text: modelData
                            fullColor: true
                            primaryColor: index === typeSpace.currentIndex ? $Colors.colorPrimary : $Colors.gray300
                            fulltextColor: index === typeSpace.currentIndex ? "white" : $Colors.colorPrimary
                            font.pixelSize: 14
                            componentRadius: implicitHeight / 2
                            onClicked: typeSpace.currentIndex = index
                        }
                    }
                }
            }

        }
    }

    NiceButton {
        text: shouldCreate ? qsTr("Save") : qsTr("Update")
        height: 60
        radius: 30
        anchors {
            right: parent.right
            rightMargin: 20

            left: parent.left
            leftMargin: 20

            bottom: parent.bottom
            bottomMargin: 10
        }
        onClicked: {
            let data = {
                "libelle": spaceNameItem.text,
                "description": descriptionArea.text,
                "type": typeSpace.currentIndex
            }
            if(shouldCreate) {
                if(data.libelle === "") return
                $Model.space.sqlCreate(data).then(function (rs) {
                    console.log(JSON.stringify(rs))
                    callback(data)
                    header.backButtonClicked()
                }).catch(function (err) {
                    console.log("error creare", err)
                })
            } else if(spaceID) {
                if(spaceName === "" && spaceNameItem.text === "") return
                if(spaceDescription === descriptionArea.text) delete data["description"]
                if(spaceName === spaceNameItem.text) delete data["libelle"]
                if(isOutDoor === false && typeSpace.currentIndex === 1) delete data["type"]
                if(isOutDoor === true && typeSpace.currentIndex === 0) delete data["type"]

                if(Object.keys(data).length > 0) {
                    $Model.space.sqlUpdate(spaceID, data).then(function (rs) {
                        $Model.space.clear()
                        $Model.space.fetchAll()
                        callback(data)
                        header.backButtonClicked()
                    }).catch(function (err) {
                        console.log("error uprare", err)
                    })
                } else {
                    header.backButtonClicked()
                }

            }

        }
    }

    Popup {
        id: confirmRoomDeletionPopup
        anchors.centerIn: parent
        width: 300
        height: 160
        dim: true
        modal: true

        Column {
            anchors.centerIn: parent
            spacing: 20
            Label {
                text: qsTr("Remove this room ?")
                font.pixelSize: 16
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                NiceButton {
                    text: qsTr("Yes remove")
                    width: 120
                    height: 50
                    onClicked: {

                        $Model.space.plantInSpace.sqlDeleteFromSpaceID(
                                    spaceID).then(res => {
                                                                $Model.space.plantInSpace.clear()
                                                                $Model.space.plantInSpace.fetchAll()

                                    })


                        $Model.alarm.sqlDeleteFromSpaceID(
                                    spaceID).then(res => {
                                                                $Model.alarm.clear()
                                                                $Model.alarm.fetchAll()

                                    })

                        $Model.space.sqlDelete(
                                    spaceID).then(res => {
//                                                                        if ($Model.space.count === 1) {
                                                                            $Model.space.clear()
                                                                            $Model.space.fetchAll()
//                                                                        }
                                                                    })
                        confirmRoomDeletionPopup.close()
                        page_view.pop()
                        page_view.pop()
                    }
                }
                NiceButton {
                    text: qsTr("No")
                    width: 100
                    height: 50
                    onClicked: confirmRoomDeletionPopup.close()
                }
            }
        }
    }

}
