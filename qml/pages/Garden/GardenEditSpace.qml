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
//    background.color: Qt.rgba(12, 200, 25, 0)


    header: AppBar {
        id: header
        title: shouldCreate ? qsTr("Créer une nouvelle salle") : qsTr("Modifier la salle")

        ButtonWireframeIcon {
            visible: spaceID
            height: 36
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            primaryColor: $Colors.red300
            secondaryColor: Qt.rgba(0, 0, 0, 0)
            fulltextColor: $Colors.colorPrimary

            background: Item {}

            source: Icons.trashCan
            sourceSize: 30

            onClicked: confirmRoomDeletionPopup.open()
        }
    }
    Flickable {
        anchors.fill: parent
        contentHeight: _insideCol.height
        Column {
            id: _insideCol
            padding: 10
            width: parent.width - 2*padding
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
                                width: parent.width - 20
                                height: parent.height - 20
                                fullColor: true
                                primaryColor: index === rowPlaces.currentIndex ? $Colors.colorPrimary : $Colors.gray50
                                fulltextColor: index === rowPlaces.currentIndex ? "white" : $Colors.colorPrimary
                                componentRadius: 10


                                onClicked: {
                                    rowPlaces.currentIndex = index
                                    spaceNameItem.text = modelData.title
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.componentRadius
                                    color: Qt.rgba(0, 0, 0, 0)
                                    border {
                                        color: $Colors.colorPrimary
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
                                horizontalAlignment: Text.AlignLeft
                                leftPadding: 10
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

            Row {
                topPadding: 30
                spacing: 7
                IconSvg {
                    source: Icons.home
                    color: $Colors.colorPrimary
                    width: 20
                    height: 20
                }

                Label {
                    text: qsTr("Information sur la salle")
                    opacity: .5
                }
            }
            Column {
                width: parent.width - 20
                leftPadding: 10
                rightPadding: 10
                spacing: 15


                TextField {
                    id: spaceNameItem
                    text: spaceName
                    width: parent.width - 20
                    height: 50
                    font.pixelSize: 16
                    placeholderText: qsTr("Entrez le nom de votre salle ici !")
                    verticalAlignment: Text.AlignVCenter
                    padding: 5
                    background: Rectangle {
                        radius: 10
                        color: "#ECFBF4"
                        border {
                            width: 1
                            color: $Colors.colorPrimary
                        }
                    }
                }

                TextArea {
                    id: descriptionArea
                    text: spaceDescription
                    width: parent.width - 20
                    height: 100
                    font.pixelSize: 16
                    background: Rectangle {
                        radius: 10
                        color: "#ECFBF4"
                        border {
                            width: 1
                            color: $Colors.colorPrimary
                        }

                        Text {
                            visible: descriptionArea.text === ""
                            opacity: .5
                            text: qsTr("Description de la salle")
                            font.pixelSize: 16
                            anchors {
                                top: parent.top
                                left: parent.left
                                margins: 10
                            }
                        }
                    }
                }
            }


            Column {
                width: parent.width - 20
                spacing: 5

                Row {
                    topPadding: 30
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

    }

    NiceButton {
        text: shouldCreate ? qsTr("Continuer") : qsTr("Update")
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
            function generateUUID() {
                // Public Domain/MIT
                var d = new Date().getTime()
                //Timestamp
                var d2 = ((typeof performance !== 'undefined')
                          && performance.now
                          && (performance.now(
                                  ) * 1000)) || 0
                //Time in microseconds since page-load or 0 if unsupported
                return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
                            /[xy]/g, function (c) {
                                var r = Math.random(
                                            ) * 16
                                //random number between 0 and 16
                                if (d > 0) {
                                    //Use timestamp until depleted
                                    r = (d + r) % 16 | 0
                                    d = Math.floor(
                                                d / 16)
                                } else {
                                    //Use microseconds since page-load if supported
                                    r = (d2 + r) % 16 | 0
                                    d2 = Math.floor(
                                                d2 / 16)
                                }
                                return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(
                                            16)
                            })
            }

            let spaceFormData = {
                "libelle": spaceNameItem.text,
                "description": descriptionArea.text,
                "type": typeSpace.currentIndex
            }
            if(shouldCreate) {
                if(spaceFormData.libelle === "") return
                $Model.plantSelect.show(function (plant) {
                    // 1. Create the space
                    $Model.space.sqlCreate(spaceFormData).then(function (createdSpace) {
                        let currentSpace = $Model.space.get($Model.space.count-1)

                        // 2. Create plant in local DB
                        let plantData = {
                            "libelle": plant.name_scientific,
                            "image_url": "-1",
                            "remote_id": plant.id,
                            "uuid": generateUUID()
                        }
                        plantData["plant_json"] = JSON.stringify(
                                    plant)
                        $Model.plant.sqlCreate(plantData).then(
                                    function (new_plant) {
                                        // 3. Link plant to space
                                        let inData = {
                                            "plant_json": plantData["plant_json"],
                                            "space_id": currentSpace.id,
                                            "space_name": currentSpace.libelle,
                                            "plant_id": new_plant.id
                                        }
                                        console.log("inData ", JSON.stringify(inData))
                                        $Model.space.plantInSpace.sqlCreate(
                                                    inData).then(
                                                    function () {
                                                        // Navigate to another page
                                                        console.info("Done")

                                                        callback(spaceFormData)
                                                        header.backButtonClicked()
                                                        page_view.push(navigator.gardenSpaceDetails, {"space_id": currentSpace.id, "space_name": currentSpace.libelle})
                                                    }).catch(console.log)
                                    })

                    }).catch(function (err) {
                        console.log("error creare", err)
                    })
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
