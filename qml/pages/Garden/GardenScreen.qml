import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import QtQuick.Shapes
import QtPositioning

import Qt5Compat.GraphicalEffects as QGE

import SortFilterProxyModel
import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http
import "../../components_js/Utils.js" as Utils
BPage {
    id: control
    objectName: "Garden"
    header: Item {
        height: 30
    }
    backgroundColor: $Colors.colorTertiary

    property var getNextDate: Utils.getNextDate
    property bool isTodoFilterEnd: false
    property bool isLateFilterEnd: false
    property var alarmsIdsToDownStatus: []

    property bool isWeatherLoaded: false
    property variant weatherResponse: undefined

    Component.onCompleted: {
        loadWeather()
    }

    function loadWeather () {
        control.isWeatherLoaded = false
        utilsApp.getMobileLocationPermission()
//        if(!gps.position.coordinate.latitude) {
//            control.isWeatherLoaded = true
//            return
//        }

        const weatherLatLong = `${gps.position.coordinate.latitude},${gps.position.coordinate.longitude}`
        const weatherKey = "56f4ae294928423cade144712232508"
        Http.fetch({
            "url": `http://api.weatherapi.com/v1/forecast.json?key=${weatherKey}&q=${weatherLatLong}&days=3`,
            "method": "GET"
        }).then(function(res) {
            try {
                control.weatherResponse = JSON.parse(res)
                control.isWeatherLoaded = true
                console.log("FIRST weatherResponse ", weatherResponse)
            } catch (e) {
                console.warn(JSON.stringify(e))
            }

        }).catch(function(err) {
            console.warn(JSON.stringify(err))
            control.isWeatherLoaded = true
        })
    }

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

    PositionSource {
        id: gps
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
    }

    Rectangle {
        anchors {
            bottom: parent.top
            bottomMargin: -220
            horizontalCenter: parent.horizontalCenter
        }

        height: 1200
        width: height / 1.7
        radius: height

        gradient: $Colors.gradientPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 0
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 25
            Layout.topMargin: 5

            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: Layout.preferredWidth
                radius: Layout.preferredHeight / 2
                color: $Colors.white


                IconSvg {
                    width: parent.width - 4
                    height: width
                    anchors.centerIn: parent
                    source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                    color: $Colors.colorPrimary
                    MouseArea {
                        anchors.fill: parent
                        onClicked: appDrawer.open()
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                Label {
                    text: qsTr("My Garden")
                    font {
                        pixelSize: 36
                        family: "Courrier"
                        weight: Font.Bold
                    }
                    color: $Colors.white
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    text: qsTr("Manage your personal garden efficiently")
                    opacity: .5
                    color: $Colors.white
                    font {
                        pixelSize: 14
                        family: "Courrier"
                        weight: Font.Bold
                    }
                }
            }
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: Layout.preferredWidth
                radius: Layout.preferredHeight / 2
                color: $Colors.white


                IconSvg {
                    width: parent.width - 4
                    height: width
                    anchors.centerIn: parent
                    source: Icons.bell
                    color: $Colors.colorPrimary
                    MouseArea {
                        anchors.fill: parent
                        onClicked: page_view.push(navigator.loginPage)
                    }
                }
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
                spacing: 10

                Flickable {
                    id: weatherFlickable
                    width: parent.width - 20
                    height: weartherRow.height
                    contentWidth: weartherRow.width

                    Row {
                        id: weartherRow
                        spacing: 10

                        Item {
                            width: weatherFlickable.width - 50
                            height: 180
                            visible: !weatherResponse
                            BusyIndicator {
                                visible: !isWeatherLoaded
                                anchors.centerIn: parent
                            }

                            Column {
                                anchors.centerIn: parent
                                visible: isWeatherLoaded && weatherResponse === undefined

                                Label {
                                    text: qsTr("Weather not loaded !")
                                }

                                NiceButton {
                                    text: qsTr("Reload")
                                    onClicked: loadWeather()
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }


                        }

                        Repeater {
                            model: weatherResponse?.forecast?.forecastday

                            WeatherCard {
                                required property variant modelData
                                required property int index
                                width: weatherFlickable.width - 20
                                height: 180
                                radius: 20
                                dateText: {
                                    switch(index) {
                                    case 0: return qsTr("Today")
                                    case 1: return qsTr("Tomorrow")
                                    case 2: return qsTr("After tomorrow")
                                    default: return (new Date(modelData.date)).toLocaleDateString()
                                    }
                                }

                                weatherData: {
                                    const today = new Date()
                                    for(let i = modelData.hour.length - 1; i >= 0 ; i--) {
                                        if(today >= new Date(modelData.hour[i].time)) {
                                            return modelData.hour[i]
                                        }
                                    }
                                    return modelData.hour[modelData.hour.length-1]
                                }

                                location: weatherResponse.location
                            }
                        }

                    }
                }


                RowLayout {
                    id: _insideControl
                    property string foregroundColor: $Colors.colorPrimary

                    width: parent.width - 20
                    anchors.leftMargin: 15
                    anchors.rightMargin: 20
                    spacing: 20

                    Rectangle {
                            Layout.preferredHeight: 80
                            Layout.preferredWidth: 80
                            radius: 15
                            gradient: $Colors.gradientPrimary
                            ColumnLayout {
                                anchors.centerIn: parent
                                anchors.margins: 5
                                spacing: 7

                                IconSvg {
                                    source: "qrc:/assets/icons_custom/tasks.svg"
                                    Layout.preferredHeight: 30
                                    Layout.preferredWidth: Layout.preferredHeight
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Label {
                                    text: qsTr("Tasks")
                                    font.pixelSize: 16
                                    font.weight: Font.DemiBold
                                    color: $Colors.white
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                            MouseArea {
                                id: _insideMouse
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: "PointingHandCursor"
                                onClicked: {
                                    page_view.push(navigator.gardenAlarmsCalendar)
                                }
                            }
                        }


                    Rectangle {
                            Layout.preferredHeight: 100
                            Layout.preferredWidth: 120
                            radius: 20
                            color: $Colors.colorPrimary

                            Timer {
                                id: animationTimer
                                property double min: 1.0
                                property double max: 1.15
                                property bool up: true
                                interval: 50
                                repeat: true
                                running: $Model.space.count === 0
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

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                IconSvg {
                                    source: "qrc:/assets/icons_custom/house.svg"
                                    color: _insideMouse.containsMouse
                                           || _insideMouse.containsPress ? _insideControl.foregroundColor : $Colors.white
                                    Layout.preferredHeight: 45
                                    Layout.preferredWidth: Layout.preferredHeight
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Label {
                                    text: qsTr("Rooms")
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                    color: _insideMouse.containsMouse
                                           || _insideMouse.containsPress ? _insideControl.foregroundColor : $Colors.white
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                            MouseArea {
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: "PointingHandCursor"
                                onClicked: {
                                    page_view.push(navigator.gardenSpacesList)
                                }
                            }
                        }

                    Rectangle {
                            Layout.preferredHeight: 80
                            Layout.preferredWidth: 80
                            radius: 15
                            gradient: $Colors.gradientPrimary
                            ColumnLayout {
                                anchors.centerIn: parent
                                anchors.margins: 5
                                spacing: 7

                                IconSvg {
                                    source: "qrc:/assets/icons_custom/plant-leaves.svg"
                                    Layout.preferredHeight: 30
                                    Layout.preferredWidth: Layout.preferredHeight
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Label {
                                    text: qsTr("Plantes")
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: $Colors.white
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                            MouseArea {
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: "PointingHandCursor"
                                onClicked: {
                                    page_view.push(navigator.gardenPlantsList)
                                }
                            }
                        }

                }

                Flickable {
                    width: parent.width - 20
                    height: getStartedRow.height
                    contentWidth: getStartedRow.width

                    RowLayout {
                        id: getStartedRow
                        spacing: 10

                        Repeater {
                            model: 4

                            Rectangle {
                                Layout.preferredWidth: 180
                                Layout.preferredHeight: 100
                                Image {
                                    anchors.fill: parent
                                    source: index % 2 === 0 ? "qrc:/assets/img/plant-in-pot-long-leaves.png" : "qrc:/assets/img/plant-with-insect.png"
                                    opacity: 0.95
                                }
                                RowLayout {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 3
                                    width: parent.width - 20
                                    Layout.leftMargin: 10
                                    Layout.rightMargin: 10
                                    spacing: 5

                                    IconSvg {
                                        source: "qrc:/assets/icons_custom/plant-leaves.svg"
                                        Layout.preferredWidth: 45
                                        Layout.preferredHeight: Layout.preferredWidth
                                        color: $Colors.white
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignBottom
                                        color: $Colors.white
                                        text: qsTr("Comment créer une salle ?")
                                        wrapMode: Text.Wrap
                                        font {
                                            weight: Font.Bold
                                            pixelSize: 14
                                        }
                                    }
                                }
                            }
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
                                                                          subtitle = ""
                                                                          + (res.libelle[0] === "'" ? res.libelle.slice(1, -1) : res.libelle)
                                                                      }).catch(
                                            console.warn)

                                return ""
                            }

                            frequency: {
                                const period = Utils.humanizeDayPeriod(model.frequence)
                                qsTr("Each") + " " + period.freq + " " + period.period_label
                            }

                            hideDelete: true

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
                        }
                    }
                }

                Column {
                    id: tipsColum
                    width: parent.width - 20
                    spacing: 10
                    Label {
                        text: qsTr("Tips and advices")
                        width: parent.width
                        color: $Colors.colorPrimary
                        font {
                            weight: Font.DemiBold
                            pixelSize: 16
                        }
                    }

                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            width: parent.width
                            height: 120
                            color: $Colors.colorTertiary
                            radius: 10
                            clip: true
                            border {
                                width: 1
                                color: $Colors.gray200
                            }

                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.preferredWidth: 90
                                    Layout.fillHeight: true
                                    color: $Colors.pink200

                                    Image {
                                        source: "qrc:/assets/icons_custom/tips_child.png"
                                        anchors.fill: parent
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.margins: 5
                                    Label {
                                        text: qsTr("Tips and advices")
                                        font {
                                            pixelSize: 14
                                            weight: Font.DemiBold
                                        }
                                        color: $Colors.white
                                        padding: 5
                                        topPadding: 2
                                        bottomPadding: 2
                                        background: Rectangle {
                                            color: $Colors.colorPrimary
                                            radius: 5
                                        }
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: qsTr("Cultiver son puce vert et suivre son rythme").slice(0, 60)
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        font {
                                            pixelSize: 16
                                            weight: Font.DemiBold
                                        }
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                    }

                                    Label {
                                        text: qsTr("Publié le 13 Aout")
                                        font {
                                            pixelSize: 12
                                        }
                                        background: Rectangle {
                                            color: $Colors.gray200
                                            radius: 2
                                        }
                                        padding: 10
                                        topPadding: 2
                                        bottomPadding: 2
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 100
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Rectangle {
        anchors {
            bottom: parent.bottom
            bottomMargin: 30
            right: parent.right
            rightMargin: 25
        }

        height: 40
        width: height
        radius: height / 2

        gradient: $Colors.gradientPrimary

        Text {
            text: "+"
            anchors.centerIn: parent
            font.pixelSize: 34
            color: $Colors.white
        }

        MouseArea {
            anchors.fill: parent
            onClicked: plusOptionsDrawer.open()
        }
    }

    Drawer {
        id: plusOptionsDrawer
        height: parent.height
        width: parent.width
        background: Rectangle {
            color: $Colors.colorPrimary
            opacity: 0.9
        }

        Column {
            width: parent.width
            anchors {
                bottom: parent.bottom
                bottomMargin: 60
                right: parent.right
                rightMargin: 15
            }
            spacing: 15
            Item {
                width: parent.width
                height: 40
                Row {
                    anchors {
                        right: parent.right
                        rightMargin: 25
                    }
                    spacing: 10
                    Label {
                        text: qsTr("Liste des tâches")
                        color: $Colors.white
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width: 40
                        height: width
                        radius: 5
                        IconSvg {
                            anchors.centerIn: parent
                            anchors.margins: 12
                            source: "qrc:/assets/icons_custom/plant-leaves.svg"
                            color: $Colors.colorPrimary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        plusOptionsDrawer.close()
                        page_view.push(navigator.gardenAlarmsCalendar)
                    }
                }
            }

            Item {
                width: parent.width
                height: 40
                Row {
                    anchors {
                        right: parent.right
                        rightMargin: 25
                    }
                    spacing: 10
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            text: qsTr("Ajouter une nouvelle plante")
                            color: $Colors.white
                            anchors.right: parent.right
                        }
                        Label {
                            text: qsTr("dans votre jardin")
                            color: $Colors.white
                            anchors.right: parent.right
                        }
                    }

                    Rectangle {
                        width: 40
                        height: width
                        radius: 5
                        IconSvg {
                            anchors.centerIn: parent
                            anchors.margins: 12
                            source: "qrc:/assets/icons_custom/plant-leaves.svg"
                            color: $Colors.colorPrimary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
//                    onClicked: {
//                        plusOptionsDrawer.close()
//                        page_view.push(navigator.gardenEditSpace)
//                    }
                }
            }

            Item {
                width: parent.width
                height: 40
                Row {
                    anchors {
                        right: parent.right
                        rightMargin: 25
                    }
                    spacing: 10
                    Label {
                        text: qsTr("Ajouter une salle")
                        color: $Colors.white
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width: 40
                        height: width
                        radius: 5
                        IconSvg {
                            anchors.centerIn: parent
                            anchors.margins: 12
                            source: "qrc:/assets/icons_custom/house.svg"
                            color: $Colors.colorPrimary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        plusOptionsDrawer.close()
                        page_view.push(navigator.gardenEditSpace)
                    }
                }
            }

            Rectangle {
                anchors {
                    right: parent.right
                    rightMargin: 25
                }

                height: 40
                width: height
                radius: height / 2

                gradient: $Colors.gradientPrimary

                Text {
                    text: "x"
                    anchors.centerIn: parent
                    font.pixelSize: 34
                    color: $Colors.white
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: plusOptionsDrawer.close()
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
}
