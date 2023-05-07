import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import SortFilterProxyModel

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
        title: qsTr("Room") + " - " + control.space_name
    }

    SortFilterProxyModel {
        id: plantInSpace
        sourceModel: $Model.space.plantInSpace
        filters: ValueFilter {
            value: control.space_id
            roleName: "space_id"
        }
    }

    SortFilterProxyModel {
        id: alarmInSpace
        sourceModel: $Model.alarm
        filters: ValueFilter {
            value: control.space_id
            roleName: "space"
        }
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
                                    text: "Plants"
                                    font {
                                        pixelSize: 16
                                        weight: Font.Normal
                                    }
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Label {
                                    text: plantInSpace.count
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
                                    text: "Tasks"
                                    font {
                                        pixelSize: 16
                                        weight: Font.Normal
                                    }
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Label {
                                    text: alarmInSpace.count
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
                        id: _colLayout
                        Layout.fillWidth: true
                        spacing: 10
                        leftPadding: 10
                        rightPadding: 10

                        RowLayout {
                            width: parent.width - 20
                            Label {
                                text: qsTr("Plants in the room")
                                Layout.fillWidth: true
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                            }

                            ButtonWireframe {
                                text: qsTr("Add new")
                                componentRadius: 20
                                fullColor: Theme.colorPrimary
                                fulltextColor: "white"
                                leftPadding: 20
                                rightPadding: leftPadding
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
                                    $Model.plantSelect.show(function (plant) {
                                        let data = {
                                            "libelle": plant.name_scientific,
                                            "image_url": "-1",
                                            "remote_id": plant.id,
                                            "uuid": generateUUID()
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
                            model: plantInSpace
                            GardenPlantLine {
                                property var plant: JSON.parse(plant_json)
                                width: _colLayout.width - 20
                                height: 100
                                title: plant.name_scientific
                                subtitle: plant.description ?? ""
                                roomName: ""
                                onClicked: {
                                    removePlantPopup.show({
                                                              "id": model.id,
                                                              "name_scientific": plant.name_scientific
                                                          })
                                }

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
                                text: qsTr("Tasks")
                                Layout.fillWidth: true
                            }
                            Item {
                                Layout.fillWidth: true
                            }

                            ButtonWireframe {
                                text: qsTr("Add new")
                                componentRadius: 20
                                fullColor: Theme.colorPrimary
                                fulltextColor: "white"
                                leftPadding: 20
                                rightPadding: leftPadding
                                onClicked: addAlarmPopup.open()
                            }
                        }

                        Repeater {
                            model: alarmInSpace
                            GardenActivityLine {
                                title: model.libelle === "" ? (model.type === 0 ? "Rampotage" : "Arrosage") : model.libelle
                                subtitle: model.type === 0 ? "Rampotage" : "Arrosage"
                                onClicked: {
                                    removeAlarmPopup.show(model)
                                }

                                icon.source: Icons.water
                                width: parent.width - 20
                                height: 70
                                hours: model.hours.toString().padStart(2, '0')
                                minutes: model.minute.toString().padStart(2,
                                                                          '0')
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: removeAlarmPopup
        property var alarm
        anchors.centerIn: parent
        width: 300
        height: 160
        dim: true
        modal: true
        function show(al) {
            alarm = al
            open()
        }

        Column {
            anchors.centerIn: parent
            spacing: 20
            Label {
                text: qsTr("Remove this task ?")
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
                        $Model.alarm.sqlDelete(removeAlarmPopup.alarm.id)
                        removeAlarmPopup.close()
                    }
                }
                NiceButton {
                    text: qsTr("No")
                    width: 100
                    height: 50
                    onClicked: removeAlarmPopup.close()
                }
            }
        }
    }

    Popup {
        id: removePlantPopup
        property var plant
        anchors.centerIn: parent
        width: 300
        height: 160
        dim: true
        modal: true
        function show(pl) {
            plant = pl
            open()
        }

        Column {
            anchors.centerIn: parent
            spacing: 20
            Label {
                text: qsTr("Remove") + " " + removePlantPopup.plant?.name_scientific
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
                        $Model.space.plantInSpace.sqlDelete(
                                    removePlantPopup.plant.id)
                        removePlantPopup.close()
                    }
                }
                NiceButton {
                    text: qsTr("No")
                    width: 100
                    height: 50
                    onClicked: removePlantPopup.close()
                }
            }
        }
    }

    Drawer {
        id: addAlarmPopup
        width: parent.width
        height: parent.height - 45
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
                    title: qsTr("New task")
                    statusBarVisible: false
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
                                    id: _hours
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
                                    onTextChanged: errorView.text = ""
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
                                    id: _minutes
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
                                    onTextChanged: errorView.text = ""
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
                        id: errorView
                        color: $Colors.red
                        visible: text.length > 0
                        text: ""
                    }

                    Label {
                        text: qsTr("Task name")
                    }
                    TextField {
                        id: etiquette
                        width: parent.width
                        height: 50
                        placeholderText: "A description"
                    }
                    Label {
                        text: "Type"
                    }
                    ComboBox {
                        id: typeAlarm
                        width: parent.width
                        height: 55
                        model: ["Rampotage", "Arrosage"]
                    }
                    Label {
                        text: qsTr("Days")
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
                            text: "+ " + qsTr("Choose plant")
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
                        text: qsTr("Save task")
                        width: 160
                        height: 60
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 25
                        onClicked: {
                            if (parseInt(_minutes.text) > 59) {
                                errorView.text = "The minutes can't reach 60"
                                return
                            }

                            if (parseInt(_hours.text) > 23) {
                                errorView.text = "The hours can't reach 24"
                                return
                            }

                            if (gardenLine.plant === undefined) {
                                errorView.text = "No plant choosed"
                                return
                            }

                            let data = {
                                "mon": _control.recurrence[0],
                                "tue": _control.recurrence[1],
                                "wed": _control.recurrence[2],
                                "thu": _control.recurrence[3],
                                "fri": _control.recurrence[4],
                                "sat": _control.recurrence[5],
                                "sun": _control.recurrence[6],
                                "libelle": etiquette.text,
                                "minute": _minutes.text,
                                "hours": _hours.text,
                                "type": typeAlarm.currentIndex,
                                "space": control.space_id,
                                "plant_json": JSON.stringify(gardenLine.plant)
                            }
                            $Model.alarm.sqlCreate(data).then(function (res) {
                                console.info("First alarm created")
                                addAlarmPopup.close()
                                _control.recurrence = [0, 0, 0, 0, 0, 0, 0]
                                etiquette.text = ""
                                _hours.text = ""
                                _minutes.text = ""
                                gardenLine.plant = null
                            }).catch(err => console.error(JSON.stringify(err)))
                        }
                    }
                }
            }
        }
    }

    Drawer {
        id: choosePlantPopup
        property var callback
        width: parent.width
        height: parent.height - 55
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
            anchors.margins: -1
            radius: 18
            BPage {
                anchors.fill: parent
                header: AppBar {
                    title: qsTr("Choose plant")
                    statusBarVisible: false
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
                    model: plantInSpace
                    delegate: Item {
                        id: insideControl
                        property var plant: JSON.parse(plant_json)
                        width: inside.width
                        height: inside.height
                        GardenPlantLine {
                            id: inside
                            width: plantListView.width - 10
                            height: 100
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
