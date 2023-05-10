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
//                        leftPadding: 10
//                        rightPadding: 10

                        RowLayout {
                            width: parent.width - 10
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
                                property var plant: {
                                    console.log(plant_json)
                                    return JSON.parse(plant_json)
                                }

                                width: _colLayout.width - 10
                                height: 100
                                title: plant.name_scientific
                                subtitle: plant.description ?? ""
                                roomName: ""
                                onClicked: {
                                    removePlantPopup.show({
                                                              "id": model.id,
                                                              "name_scientific": plant.name_scientific,
                                                              "origin_id": plant.id
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
                                property var plantObj: JSON.parse(
                                                           model.plant_json)
                                title: model.libelle || "NULL"
                                plant_name: plantObj.name_scientific
                                subtitle: {
                                    let countPerWeek = 0
                                    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
                                    for (let _dayIndex in days) {
                                        if (model[days[_dayIndex]] === 1)
                                            countPerWeek++
                                    }

                                    return countPerWeek + ' ' + qsTr(
                                                "times par week")
                                }
                                isDone: model.done

                                onDeleteClicked: {
                                    removeAlarmPopup.show(model)
                                }
                                onClicked: {
                                    addAlarmPopup.initialAlarm = model
                                    addAlarmPopup.open()
                                }

                                onChecked: newStatus => {
                                               $Model.alarm.sqlUpdateTaskStatus(
                                                   model.id,
                                                   newStatus).then(res => {
                                                                       $Model.alarm.fetchAll()
                                                                   }).catch(
                                                   console.warn)
                                           }

                                icon.source: model.type === 0 ? Icons.shovel : model.type === 1 ? Icons.waterOutline : model.type === 2 ? Icons.potMixOutline : Icons.flowerOutline
                                image.source: {
                                    let value = plantObj.images_plantes[0] ? "https://blume.mahoudev.com/assets/" + plantObj.images_plantes[0].directus_files_id : ""
                                    return value
                                }

                                width: parent.width - 10
                                height: 80
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
                        $Model.alarm.sqlDelete(
                                    removeAlarmPopup.alarm.id).then(res => {
                                                                        if ($Model.alarm.count === 1) {
                                                                            $Model.alarm.clear()
                                                                            $Model.alarm.fetchAll()
                                                                        }
                                                                    })

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

        SortFilterProxyModel {
            id: alarmsForPlantInSpace
            sourceModel: $Model.alarm
            filters: [
                ValueFilter {
                    value: control.space_id
                    roleName: "space"
                },
                ValueFilter {
                    value: {
                        return removePlantPopup.plant?.origin_id || 0
                    }

                    roleName: "plant"
                }
            ]
        }

        Column {
            anchors.centerIn: parent
            spacing: 20
            Column {
                width: parent.width
                Label {
                    text: qsTr("Remove") + " " + removePlantPopup.plant?.name_scientific
                    font.pixelSize: 16
                }
                Label {
                    text: alarmsForPlantInSpace.count + " " + qsTr(
                              "Related tasks will also be removed")
                    font.pixelSize: 16
                    visible: alarmsForPlantInSpace.count > 0
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                NiceButton {
                    text: qsTr("Yes remove")
                    width: 120
                    height: 50
                    backgroundColor: $Colors.red500
                    onClicked: {
                        const plant_id = removePlantPopup.plant.id
                        $Model.space.plantInSpace.sqlDelete(
                                    removePlantPopup.plant.id).then(res => {
                                                                        // A trouble occured when going to delete the last plant.
                                                                        // So we clear() and fecthAll() to solved that case
                                                                        if ($Model.space.plantInSpace.count === 1) {
                                                                            $Model.space.plantInSpace.clear()
                                                                            $Model.space.plantInSpace.fetchAll()
                                                                        }

                                                                        // Delete alarms related to that plant in current space
                                                                        for (var i = 0; i < alarmsForPlantInSpace.count; i++) {
                                                                            const deleteAlarmID = alarmsForPlantInSpace.get(i).id
                                                                            $Model.alarm.sqlDelete(
                                                                                deleteAlarmID).then(() => {
                                                                                                        $Model.alarm.clear()
                                                                                                        $Model.alarm.fetchAll()
                                                                                                    })
                                                                        }
                                                                    })

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
        property var initialAlarm: ({})
        property bool shouldUpdate: addAlarmPopup.initialAlarm.space !== undefined

        width: parent.width
        height: parent.height - 90
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
        onOpened: {
            const _days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
            let recur = [0, 0, 0, 0, 0, 0, 0]
            for (var i = 0; i < _days.length; i++) {
                const _day = _days[i]
                recur[i] = addAlarmPopup.initialAlarm[_day] === 1 ? 1 : 0
            }
            _control.recurrence = recur
            gardenLine.plant = JSON.parse(addAlarmPopup.initialAlarm?.plant_json
                                          || 'null') || undefined
            typeAlarm.currentIndex = addAlarmPopup.initialAlarm.type || 0
            if (typeAlarm.currentIndex === 3)
                anotherAlarmType.text = addAlarmPopup.initialAlarm.libelle

            //            console.log("typeAlarm.currentIndex = ", typeAlarm.currentIndex )
            //            console.log("addAlarmPopup.initialAlarm.libelle = ", addAlarmPopup.initialAlarm.libelle)
        }

        onClosed: {
            addAlarmPopup.initialAlarm = {}
            gardenLine.plant = undefined
            anotherAlarmType.text = ""
            _control.recurrence = [0, 0, 0, 0, 0, 0, 0]
        }

        ClipRRect {
            anchors.fill: parent
            anchors.margins: -1
            radius: 18
            BPage {
                anchors.fill: parent
                header: AppBar {
                    title: addAlarmPopup.shouldUpdate ? qsTr("Update task ") : qsTr(
                                                            "New task")
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

                    Label {
                        id: errorView
                        color: $Colors.red
                        visible: text.length > 0
                        text: ""
                    }

                    Label {
                        text: "Task"
                    }
                    Flickable {
                        width: parent.width
                        height: typeAlarm.height
                        contentWidth: typeAlarm.width

                        Row {
                            id: typeAlarm

                            property int currentIndex: 0
                            property variant model: ["Rampotage", "Arrosage", "Fertilisation", "Autre"]

                            spacing: 20

                            Repeater {
                                model: typeAlarm.model
                                delegate: ButtonWireframe {
                                    text: modelData
                                    fullColor: true
                                    primaryColor: index === typeAlarm.currentIndex ? Theme.colorPrimary : $Colors.gray300
                                    fulltextColor: index === typeAlarm.currentIndex ? "white" : Theme.colorPrimary
                                    font.pixelSize: 14
                                    componentRadius: implicitHeight / 2
                                    onClicked: {
                                        typeAlarm.currentIndex = index
                                        if (typeAlarm.currentIndex === typeAlarm.model.length - 1)
                                            anotherAlarmType.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }

                    TextField {
                        id: anotherAlarmType
                        visible: typeAlarm.currentIndex === typeAlarm.model.length - 1
                        width: parent.width
                        height: 60
                        text: ""
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        verticalAlignment: Label.AlignVCenter
                        background: Rectangle {
                            radius: 10
                            color: $Colors.gray200
                        }
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
                                required property var modelData
                                required property int index
                                width: (parent.width / 7) - 6
                                height: width
                                radius: width / 2
                                border.color: Theme.colorPrimary
                                border.width: {
                                    //                                    console.log("_control.recurrence[index] ", index, _control.recurrence[index])
                                    return _control.recurrence[index] === 1 ? 1 : 0
                                }

                                color: _control.recurrence[index] === 1 ? $Colors.gray200 : "white"
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
                                            _control.recurrence[index] = 0
                                        } else
                                            _control.recurrence[index] = 1
                                        _control.recurrence = g
                                        //                                        parent.color = g[index] === 1 ? $Colors.gray300 : "white"
                                        //                                        parent.border.width = g[index]
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 80
                        radius: 8
                        Label {
                            text: "+ " + qsTr("Choose plant")
                            anchors.centerIn: parent
                            opacity: .5
                            font.pixelSize: 16
                            visible: gardenLine.plant === undefined
                        }

                        GardenPlantLine {
                            id: gardenLine
                            property var plant

                            anchors.fill: parent
                            title: {
                                return plant?.name_scientific ?? ""
                            }

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
                                console.log(addAlarmPopup.initialAlarm.plant_json)
                                gardenLine.plant = item
                            })
                        }
                    }
                    Item {
                        height: 5
                        width: 1
                    }

                    NiceButton {
                        text: addAlarmPopup.shouldUpdate ? qsTr("Update task") : qsTr(
                                                               "Save task")
                        width: 160
                        height: 60
                        radius: height / 2
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 25
                        onClicked: {
                            if (gardenLine.plant === undefined) {
                                errorView.text = "No plant choosed"
                                return
                            }

                            //                            if(addAlarmPopup.shouldUpdate) {
                            //                                errorView.text = "'Task Update' is not net implemented"
                            //                                return
                            //                            }
                            let data = {
                                "mon": _control.recurrence[0],
                                "tue": _control.recurrence[1],
                                "wed": _control.recurrence[2],
                                "thu": _control.recurrence[3],
                                "fri": _control.recurrence[4],
                                "sat": _control.recurrence[5],
                                "sun": _control.recurrence[6],
                                "libelle": typeAlarm.currentIndex === typeAlarm.model.length
                                           - 1 ? anotherAlarmType.text : typeAlarm.model[typeAlarm.currentIndex],
                                "type": typeAlarm.currentIndex,
                                "space": control.space_id,
                                "plant": gardenLine.plant.id,
                                "plant_json": JSON.stringify(gardenLine.plant)
                            }

                            if (addAlarmPopup.shouldUpdate) {
                                $Model.alarm.sqlUpdate(
                                            addAlarmPopup.initialAlarm.id,
                                            data).then(function (res) {
                                                gardenLine.plant = undefined
                                                $Model.alarm.clear()
                                                $Model.alarm.fetchAll()
                                                addAlarmPopup.close()
                                            }).catch(err => console.error(
                                                         JSON.stringify(err)))
                            } else {
                                $Model.alarm.sqlCreate(data).then(
                                            function (res) {
                                                console.info(
                                                            "New alarm created")
                                                gardenLine.plant = undefined
                                                addAlarmPopup.close()
                                            }).catch(err => console.error(
                                                         JSON.stringify(err)))
                            }
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
                    anchors.margins: 10
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
