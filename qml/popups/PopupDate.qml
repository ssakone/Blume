import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

import "../components_generic/"
import "../components_themed/"

Popup {
    id: popupDate
    width: appWindow.width * 0.9
    x: (appWindow.width / 2) - (width / 2)
    y: (appWindow.height / 2) - (height / 2) // - (appHeader.height / 2)

    padding: 0
    margins: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    ////////////////////////////////////////////////////////////////////////////

    //property var locale: Qt.locale()
    property var today: new Date()
    property bool isToday: false

    property var minDate: null
    property var maxDate: null

    property date initialDate
    property date currentDate

    signal updateDate(var newdate)

    function openDate(date) {
        minDate = null
        maxDate = null

        initialDate = date
        currentDate = date

        today = new Date()
        printDate()

        // visual hacks
        //dow.width = dow.width - 8
        grid.width = dow.width - 8

        popupDate.open()
    }

    function openDate_limits(datetime, min, max) {
        openDate(datetime)

        minDate = min
        maxDate = max
    }

    function printDate() {
        bigDay.text = currentDate.toLocaleString(locale, "dddd")
        bigDate.text = currentDate.toLocaleString(locale, "dd MMMM yyyy")

        var thismonth = new Date(grid.year, grid.month)
        bigMonth.text = thismonth.toLocaleString(locale, "MMMM")

        isToday = (today.toLocaleString(
                       locale, "dd MMMM yyyy") === currentDate.toLocaleString(
                       locale, "dd MMMM yyyy"))
    }

    ////////////////////////////////////////////////////////////////////////////
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.5
            to: 1.0
            duration: 133
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 233
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    background: Rectangle {
        radius: Theme.componentRadius * 2
        color: Theme.colorBackground
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorSeparator
    }

    ////////////////////////////////////////////////////////////////////////////
    contentItem: Column {

        Rectangle {
            id: titleArea
            anchors.left: parent.left
            anchors.right: parent.right

            height: 80
            radius: Theme.componentRadius * 2
            color: Theme.colorPrimary

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: parent.color
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    id: bigDay
                    text: currentDate.toLocaleString(locale,
                                                     "dddd") // "Vendredi"
                    font.pixelSize: 24
                    font.capitalization: Font.Capitalize
                    color: "white"
                }
                Text {
                    id: bigDate
                    text: currentDate.toLocaleString(
                              locale, "dd MMMM yyyy") // "15 octobre 2020"
                    font.pixelSize: 20
                    color: "white"
                }
            }

            RoundButtonIcon {
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/duotone-restart_alt-24px.svg"
                iconColor: "white"
                backgroundColor: Qt.lighter(Theme.colorPrimary, 0.9)

                visible: !(grid.year === today.getFullYear()
                           && grid.month === today.getMonth())

                onClicked: {
                    grid.month = today.getMonth()
                    grid.year = today.getFullYear()
                }
            }
        }

        ////////////////
        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 24
            bottomPadding: 16

            Rectangle {
                height: 48
                anchors.left: parent.left
                anchors.right: parent.right
                color: "#66dddddd"

                RoundButtonIcon {
                    width: 48
                    height: 48
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-chevron_left-24px.svg"

                    onClicked: {
                        if (grid.month > 0) {
                            grid.month--
                        } else {
                            grid.month = 11
                            grid.year--
                        }
                        printDate()
                    }
                }
                Text {
                    id: bigMonth
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: currentDate.toLocaleString(locale,
                                                     "MMMM") // "Octobre"
                    font.capitalization: Font.Capitalize
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                }
                RoundButtonIcon {
                    anchors.right: parent.right
                    width: 48
                    height: 48
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"

                    onClicked: {
                        if (grid.month < 11) {
                            grid.month++
                        } else {
                            grid.month = 0
                            grid.year++
                        }
                        printDate()
                    }
                }
            }

            ////////
            DayOfWeekRow {
                id: dow
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4

                //locale: popupDate.locale
                delegate: Text {
                    text: model.shortName.substring(0, 1).toUpperCase()
                    color: Theme.colorText
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MonthGrid {
                id: grid
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4

                //locale: popupDate.locale
                delegate: Text {
                    width: (grid.width / 7)
                    height: width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    opacity: (model.month === grid.month ? 1 : 0.2)
                    text: model.day
                    font: grid.font
                    //font.bold: model.today
                    color: selected ? "white" : Theme.colorSubText

                    property bool selected: (model.day === currentDate.getDate()
                                             && model.month === currentDate.getMonth()
                                             && model.year === currentDate.getFullYear(
                                                 ))
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        radius: width
                        color: selected ? Theme.colorSecondary : "transparent"
                        border.color: Theme.colorSecondary
                        border.width: (model.today) ? Theme.componentBorderWidth : 0
                    }
                }

                onClicked: date => {
                               if (date.getMonth() === grid.month) {
                                   // validate date (min / max)
                                   if (minDate && maxDate) {
                                       const diffMinTime = (minDate - date)
                                       const diffMinDays = -Math.ceil(
                                           diffMinTime / (1000 * 60 * 60 * 24) - 1)
                                       //console.log(diffMinDays + " diffMinDays");
                                       const diffMaxTime = (minDate - date)
                                       const diffMaxDays = -Math.ceil(
                                           diffMaxTime / (1000 * 60 * 60 * 24) - 1)

                                       //console.log(diffMaxDays + " diffMaxDays");
                                       if (diffMinDays > -1
                                           && diffMaxDays < 1) {
                                           date.setHours(
                                               currentDate.getHours(),
                                               currentDate.getMinutes(),
                                               currentDate.getSeconds())
                                           currentDate = date
                                       }
                                   } else {
                                       const diffTime = (today - date)
                                       const diffDays = -Math.ceil(
                                           diffTime / (1000 * 60 * 60 * 24) - 1)
                                       //console.log(diffDays + " days");

                                       // validate date (-7 / today)
                                       if (diffDays > -7 && diffDays < 1) {
                                           date.setHours(
                                               currentDate.getHours(),
                                               currentDate.getMinutes(),
                                               currentDate.getSeconds())
                                           currentDate = date
                                       }
                                   }

                                   printDate()
                               }
                           }
            }

            ////////
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 16

                ButtonWireframe {
                    height: 36
                    text: qsTr("Cancel")

                    primaryColor: Theme.colorSecondary
                    fullColor: true

                    onClicked: popupDate.close()
                }

                ButtonWireframe {
                    height: 36
                    text: qsTr("Validate")

                    primaryColor: Theme.colorPrimary
                    fullColor: true

                    onClicked: {
                        updateDate(currentDate)
                        popupDate.close()
                    }
                }
            }
        }

        ////////
    }
}
