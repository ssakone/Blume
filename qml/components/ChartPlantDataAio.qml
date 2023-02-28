import QtQuick
import QtCharts

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: chartPlantDataAio
    anchors.fill: parent

    property bool useOpenGL: true
    property bool showGraphDots: settingsManager.graphAioShowDots
    property color legendColor: Theme.colorSubText

    property int daysTarget: settingsManager.graphAioDays
    property int daysVisible: settingsManager.graphAioDays
    property int daysTick: isPhone ? 4 : settingsManager.graphAioDays

    Connections {
        target: settingsManager
        function onGraphAioDaysChanged() {
            updateGraph()
            clickableGraphArea.forceUpdate()

            //var av07 = (currentDevice.countDataNamed("temperature", 7) > 1)
            //var av14 = av07 || (currentDevice.countDataNamed("temperature", 14) > 1)
            //var av31 = av14 || (currentDevice.countDataNamed("temperature", 31) > 1)
        }
    }

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartPlantDataAio // loadGraph() >> " + currentDevice)

        hygroData.visible = currentDevice.hasSoilMoistureSensor && currentDevice.hasDataNamed("soilMoisture")
        conduData.visible = currentDevice.hasSoilConductivitySensor && currentDevice.hasDataNamed("soilConductivity")
        hygroData.visible |= currentDevice.hasHumiditySensor && currentDevice.hasDataNamed("humidity")
        tempData.visible = currentDevice.hasTemperatureSensor
        lumiData.visible = currentDevice.hasLuminositySensor

        dateIndicator.visible = false
        dataIndicator.visible = false
        verticalIndicator.visible = false

        legendColor = Qt.rgba(legendColor.r, legendColor.g, legendColor.b, 0.8)
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartPlantDataAio // updateGraph() >> " + currentDevice)

        //// DATA
        if (currentDevice.isPlantSensor) {
            currentDevice.getChartData_plantAIO(daysTarget, axisTime, hygroData, conduData, tempData, lumiData)
        } else if (currentDevice.isThermometer) {
            currentDevice.getChartData_thermometerAIO(daysTarget, axisTime, tempData, hygroData)
        }

        // graph visibility
        aioGraph.visible = (tempData.count > 1)
        showGraphDots = (settingsManager.graphAioShowDots && tempData.count < 16)

        //// AXIS
        axisHygro.min = 0
        axisHygro.max = 100
        axisTemp.min = 0
        axisTemp.max = 60
        axisCondu.min = 0
        axisCondu.max = 2000
        axisLumi.min = 1
        axisLumi.max = 100000

        // Min/Max axis for hygrometery / humidity
        if (currentDevice.isPlantSensor) {
            if (currentDevice.hygroMin*0.85 < 0.0) axisHygro.min = 0
            else axisHygro.min = currentDevice.hygroMin*0.85
            if (currentDevice.hygroMax*1.15 > 100.0) axisHygro.max = 100
            else axisHygro.max = currentDevice.hygroMax*1.15
        }
        if (currentDevice.isThermometer) {
            if (currentDevice.humiMin*0.85 < 0.0) axisHygro.min = 0
            else axisHygro.min = currentDevice.humiMin*0.85
            if (currentDevice.humiMax*1.15 > 100.0) axisHygro.max = 100
            else axisHygro.max = currentDevice.humiMax*1.15
        }

        // Min/Max axis for temperature
        axisTemp.min = currentDevice.tempMin*0.85
        axisTemp.max = currentDevice.tempMax*1.15

        // Max axis for conductivity
        axisCondu.max = currentDevice.conduMax*2.0

        // Max axis for luminosity?
        axisLumi.max = currentDevice.luxMax*3.0

        //// ADJUSTMENTS
        hygroData.width = 2
        tempData.width = 2

        if (currentDevice.isPlantSensor) {
            // not planted? don't show hygro and condu
            hygroData.visible = currentDevice.hasSoilMoistureSensor && currentDevice.hasDataNamed("soilMoisture")
            conduData.visible = currentDevice.hasSoilConductivitySensor && currentDevice.hasDataNamed("soilConductivity")
        }

        // Update indicator (only works if data are changed in database though...)
        if (dateIndicator.visible) updateIndicator()
    }

    function qpoint_lerp(p0, p1, x) { return (p0.y + (x - p0.x) * ((p1.y - p0.y) / (p1.x - p0.x))) }

    ////////////////////////////////////////////////////////////////////////////

    ChartView {
        id: aioGraph
        anchors.fill: parent
        anchors.topMargin: -28
        anchors.leftMargin: -24
        anchors.rightMargin: -24
        anchors.bottomMargin: -24

        antialiasing: true
        legend.visible: false
        backgroundColor: Theme.colorBackground
        backgroundRoundness: 0
        dropShadowEnabled: false
        animationOptions: ChartView.NoAnimation

        ValueAxis { id: axisHygro; visible: false; gridVisible: false; }
        ValueAxis { id: axisCondu; visible: false; gridVisible: false; }
        ValueAxis { id: axisTemp; visible: false; gridVisible: false; }
        ValueAxis { id: axisLumi; visible: false; gridVisible: false; }
        DateTimeAxis { id: axisTime; visible: true;
                       labelsFont.pixelSize: Theme.fontSizeContentVerySmall; labelsColor: legendColor;
                       color: legendColor; tickCount: daysTick;
                       gridLineColor: Theme.colorSeparator; }

        LineSeries {
            id: hygroData
            useOpenGL: useOpenGL
            pointsVisible: showGraphDots
            color: Theme.colorBlue; width: 2;
            axisY: axisHygro; axisX: axisTime;
        }
        LineSeries {
            id: conduData
            useOpenGL: useOpenGL
            pointsVisible: showGraphDots
            color: Theme.colorRed; width: 2;
            axisY: axisCondu; axisX: axisTime;
        }
        LineSeries {
            id: tempData
            useOpenGL: useOpenGL
            pointsVisible: showGraphDots
            color: Theme.colorGreen; width: 2;
            axisY: axisTemp; axisX: axisTime;
        }
        LineSeries {
            id: lumiData
            useOpenGL: useOpenGL
            pointsVisible: showGraphDots
            color: Theme.colorYellow; width: 2;
            axisY: axisLumi; axisX: axisTime;
        }

        ////////////////

        MouseArea {
            id: clickableGraphArea
            anchors.fill: aioGraph

            acceptedButtons: (Qt.LeftButton | Qt.RightButton)

            onClicked: (mouse) => {
                if (isMobile) {
                    if (mouse.button === Qt.LeftButton) {
                        lastMouseMap = mouse
                        aioGraph.moveIndicator(mouse, false)
                        mouse.accepted = true
                    } else if (mouse.button === Qt.RightButton) {
                        resetIndicator()
                    }
                }
            }

            onPressAndHold: {
                if (isMobile) {
                    smsmsm.showHide()
                }
            }

            onPressed: (mouse) => {
                if (isDesktop) {
                    if (mouse.button === Qt.LeftButton) {
                        lastMouseMap = mouse
                        aioGraph.moveIndicator(mouse, false)
                        mouse.accepted = true
                    } else if (mouse.button === Qt.RightButton) {
                        resetIndicator()
                    }
                }
            }
            onReleased: (mouse) =>{
                if (typeof (plantSensorPages) !== "undefined") {
                    // Re-enable page swipe after we dragged the indicator
                    plantSensorPages.interactive = isPhone
                }

                if (mouse.button !== Qt.RightButton) {
                    vanim.duration = 233
                }
            }

            onPositionChanged: (mouse) => {
                if (isDesktop || verticalIndicator.visible) {

                    if (typeof (plantSensorPages) !== "undefined") {
                        // Disable page swipe while we drag the indicator
                        plantSensorPages.interactive = false
                    }

                    vanim.duration = 0

                    lastMouseMap = mouse
                    aioGraph.moveIndicator(lastMouseMap, true)
                    mouse.accepted = true
                }
            }

            property var lastMouseMap: null
            function forceUpdate() { aioGraph.moveIndicator(lastMouseMap, true) }
        }

        function moveIndicator(mouse, isMoving) {
            var mmm = Qt.point(mouse.x, mouse.y)

            // we adjust coordinates with graph area margins
            var ppp = Qt.point(mouse.x, mouse.y)
            ppp.x = ppp.x + aioGraph.anchors.rightMargin
            ppp.y = ppp.y - aioGraph.anchors.topMargin

            // map mouse position to graph value // mpmp.x is the timestamp
            var mpmp = aioGraph.mapToValue(mmm, tempData)

            //console.log("clicked " + mouse.x + " " + mouse.y)
            //console.log("clicked adjusted " + ppp.x + " " + ppp.y)
            //console.log("clicked mapped " + mpmp.x + " " + mpmp.y)

            if (isMoving) {
                // dragging outside the graph area?
                if (mpmp.x < tempData.at(0).x){
                    ppp.x = aioGraph.mapToPosition(tempData.at(0), tempData).x + aioGraph.anchors.rightMargin
                    mpmp.x = tempData.at(0).x
                }
                if (mpmp.x > tempData.at(tempData.count-1).x){
                    ppp.x = aioGraph.mapToPosition(tempData.at(tempData.count-1), tempData).x + aioGraph.anchors.rightMargin
                    mpmp.x = tempData.at(tempData.count-1).x
                }
            } else {
                // did we clicked outside the graph area?
                if (mpmp.x < tempData.at(0).x || mpmp.x > tempData.at(tempData.count-1).x) {
                    resetIndicator()
                    return
                }
            }

            // indicators is now visible
            dateIndicator.visible = true
            verticalIndicator.visible = true
            verticalIndicator.x = ppp.x
            verticalIndicator.clickedCoordinates = mpmp

            // update the indicator data
            updateIndicator()
        }

        ////////////////

        Item {
            id: legend_area
            x: aioGraph.plotArea.x
            y: aioGraph.plotArea.y
            width: aioGraph.plotArea.width
            height: aioGraph.plotArea.height

            //Rectangle { anchors.fill: parent; color: "red"; opacity: 0.1; }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: indicators
        anchors.margins: -8
        onClicked: resetIndicator()
    }

    onWidthChanged: resetIndicator()

    function isIndicator() {
        return verticalIndicator.visible
    }

    function resetIndicator() {
        if (appContent.state === "DevicePlantSensor" && indicatorsLoader.status === Loader.Ready) {
            if (typeof devicePlantSensorData === "undefined" || !devicePlantSensorData) return
            dataIndicators.resetDataBars()
        }
        if (appContent.state === "DeviceThermometer") {
            //
        }

        vanim.duration = 0

        dateIndicator.visible = false
        dataIndicator.visible = false
        verticalIndicator.visible = false
        verticalIndicator.clickedCoordinates = null
    }

    function updateIndicator() {
        if (!dateIndicator.visible) return

        // set date & time
        var date = new Date(verticalIndicator.clickedCoordinates.x)
        var date_string = date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
        var time_string = date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)

        //: "at" is used for DATE at HOUR
        dateIndicator.text = date_string + " " + qsTr("at") + " " + time_string

        // search index corresponding to the timestamp
        var x1 = -1
        var x2 = -1
        for (var i = 0; i < tempData.count; i++) {
            var graph_at_x = tempData.at(i).x
            var dist = (graph_at_x - verticalIndicator.clickedCoordinates.x) / 1000000

            if (Math.abs(dist) < 0.5) {
                // nearest neighbor
                if (appContent.state === "DevicePlantSensor") {
                    dataIndicators.updateDataBars(hygroData.at(i).y, conduData.at(i).y, -99,
                                                  tempData.at(i).y, -99, lumiData.at(i).y)
                } else if (appContent.state === "DeviceThermometer") {
                    dataIndicator.visible = true
                    dataIndicator.text = (settingsManager.tempUnit === "F") ?
                                            UtilsNumber.tempCelsiusToFahrenheit(tempData.at(i).y).toFixed(1) + qsTr("°F") :
                                            tempData.at(i).y.toFixed(1) + qsTr("°C")
                    dataIndicator.text += " " + hygroData.at(i).y.toFixed(0) + "%"
                }
                break
            } else {
                if (dist < 0) {
                    if (x1 < i) x1 = i
                } else {
                    x2 = i
                    break
                }
            }
        }

        if (x1 >= 0 && x2 > x1) {
            // linear interpolation
            if (appContent.state === "DevicePlantSensor") {
                dataIndicators.updateDataBars(qpoint_lerp(hygroData.at(x1), hygroData.at(x2), verticalIndicator.clickedCoordinates.x),
                                              qpoint_lerp(conduData.at(x1), conduData.at(x2), verticalIndicator.clickedCoordinates.x),
                                              -99,
                                              qpoint_lerp(tempData.at(x1), tempData.at(x2), verticalIndicator.clickedCoordinates.x),
                                              -99,
                                              qpoint_lerp(lumiData.at(x1), lumiData.at(x2), verticalIndicator.clickedCoordinates.x))
            } else if (appContent.state === "DeviceThermometer") {
                dataIndicator.visible = true
                var temmp = qpoint_lerp(tempData.at(x1), tempData.at(x2), verticalIndicator.clickedCoordinates.x)
                dataIndicator.text = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(temmp).toFixed(1) + "°F" : temmp.toFixed(1) + "°C"
                dataIndicator.text += " " + qpoint_lerp(hygroData.at(x1), hygroData.at(x2), verticalIndicator.clickedCoordinates.x).toFixed(0) + "%"
            }
        }
    }

    Rectangle {
        id: verticalIndicator

        x: legend_area_overlay.x
        y: legend_area_overlay.y
        width: 2
        height: legend_area_overlay.height

        visible: false
        opacity: 0.66
        color: Theme.colorSubText

        property var clickedCoordinates: null

        Behavior on x { NumberAnimation { id: vanim; duration: 0; easing.type: Easing.InOutCubic; } }

        onXChanged: {
            if (isPhone) return // verticalIndicator default to middle
            if (isTablet) return // verticalIndicator default to middle

            var direction = "middle"
            if (verticalIndicator.x > dateIndicator.width + 48)
                direction = "right"
            else if (chartPlantDataAio.width - verticalIndicator.x > dateIndicator.width + 48)
                direction = "left"

            if (direction === "middle") {
                // date indicator is too big, center on screen
                indicators.columns = 2
                indicators.state = "reanchoredmid"
                indicators.layoutDirection = "LeftToRight"
            } else {
                // date indicator is positioned next to the vertical indicator
                indicators.columns = 1
                if (direction === "left") {
                    indicators.state = "reanchoredleft"
                    indicators.layoutDirection = "LeftToRight"
                } else {
                    indicators.state = "reanchoredright"
                    indicators.layoutDirection = "RightToLeft"
                }
            }
        }
    }

    ////////////////

    Grid {
        id: indicators
        anchors.top: legend_area_overlay.top
        anchors.topMargin: (isPhone ? 8 : 12) + 8
        anchors.leftMargin: isPhone ? 20 : 24
        anchors.rightMargin: isPhone ? 20 : 24
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 32
        layoutDirection: "LeftToRight"
        columns: 2
        rows: 2

        //transitions: Transition { AnchorAnimation { duration: 133; } }
        //move: Transition { NumberAnimation { properties: "x"; duration: 133; } }

        states: [
            State {
                name: "reanchoredmid"
                AnchorChanges {
                    target: indicators
                    anchors.right: undefined
                    anchors.left: undefined
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            },
            State {
                name: "reanchoredleft"
                AnchorChanges {
                    target: indicators
                    anchors.horizontalCenter: undefined
                    anchors.right: undefined
                    anchors.left: verticalIndicator.right
                }
            },
            State {
                name: "reanchoredright"
                AnchorChanges {
                    target: indicators
                    anchors.horizontalCenter: undefined
                    anchors.left: undefined
                    anchors.right: verticalIndicator.right
                }
            }
        ]

        Text {
            id: dateIndicator

            visible: false
            font.pixelSize: 15
            font.bold: true
            color: Theme.colorSubText

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: -8
                anchors.leftMargin: -12
                anchors.rightMargin: -12
                anchors.bottomMargin: -8

                z: -1
                radius: height
                color: Theme.colorComponentBackground
                border.width: Theme.componentBorderWidth
                border.color: Theme.colorComponentDown
            }
        }

        Text {
            id: dataIndicator

            visible: false
            font.pixelSize: 15
            font.bold: true
            color: Theme.colorSubText

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: -8
                anchors.leftMargin: -12
                anchors.rightMargin: -12
                anchors.bottomMargin: -8

                z: -1
                radius: height
                color: Theme.colorComponentBackground
                border.width: 2
                border.color: Theme.colorComponentDown
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: legend_area_overlay
        x: aioGraph.x + aioGraph.plotArea.x
        y: aioGraph.y + aioGraph.plotArea.y
        width: aioGraph.plotArea.width
        height: aioGraph.plotArea.height

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            spacing: 6

            RoundButtonIcon {
                width: 34
                height: 34
                anchors.verticalCenter: parent.verticalCenter

                background: true
                source: "qrc:/assets/icons_material/outline-settings-24px.svg"

                visible: isDesktop
                onClicked: smsmsm.showHide()
            }

            SelectorMenu {
                id: smsmsm
                height: 32
                anchors.verticalCenter: parent.verticalCenter

                function showHide() {
                    if (smsmsm.opacity > 0) smsmsm.opacity = 0
                    else smsmsm.opacity = 1
                }

                enabled: (opacity > 0)
                opacity: 0
                Behavior on opacity { OpacityAnimator { duration: 133 } }

                model: ListModel {
                    id: lmSelectorMenuTxt2
                    ListElement { idx: 1; txt: "31"; src: ""; sz: 0; }
                    ListElement { idx: 2; txt: "14"; src: ""; sz: 0; }
                    ListElement { idx: 3; txt: "7"; src: ""; sz: 0; }
                }

                currentSelection: {
                    if (settingsManager.graphAioDays === 31) return 1
                    if (settingsManager.graphAioDays === 14) return 2
                    if (settingsManager.graphAioDays === 7) return 3
                    return 2
                }

                onMenuSelected: (index) => {
                    if (index === 1) settingsManager.graphAioDays = 31
                    else if (index === 2) settingsManager.graphAioDays = 14
                    else if (index === 3) settingsManager.graphAioDays = 7
                    else settingsManager.graphAioDays = 14
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
