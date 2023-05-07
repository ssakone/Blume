import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import Qt5Compat.GraphicalEffects as QGE

import "../../components"
import "../../components_generic"
import "../../components_js/Utils.js" as Utils

BPage {
    id: control
    property string name
    property string description
    property int status
    property int type
    property string space_name: name
    required property int space_id

    header: AppBar {
        title: "Space - " + control.space_name
    }

    ListModel {
        id: plantInSpace
    }

    ColumnLayout {
        anchors.fill: parent

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _insideColumn.height

            Column {
                id: _insideColumn
                width: parent.width
                padding: 15
                topPadding: 25
                spacing: 10

                ColumnLayout {
                    width: parent.width - 30
                    spacing: 20

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        radius: 12
                        layer.enabled: true
                        layer.effect: QGE.DropShadow {
                            radius: 2
                            verticalOffset: 1
                            color: "#ccc"
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                Label {
                                    text: "Nombre de plante"
                                    font {
                                        pixelSize: 16
                                        weight: Font.Normal
                                    }
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Label {
                                    text: "0"
                                    font {
                                        pixelSize: 42
                                        family: 'Courrier'
                                        weight: Font.Bold
                                    }
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                                opacity: .4
                                color: "#ccc"
                            }
                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                Label {
                                    text: "Nombre de plante"
                                    font {
                                        pixelSize: 16
                                        weight: Font.Normal
                                    }
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Label {
                                    text: "0"
                                    font {
                                        pixelSize: 42
                                        family: 'Courrier'
                                        weight: Font.Bold
                                    }
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 10
                        leftPadding: 10
                        rightPadding: 10

                        RowLayout {
                            width: parent.width - 20
                            Label {
                                text: "Liste des plantes"
                                Layout.fillWidth: true
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                            }

                            ButtonWireframe {
                                text: "Ajouter"
                                componentRadius: 20
                                fullColor: Theme.colorPrimary
                                fulltextColor: "white"
                                leftPadding: 20
                                rightPadding: leftPadding
                                onClicked: {
                                    $Model.plantSelect.show(function (plant) {
                                        let data = {
                                            "libelle": plant.name_scientific,
                                            "_url": plant.images_plantes.length > 0 ? plant.images_plantes[0].directus_files_id : "",
                                            "remote_id": plant.id,
                                            "uuid": new Date(plant.date_created).getTime(
                                                        ) / 1000
                                        }
                                        data["plant_json"] = JSON.stringify(
                                                    plant)
                                        $Model.plant.sqlCreate(data).then(
                                                    function (new_plant) {
                                                        let inData = {
                                                            "space_id": control.space_id,
                                                            "space_name": control.name,
                                                            "plant_json": data["plant_json"],
                                                            "plant_id": new_plant.id
                                                        }
                                                        $Model.space.plantInSpace.sqlCreate(
                                                                    inData).then(
                                                                    function () {
                                                                        console.info("Done")
                                                                    })
                                                    })
                                    })
                                }
                            }
                        }

                        Repeater {
                            model: $Model.space.plantInSpace
                            GardenPlantLine {
                                property var plant: JSON.parse(plant_json)
                                width: parent.width - 20
                                title: plant.name_scientific
                                visible: model.space_id === control.space_id
                                subtitle: plant.description ?? ""
                                roomName: ""
                                imageSource: plant.images_plantes.length
                                             > 0 ? "https://blume.mahoudev.com/assets/"
                                                   + plant.images_plantes[0].directus_files_id : ""
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 10
                        leftPadding: 10
                        rightPadding: 10

                        RowLayout {
                            width: parent.width - 20
                            Label {
                                text: "Liste des plantes"
                                Layout.fillWidth: true
                            }
                            Item {
                                Layout.fillWidth: true
                            }

                            ButtonWireframe {
                                text: "Ajouter"
                                componentRadius: 20
                                fullColor: Theme.colorPrimary
                                fulltextColor: "white"
                                leftPadding: 20
                                rightPadding: leftPadding
                                onClicked: addAlarmPopup.open()
                            }
                        }

                        Repeater {
                            model: ["Arrosage", "Rampotage"]
                            GardenActivityLine {
                                title: modelData
                                subtitle: "3 plantes"
                                onClicked: console.log("Clicked")
                                icon.source: Icons.water
                                width: parent.width - 20
                                height: 70
                            }
                        }
                    }
                }
            }
        }
    }

    Drawer {
        id: addAlarmPopup
        width: parent.width
        height: parent.height - 20
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
            radius: 18
            BPage {
                anchors.fill: parent
                header: AppBar {
                    title: "New Alarm"
                    leading.icon: Icons.close
                    leading.onClicked: {
                        addAlarmPopup.close()
                    }

                    noAutoPop: true
                }
                Column {
                    width: parent.width - 40
                    padding: 20
                    spacing: 10
                    Item {
                        width: parent.width
                        height: 100
                        Rectangle {
                            width: 200
                            height: 80
                            radius: 8
                            color: $Colors.gray100
                            border.color: $Colors.gray300
                            anchors.centerIn: parent
                            layer.enabled: true
                            layer.effect: QGE.InnerShadow {
                                radius: 1
                                samples: 8
                                color: $Colors.gray400
                                verticalOffset: 2
                            }
                            RowLayout {
                                anchors.fill: parent
                                spacing: 5
                                TextField {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: "00"
                                    font.pixelSize: 48
                                    font.weight: Font.Bold
                                    verticalAlignment: Label.AlignVCenter
                                    horizontalAlignment: Label.AlignHCenter
                                    Layout.minimumWidth: 90
                                    Layout.maximumWidth: 90
                                    background: Item {}
                                    validator: IntValidator {
                                        top: 23
                                        bottom: 0
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            parent.forceActiveFocus()
                                            parent.focus = true
                                            parent.selectAll()
                                        }
                                    }
                                }
                                Label {
                                    text: ":"
                                    font.pixelSize: 42
                                    font.weight: Font.Medium
                                    Layout.alignment: Qt.AlignVCenter
                                    verticalAlignment: Label.AlignVCenter
                                    horizontalAlignment: Label.AlignHCenter
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumWidth: 90
                                    Layout.maximumWidth: 90
                                    text: "00"
                                    font.pixelSize: 48
                                    font.weight: Font.Bold
                                    verticalAlignment: Label.AlignVCenter
                                    horizontalAlignment: Label.AlignHCenter
                                    background: Item {}
                                    validator: IntValidator {
                                        top: 59
                                        bottom: 0
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            parent.forceActiveFocus()
                                            parent.focus = true
                                            parent.selectAll()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        text: "Etiquette"
                    }
                    TextField {
                        width: parent.width
                        height: 50
                        placeholderText: "An alarm description name"
                    }
                    Label {
                        text: "Type"
                    }
                    ComboBox {
                        model: ["Rampotage", 'Arrosage']
                        width: parent.width
                        height: 55
                    }
                    Label {
                        text: "Recurrence"
                    }

                    Row {
                        id: _control
                        property var recurrence: [0, 0, 0, 0, 0, 0, 0]
                        property var day: ["Mon", "Tue", "Wed", "Thu", "Fry", "Sat", "Sun"]
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: parent.day
                            Rectangle {
                                width: (parent.width / 7) - 6
                                height: width
                                radius: width / 2
                                border.color: $Colors.gray200
                                color: _control.recurrence[index] === 1 ? $Colors.gray300 : "white"
                                Label {
                                    anchors.centerIn: parent
                                    text: modelData
                                }

                                MouseArea {
                                    hoverEnabled: true
                                    cursorShape: "PointingHandCursor"
                                    anchors.fill: parent
                                    onClicked: {
                                        let g = _control.recurrence
                                        if (_control.recurrence[index] === 1) {
                                            g[index] = 0
                                        } else
                                            g[index] = 1
                                        _control.recurrence = g
                                        parent.color = g[index] === 1 ? $Colors.gray300 : "white"
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 80
                        border.color: $Colors.gray200
                        radius: 8
                        Label {
                            text: "+ Choose plant"
                            anchors.centerIn: parent
                            opacity: .5
                            font.pixelSize: 16
                        }

                        GardenPlantLine {
                            id: gardenLine
                            property var plant
                            width: parent.width - 10
                            title: plant?.name_scientific ?? ""
                            subtitle: plant?.description ?? ""
                            roomName: ""
                            visible: plant !== undefined
                            imageSource: plant?.images_plantes?.length
                                         > 0 ? "https://blume.mahoudev.com/assets/"
                                               + plant.images_plantes[0].directus_files_id : ""
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: choosePlantPopup.show(function (item) {
                                gardenLine.plant = item
                            })
                        }
                    }
                    Item {
                        height: 5
                        width: 1
                    }

                    NiceButton {
                        text: "Save alarm"
                        width: 160
                        height: 60
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 25
                    }
                }
            }
        }
    }

    Drawer {
        id: choosePlantPopup
        property var callback
        width: parent.width
        height: parent.height - 35
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
        function show(c) {
            choosePlantPopup.callback = c
            open()
        }

        ClipRRect {
            anchors.fill: parent
            radius: 18
            BPage {
                anchors.fill: parent
                header: AppBar {
                    title: "Choose plant"
                    leading.icon: Icons.close
                    leading.onClicked: {
                        choosePlantPopup.close()
                    }

                    noAutoPop: true
                }
                ListView {
                    id: plantListView
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10
                    model: $Model.space.plantInSpace
                    delegate: Item {
                        id: insideControl
                        property var plant: JSON.parse(plant_json)
                        width: inside.width
                        height: inside.height
                        GardenPlantLine {
                            id: inside
                            visible: model.space_id === control.space_id
                            width: plantListView.width - 10
                            title: insideControl.plant.name_scientific
                            subtitle: insideControl.plant.description ?? ""
                            roomName: ""
                            imageSource: insideControl.plant.images_plantes.length
                                         > 0 ? "https://blume.mahoudev.com/assets/"
                                               + insideControl.plant.images_plantes[0].directus_files_id : ""
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                choosePlantPopup.callback(insideControl.plant)
                                choosePlantPopup.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
