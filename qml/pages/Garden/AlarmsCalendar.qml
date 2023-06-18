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

    property int forXDays: 30
    property var startDay: new Date(Utils.humanizeToISOString(new Date()))
    property var endDay: new Date(startDay.getTime(
                                      ) + (forXDays * 1000 * 60 * 60 * 24))

    property bool isLoading: true

    header: AppBar {
        title: qsTr("Calendar")
    }

    Component.onCompleted: {
        //console.log("INIT [control.startDay] ", control.startDay, ' ---> ', control.endDay )
        const query = "SELECT updated_at FROM %1 WHERE updated_at IS NOT NULL AND updated_at != '' AND updated_at > 0 ORDER BY updated_at ASC LIMIT 1 ".arg(
                        $Model.alarm.tableName)
        $Model.alarm.db.executeSql(query).then(function (rs) {
            if (rs.query === true) {
                if ("datas" in rs) {
                    const dateObject = new Date(parseInt(
                                                    rs.datas[0].updated_at * 1000000))
                    const day = dateObject.getDate()
                    const month = dateObject.getMonth()
                    const year = dateObject.getFullYear()

                    startDay = new Date(year, month, day, 0, 0, 0, 0)
                }
            }
            control.fetchMore()
        }).catch(function (err) {
            control.fetchMore()
        })
    }

    ListModel {
        id: calendarAlarmModel
    }

    Timer {
        id: timer
        interval: 3000
        repeat: false
        running: false
        onTriggered: console.log("end")
    }

    function fetchMore() {
        console.log("Fetching more...")
        control.isLoading = true
        const nbAlarms = $Model.alarm.count


        /* should be set among days iterations
            key: alarm index in the '$Model.alarm' model
            value: last date this alarm should have be seen in 'ISOString' format
        */
        const lastDoneHistory = {}

        for (var dayIndex = 0; dayIndex < control.forXDays; dayIndex++) {
            // Today is <dayIndex> days after <control.startDay>
            const todayTimeStamp = control.startDay.getTime(
                                     ) + (dayIndex * 24 * 60 * 60 * 1000)
            const today = new Date(todayTimeStamp)
            console.log(today.toDateString())

            // 'calendarAlarmModel' items structure
            const todayModelItem = {
                "date": today,
                "alarms": []
            }

            for (var i = 0; i < nbAlarms; i++) {
                const currentAlarm = $Model.alarm.get(i)

                let lastDone = null
                if (dayIndex === 0) {
                    let realLastestDoneDate = Utils.getDateBefore(
                            new Date(), currentAlarm.frequence + i)
                    realLastestDoneDate = Utils.humanizeToISOString(
                                realLastestDoneDate)
                    lastDone = new Date(realLastestDoneDate)
                } else {
                    // Already in ISONString format
                    lastDone = new Date(lastDoneHistory[i])
                }

                const nextDate = Utils.getNextDate(lastDone,
                                                   currentAlarm.frequence + i)
                if (dayIndex === 0) {
                    lastDoneHistory[i] = nextDate
                }

                if ((nextDate.toDateString() === today.toDateString())
                        && startDay <= nextDate && nextDate <= endDay) {
                    lastDoneHistory[i]
                            = today //Utils.getNextDate(nextDate, currentAlarm.frequence+i)
                    todayModelItem.alarms.push(currentAlarm)
                }
            }

            if (todayModelItem.alarms.length > 0) {
                calendarAlarmModel.append(todayModelItem)
                //                console.log("found ", calendarAlarmModel.count)
            }
        }
        control.isLoading = false
    }

    ColumnLayout {
        anchors.fill: parent

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _insideColumn.height

            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                visible: false
                onPositionChanged: {
                    if (control.isLoading === false && timer.running === false
                            && (scrollBar.size + scrollBar.position > 0.99)) {
                        control.startDay = Utils.getNextDate(control.startDay,
                                                             control.forXDays)
                        console.log("control.startDay ", control.startDay,
                                    ' ---> ', control.endDay)
                        timer.start()
                        control.fetchMore()
                    }
                }
            }

            Column {
                id: _insideColumn
                width: parent.width
                padding: 15
                topPadding: 25
                spacing: 10

                ColumnLayout {
                    width: parent.width - 20
                    spacing: 20

                    Column {
                        Layout.fillWidth: true
                        spacing: 10
                        leftPadding: 5
                        rightPadding: 5

                        Column {
                            width: parent.width - 10
                            spacing: 30
                            Repeater {
                                model: calendarAlarmModel
                                delegate: Column {
                                    required property var model
                                    required property int index

                                    property var modelData: model

                                    width: parent.width
                                    RowLayout {
                                        width: parent.width
                                        Label {
                                            text: {
                                                //                                                console.log(typeof modelData.date, modelData.date)
                                                return (modelData.date.toDateString(
                                                            ) === (new Date()).toDateString(
                                                            ) ? qsTr("Today") : modelData.date.toLocaleDateString(
                                                                    )) || "NULL"
                                            }

                                            font.pixelSize: 18
                                            Layout.fillWidth: true
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Repeater {
                                        model: modelData.alarms
                                        GardenActivityLine {
                                            required property var model
                                            required property int index

                                            property var plantObj: JSON.parse(
                                                                       model.plant_json)
                                            title: model.libelle || "NULL"
                                            plant_name: plantObj.name_scientific
                                            subtitle: {
                                                $Model.space.sqlGet(
                                                            model.space).then(
                                                            res => {
                                                                subtitle = "Space - " + res.libelle
                                                            }).catch(
                                                            console.warn)
                                                return ""
                                            }

                                            hideCheckbox: true
                                            hideDelete: true

                                            onDeleteClicked: {
                                                removeAlarmPopup.show(model)
                                            }

                                            onChecked: newStatus => {
                                                           isDone = !isDone
                                                       }

                                            icon.source: model.type === 0 ? Icons.shovel : model.type === 1 ? Icons.waterOutline : model.type === 2 ? Icons.potMixOutline : Icons.flowerOutline
                                            image.source: {
                                                let value = plantObj.images_plantes[0] ? "https://blume.mahoudev.com/assets/" + plantObj.images_plantes[0].directus_files_id : ""
                                                return value
                                            }

                                            width: parent.width
                                            height: 80
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
}
