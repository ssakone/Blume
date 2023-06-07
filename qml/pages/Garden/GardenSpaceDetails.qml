import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import SortFilterProxyModel

import Qt5Compat.GraphicalEffects as QGE

import "../../components"
import "../../components_generic"
import "../../components_js/Utils.js" as Utils
import "qrc:/js/UtilsNumber.js" as UtilsNumber
import "../.."

BPage {
    id: control
    property string name
    property string description
    property int status
    property int type
    property string space_name: name
    required property int space_id

    header: AppBar {
        id: header
        title: {
            let text = qsTr("Room") + " - "
                + (control.space_name[0] === "'" ? control.space_name.slice(
                                                       1,
                                                       -1) : control.space_name)
            if (text.length > 20)
                text = text.slice(0, 20) + '...'
            console.log("MITSU ", status)
            return text
        }

        actions: [
            IconSvg {
                source: Icons.pen
                color: $Colors.white
                MouseArea {
                    anchors.fill: parent
                    onClicked: page_view.push(navigator.gardenEditSpace, {
                                                  spaceID: space_id,
                                                  spaceName: control.space_name[0] === "'" ? control.space_name.slice(
                                                                                                 1,
                                                                                                 -1) : control.space_name,
                                                  spaceDescription: control.description[0] === "'" ? control.description.slice(
                                                                                                        1,
                                                                                                        -1) : control.description,
                                                  isOutDoor: type === 1,
                                                  callback: function(updated) {
                                                      if(updated.libelle) header.title = updated.libelle
                                                  }
                                              })
                }
            }
        ]
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
                                subtitle: plant.noms_communs[0]?.name ?? ""
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
                                title: (model.libelle[0] === "'" ? model.libelle.slice(
                                                                       1,
                                                                       -1) : model.libelle)
                                       || "NULL"
                                plant_name: plantObj.name_scientific
                                subtitle: {
                                    $Model.alarm.sqlFormatFrequence(
                                                model.id).then(data => {
                                                                   subtitle = data.freq + " "
                                                                   + data.period_label
                                                               })
                                    return ""
                                }

                                isDone: model.done === 1
                                hideCheckbox: true

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
                                                                       model.done = model.done
                                                                       === 0 ? 1 : 0
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
                                                                                deleteAlarmID).then(
                                                                                () => {
                                                                                    $Model.alarm.clear()
                                                                                    $Model.alarm.fetchAll()
                                                                                })
                                                                        }

                                                                        // Delete devices linked to that plant
                                                                        $Model.device.sqlDeleteAllByPlantID(
                                                                            plant_id).then(
                                                                            function (result) {
                                                                                console.log("\n\nRESULT ", JSON.stringify(result))
                                                                                $Model.device.sqlGetAll().then(function (rs) {
                                                                                    console.log("ALLOA ", rs)
                                                                                    console.log(JSON.stringify(rs))
                                                                                })
                                                                            }).catch(
                                                                            function (err) {
                                                                                console.log("\n\nRESULT err", JSON.stringify(err))
                                                                            })
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
        property bool shouldUpdate: addAlarmPopup.initialAlarm?.space !== undefined

        width: parent.width
        height: parent.height - 90
        edge: Qt.BottomEdge
        dim: false
        modal: true
        interactive: false
        z: 1000
        background: Item {
            Rectangle {
                width: parent.width
                height: parent.height + 60
                radius: 18
            }
        }
        onOpened: {
            console.log("\n ON OPENED")
            const _days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
            let recur = [0, 0, 0, 0, 0, 0, 0]
            for (var i = 0; i < _days.length; i++) {
                const _day = _days[i]
                recur[i] = addAlarmPopup.initialAlarm[_day] === 1 ? 1 : 0
            }

            //            _control.recurrence = recur
            //            frequencyInput.text = addAlarmPopup.initialAlarm.frequence ?? "3"
            gardenLine.plant = JSON.parse(addAlarmPopup.initialAlarm?.plant_json
                                          || 'null') || undefined
            typeAlarm.currentIndex = addAlarmPopup.initialAlarm.type || 0
            if (typeAlarm.currentIndex === 3)
                anotherAlarmType.text = addAlarmPopup.initialAlarm.libelle

            $Model.alarm.sqlFormatFrequence(
                        addAlarmPopup.initialAlarm.id).then(data => {
                                                                frequencyInput.currentIndex
                                                                = data.freq - 1
                                                                periodComboBox.currentIndex
                                                                = data.period_index
                                                                //                                                               periodComboBox.currentIndex = periodComboBox.model.findIndex(it => it === data.period_label)
                                                                //                                                           subtitle = data.freq + " " + data.period_label
                                                            })

            //            console.log("typeAlarm.currentIndex = ", typeAlarm.currentIndex )
            //            console.log("addAlarmPopup.initialAlarm.libelle = ", addAlarmPopup.initialAlarm.libelle)
        }

        onClosed: {
            addAlarmPopup.initialAlarm = {}
            gardenLine.plant = undefined
            anotherAlarmType.text = ""
            frequencyInput.currentIndex = 0
            periodComboBox.currentIndex = 0
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
                ScrollView {
                    anchors.fill: parent
                    contentHeight: _insideColumn2.height

                    Column {
                        id: _insideColumn2
                        width: parent.parent.width - 40
                        padding: 20
                        spacing: 20

                        Label {
                            id: errorView
                            color: $Colors.red
                            visible: text.length > 0
                            text: ""
                        }

                        Label {
                            text: "Task"
                        }

                        Flow {
                            id: typeAlarm
                            width: parent.width

                            property int currentIndex: 0
                            property variant model: [qsTr("Watering"), qsTr(
                                    "Fertilisation"), qsTr("Paddling"), qsTr(
                                    "Cleaning"), qsTr(
                                    "Spraying"), qsTr("Other")]
                            property variant fields_frequences: ['frequence_arrosage', 'frequence_fertilisation', 'frequence_rampotage', 'frequence_nettoyage', 'frequence_vaporisation']
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
                            onAccepted: focus = false
                            onEditingFinished: focus = false
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

                                subtitle: plant?.noms_communs[0]?.name ?? ""
                                roomName: ""
                                visible: plant !== undefined
                                imageSource: plant?.images_plantes?.length
                                             > 0 ? "https://blume.mahoudev.com/assets/"
                                                   + plant.images_plantes[0].directus_files_id : ""
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: choosePlantPopup.show(
                                               function (item) {
                                                   gardenLine.plant = item
                                               })
                            }
                        }

                        RowLayout {
                            id: _control
                            width: parent.width
                            spacing: 10

                            Label {
                                text: qsTr("Every")
                            }

                            TumblerThemed {
                                id: frequencyInput
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 150

                                model: UtilsNumber.range(1, 31)
                            }

                            ComboBox {
                                id: periodComboBox
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                model: ["Days", "Weeks", "Months", "Years"]
                                popup {
                                    z: 10000
                                }

                                background: Rectangle {
                                    color: $Colors.gray200
                                    radius: 10
                                }
                            }
                        }

                        RowLayout {
                            visible: gardenLine.plant !== undefined
                                     && typeAlarm.currentIndex < typeAlarm.model.length - 1
                            width: parent.width
                            Label {
                                visible: recommandation_value.text !== ""
                                text: qsTr("Recommandations: ")
                                font {
                                    weight: Font.Light
                                    pixelSize: 16
                                }
                            }
                            Label {
                                id: recommandation_value
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                text: {
                                    if (typeAlarm.currentIndex < typeAlarm.model.length - 1) {
                                        const freq_field = typeAlarm.fields_frequences[typeAlarm.currentIndex]
                                        let plant_json = gardenLine.plant?.plant_json
                                        if (!plant_json)
                                            plant_json = gardenLine.plant // So it comes from local DB with fields 'libelle', 'done', 'frequence', ...
                                        return plant_json ? (plant_json[freq_field]
                                                             ?? "") : ""
                                    }
                                    return ""
                                }
                                font {
                                    weight: Font.Light
                                    pixelSize: 16
                                }
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

                                let freq = parseInt(
                                        frequencyInput.currentIndex + 1)
                                if (periodComboBox.currentIndex === 1) {
                                    // Weekly
                                    freq *= 7
                                } else if (periodComboBox.currentIndex === 2) {
                                    // Monthly
                                    freq *= 30
                                } else if (periodComboBox.currentIndex === 3) {
                                    // Yearly
                                    freq *= 365
                                }

                                let data = {
                                    "frequence": freq,
                                    "libelle": typeAlarm.currentIndex === typeAlarm.model.length
                                               - 1 ? anotherAlarmType.text : typeAlarm.model[typeAlarm.currentIndex],
                                    "type": typeAlarm.currentIndex,
                                    "space": control.space_id,
                                    "plant": gardenLine.plant.id,
                                    "plant_json": JSON.stringify(
                                                      gardenLine.plant)
                                }

                                console.log("Data ", JSON.stringify(data))

                                if (addAlarmPopup.shouldUpdate) {
                                    $Model.alarm.sqlUpdate(
                                                addAlarmPopup.initialAlarm.id,
                                                data).then(function (res) {
                                                    gardenLine.plant = undefined
                                                    $Model.alarm.clear()
                                                    $Model.alarm.fetchAll()
                                                    addAlarmPopup.close()
                                                }).catch(err => console.error(
                                                             JSON.stringify(
                                                                 err)))
                                } else {
                                    data['last_done'] = Utils.humanizeToISOString(
                                                new Date())
                                    $Model.alarm.sqlCreate(data).then(
                                                function (res) {
                                                    console.info(
                                                                "New alarm created ",
                                                                data['last_done'],
                                                                res['last_done'],
                                                                ' id=',
                                                                typeof res['id'],
                                                                res['id'])
                                                    $Model.alarm.sqlGet(
                                                                res['id'])?.then(
                                                                function (r) {
                                                                    console.log("Mamamilla ")
                                                                    console.log(r['libelle'], typeof r['last_done'], r['last_done'])
                                                                })?.catch(
                                                                function (e) {
                                                                    console.log("ERR (()) ")
                                                                    console.log(JSON.stringify(e))
                                                                })
                                                    gardenLine.plant = undefined
                                                    addAlarmPopup.close()
                                                }).catch(function (err) {
                                                    console.error(
                                                                "COOL **",
                                                                JSON.stringify(
                                                                    err))
                                                    console.log("Raw ", err)
                                                    console.log("Raw msg ",
                                                                err?.message)
                                                })
                                }
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
                            subtitle: insideControl.plant.noms_communs[0]?.name
                                      ?? ""
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
