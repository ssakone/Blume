import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import QtQuick.Shapes

import Qt5Compat.GraphicalEffects as QGE

import SortFilterProxyModel
import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http
import "../../components_js/Utils.js" as Utils
BPage {
    id: control
    objectName: "Garden"
    header: AppBar {
        title: "Blume"
        isHomeScreen: true
    }

    property var getNextDate: Utils.getNextDate
    property bool isTodoFilterEnd: false
    property bool isLateFilterEnd: false
    property var alarmsIdsToDownStatus: []

    SortFilterProxyModel {
        id: alarmsTodoToday
        sourceModel: $Model.alarm
        filters: ExpressionFilter {
            expression:  {
                let today = new Date()
                let modelData = alarmsTodoToday.sourceModel.get(index)
                let frequency = modelData.frequence
                let lastDone = modelData.last_done

                if (lastDone) {
                    if(lastDone[0] === "'") {
                        lastDone = lastDone.slice(1, -1)
                    }
                    lastDone = new Date(lastDone)
                    let diff = today - lastDone
                    let diffDays = Math.floor(diff/(1000*60*60*24))

                    if((diffDays-frequency) === 0 && modelData.done === 1) {
                        alarmsIdsToDownStatus.push(modelData.id)
                        return true
                    }
                    if (diffDays === 0) {
                        return true
                    }

                    return false
                }
                else return true
            }
        }
    }

    SortFilterProxyModel {
        id: alarmsLate
        sourceModel: $Model.alarm
        filters: ExpressionFilter {
            expression:  {
                let today = new Date()
                let modelData = alarmsLate.sourceModel.get(index)
                let frequency = modelData.frequence
                let lastDone = alarmsTodoToday.sourceModel.get(index).last_done

                if (lastDone) {
                    if(lastDone[0] === "'") {
                        lastDone = lastDone.slice(1, -1)
                    }

                    lastDone = new Date(lastDone)
                    let diff = today - lastDone
                    let diffDays = Math.floor(diff/(1000*60*60*24))
                    if(index === $Model.alarm.count -1) isLateFilterEnd = true
                    if((diffDays-frequency) > 0) {
                        alarmsIdsToDownStatus.push(modelData.id)
                        return true
                    } else if((diffDays-frequency) === 0 && modelData.done === 0) {
                        return true
                    }

                    return false

                }
                return false

            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 0

        Column {
            Layout.fillWidth: true
            padding: 25
            topPadding: 5
            Label {
                text: qsTr("My Garden")
                font {
                    pixelSize: 36
                    family: "Courrier"
                    weight: Font.Bold
                }
            }
            Label {
                text: qsTr("Manage your personal garden efficiently")
                opacity: .5
                font {
                    pixelSize: 16
                    family: "Courrier"
                    weight: Font.Bold
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 20
            spacing: 20

            Repeater {
                model: [{
                        "icon": Icons.flowerTulip,
                        "title": qsTr("My plants"),
                        "action": "plants"
                    }, {
                        "icon": Icons.viewDashboardOutline,
                        "title": qsTr("Rooms"),
                        "action": "spaces",
                        "animate": alarmsTodoToday.count === 0 && alarmsLate.count === 0
                    }, {
                        "icon": Icons.alarm,
                        "title": qsTr("Calendar"),
                        "action": "alarm"
                    }]
                delegate: Rectangle {
                    id: _insideControl
                    property string foregroundColor: Theme.colorPrimary
                    Layout.preferredHeight: 100
                    Layout.fillWidth: true
                    radius: 20
                    layer.enabled: true
                    layer.effect: QGE.DropShadow {
                        radius: 4
                        color: $Colors.gray300
                        verticalOffset: 2
                    }

                    Timer {
                        id: animationTimer
                        property double min: 1.0
                        property double max: 1.15
                        property bool up: true
                        interval: 50
                        repeat: true
                        running: modelData.animate === true
                        onTriggered: {
                            if(up) {
                                if(parent.scale <= max) {
                                    parent.scale += 0.01
                                } else {
                                    up = false
                                }
                            } else {
                                if(parent.scale >= min) {
                                    parent.scale -= 0.01
                                } else {
                                    up = true
                                }
                            }

                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 50
                            easing.type: Easing.InOutCubic
                        }
                    }

                    scale: _insideMouse.containsMouse
                           || _insideMouse.containsPress ? 1.05 : 1

                    color: _insideMouse.containsMouse
                           || _insideMouse.containsPress ? "white" : foregroundColor
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Item {
                            ColorImage {
                                anchors.centerIn: parent
                                width: 42
                                height: 42
                                source: modelData.icon
                                color: _insideMouse.containsMouse
                                       || _insideMouse.containsPress ? _insideControl.foregroundColor : $Colors.white
                            }
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        Label {
                            text: modelData.title
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: _insideMouse.containsMouse
                                   || _insideMouse.containsPress ? _insideControl.foregroundColor : $Colors.white
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    MouseArea {
                        id: _insideMouse
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"
                        onClicked: {
                            switch (modelData.action) {
                            case "plants":
                                page_view.push(navigator.gardenPlantsList)
                                break
                            case "spaces":
                                page_view.push(navigator.gardenSpacesList)
                                break
                            case "alarm":
                                page_view.push(navigator.gardenAlarmsCalendar)
                                break
                            }
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("Tasks")
            padding: 15
            opacity: .7
            font {
                pixelSize: 16
                weight: Font.Medium
            }
        }

        Flickable {
            Layout.minimumHeight: 400
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentHeight: alarmsCol.height
            clip: true

            Column {
                id: alarmsCol
                width: parent.width
                leftPadding: 10
                rightPadding: 10

                Column {
                    visible: alarmsTodoToday.count === 0 && alarmsLate.count === 0
                    width: parent.width
                    spacing: 10

                    layer.enabled: true
                    layer.effect: QGE.ColorOverlay {
                        color: Qt.rgba(100, 30, 89, 0.8)
                    }

                    Label {
                        text: qsTr("Today")
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            weight: Font.Light
                            pixelSize: 16
                        }
                    }

                    Repeater {
                        model: 3
                        GardenActivityLine {

                            title: qsTr("Watering")
                            plant_name: "Abelia Chinensis"

                            subtitle: qsTr("Terasse")

                            isDone: true

                            hideDelete: true
                            hideCheckbox: true
                            icon.source: Icons.waterOutline
//                          icon.source: model.type === 0 ? Icons.shovel : model.type === 1 ? Icons.waterOutline : model.type === 2 ? Icons.potMixOutline : Icons.flowerOutline
                            //                            image.source: {
//                                let value = plantObj.images_plantes[0] ? "https://blume.mahoudev.com/assets/" + plantObj.images_plantes[0].directus_files_id : ""
//                                return value
//                            }

                            width: parent.width - 20
                            height: 80
                        }
                    }
                }

                Column {
                    visible: alarmsLate.count > 0
                    width: parent.width
                    spacing: 10

                    Label {
                        text: qsTr("Lates")
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            weight: Font.Light
                            pixelSize: 16
                        }
                    }
                    Repeater {
                        model: alarmsLate
                        GardenActivityLine {
                            property var plantObj: JSON.parse(model.plant_json)
                            property var lateDetails: ({})

                            title: model.libelle || "NULL"
                            plant_name: plantObj.name_scientific

                            subtitle: {
                                const today = new Date()
                                const last_done = new Date(model.last_done.slice(1, -1))
                                let diff = today - last_done
                                let diffDays = Math.floor(diff/(1000*60*60*24))

                                if(diffDays > model.frequence) {
                                    const delay = diffDays - model.frequence
                                    const formated = Utils.humanizeDayPeriod(delay)
                                    lateDetails = formated
                                    return `<font color='${$Colors.red500}'> ${lateDetails.freq < 10 ? '0'+lateDetails.freq : lateDetails.freq} ${lateDetails.period_label} ${qsTr("late")} </font>`
                                }

                                return `<font color='${$Colors.red500}'>${qsTr("Task late")} </font>`
                            }
                            isDone: {
                                if(alarmsIdsToDownStatus.filter(x => x.id === model.id).length > 0 ) {
                                    return false
                                }
                                return model.done === 1
                            }

                            onDeleteClicked: {
                                removeAlarmPopup.show(model)
                            }

                            onChecked: newStatus => {
                                           $Model.alarm.sqlUpdateTaskStatus(
                                               model.id, newStatus).then(res => {
                                                                             model.done =  model.done === 0 ? 1 : 0
                                                                         }).catch(
                                               console.warn)
                                       }

                            icon.source: model.type === 0 ? Icons.shovel : model.type === 1 ? Icons.waterOutline : model.type === 2 ? Icons.potMixOutline : Icons.flowerOutline
                            image.source: {
                                let value = plantObj.images_plantes[0] ? "https://blume.mahoudev.com/assets/" + plantObj.images_plantes[0].directus_files_id : ""
                                return value
                            }

                            width: parent.width - 20
                            height: 80
                        }
                    }

                    Rectangle {
                        width: parent.width - 20
                        height: 5
                        color: $Colors.gray200
                    }

                }

                Column {
                    visible: alarmsTodoToday.count > 0
                    width: parent.width
                    spacing: 10

                    Label {
                        text: qsTr("Today")
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            weight: Font.Light
                            pixelSize: 16
                        }
                    }

                    Repeater {
                        model: alarmsTodoToday
                        GardenActivityLine {
                            property var plantObj: JSON.parse(model.plant_json)

                            title: (model.libelle[0]==="'" ? model.libelle.slice(1, -1): model.libelle) || "NULL"
                            plant_name: plantObj.name_scientific

                            subtitle: {
                                $Model.space.sqlGet(model.space).then(function(res) {
                                                                          subtitle = "Space - "
                                                                          + (res.libelle[0] === "'" ? res.libelle.slice(1, -1) : res.libelle)
                                                                      }).catch(
                                            console.warn)

                                return ""
                            }

                            isDone: {
                                if(alarmsIdsToDownStatus.filter(id => id === model.id).length > 0 ) {
                                    return false
                                }
                                return model.done === 1
                            }

                            onDeleteClicked: {
                                removeAlarmPopup.show(model)
                            }

                            onChecked: newStatus => {
                                           $Model.alarm.sqlUpdateTaskStatus(
                                               model.id, newStatus).then(res => {
                                                                             model.done = model.done === 0 ? 1 : 0
                                                                         }).catch(
                                               console.warn)
                                       }

                            icon.source: model.type === 0 ? Icons.shovel : model.type === 1 ? Icons.waterOutline : model.type === 2 ? Icons.potMixOutline : Icons.flowerOutline
                            image.source: {
                                let value = plantObj.images_plantes[0] ? "https://blume.mahoudev.com/assets/" + plantObj.images_plantes[0].directus_files_id : ""
                                return value
                            }

                            width: parent.width - 20
                            height: 80
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 200
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Label {
        text: qsTr("No pending task")
        visible: alarmsTodoToday.count === 0 && alarmsLate.count === 0
        color: Theme.colorSecondary
        opacity: 0.8
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 120
        font {
            weight: Font.Bold
            pixelSize: 18
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
}
