import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import SortFilterProxyModel

import "../components_generic"

Drawer {
    id: control
    width: parent.width
    height: parent.height - 20
    edge: "BottomEdge"
    property var callback
    onVisibleChanged: {
        if (visible)
            plantListViewForSelection.model = customModel
        else
            plantListViewForSelection.model = []
    }

    function show(c) {
        callback = c
        open()
    }

    background: Item {
        Rectangle {
            radius: 24
            width: parent.width
            height: parent.height + 60
        }
    }
    ColumnLayout {
        anchors.fill: parent
        Column {
            padding: 10
            Layout.fillWidth: true
            Label {
                font.pixelSize: 21
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Choisissez une plante"
            }
        }

        SortFilterProxyModel {
            id: customModel
            sourceModel: $Model.globalPlant
            onCountChanged: {
                if (plantListViewForSelection.searchBar !== undefined) {
                    plantListViewForSelection.searchBar.forceActiveFocus()
                }
            }

            filters: RegExpFilter {
                roleName: "name_scientific"
                pattern: plantListViewForSelection.searchValue
            }
        }

        ListView {
            id: plantListViewForSelection
            property string searchValue: ""
            property var searchBar
            Layout.fillHeight: true
            Layout.fillWidth: true
            snapMode: ListView.SnapToItem
            headerPositioning: ListView.OverlayHeader
            clip: true
            header: Rectangle {
                property alias searchBar: searchField
                width: plantListViewForSelection.width
                height: 90
                z: 1000
                Column {
                    padding: 20
                    width: parent.width
                    Label {
                        text: "Recherche"
                    }
                    TextField {
                        id: searchField
                        width: parent.width - 40
                        height: 50
                        focusReason: Qt.TabFocusReason
                        placeholderText: "Recherche"
                        onDisplayTextChanged: {
                            plantListViewForSelection.searchValue = displayText
                            focus = true
                        }
                        Component.onCompleted: plantListViewForSelection.searchBar = searchField
                    }
                }
            }

            delegate: ItemDelegate {
                width: plantListViewForSelection.width
                text: name_scientific
                height: 60
                onClicked: {
                    control.callback($Model.globalPlant.get(
                                         customModel.mapToSource(index)))
                    control.close()
                }
            }
        }
    }
}
