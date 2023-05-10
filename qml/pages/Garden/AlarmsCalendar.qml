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

    header: AppBar {
        title: qsTr("Calendar")
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
                    width: parent.width - 20
                    spacing: 20

                    Column {
                        Layout.fillWidth: true
                        spacing: 10
                        leftPadding: 5
                        rightPadding: 5

                        Column {
                            width: parent.width - 10
                            spacing: 20
                            Repeater {
                                model: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
                                delegate: Column {
                                    width: parent.width
                                    RowLayout {
                                        visible: alarmsToday.count > 0
                                        width: parent.width
                                        Label {
                                            text: modelData
                                            font.pixelSize: 18
                                            Layout.fillWidth: true
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                    }

                                    SortFilterProxyModel {
                                        id: alarmsToday
                                        sourceModel: $Model.alarm
                                        filters: ValueFilter {
                                            value: 1
                                            roleName: modelData
                                        }
                                    }

                                    Repeater {
                                        model: alarmsToday
                                        GardenActivityLine {
                                            required property var model
                                            required property int index

                                            property var plantObj: JSON.parse(
                                                                       model.plant_json)
                                            title: model.libelle || "NULL"
                                            plant_name: plantObj.name_scientific

                                            isDone: model.done

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
