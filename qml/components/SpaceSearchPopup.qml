import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import SortFilterProxyModel

import "../components_generic"

Drawer {
    id: control
    edge: "BottomEdge"
    property var callback

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
    ClipRRect {
        anchors.fill: parent
        anchors.margins: -1
        radius: 18
        BPage {
            anchors.fill: parent
            header: AppBar {
                title: "Choose space"
                statusBarVisible: false
                leading.icon: Icons.close
                leading.onClicked: {
                    control.close()
                }

                noAutoPop: true
            }
            ListView {
                anchors.fill: parent
                model: $Model.space
                anchors.margins: 10
                delegate: ItemDelegate {
                    required property variant model
                    required property int index

                    width: ListView.view.width
                    height: 80

                    GardenSpaceLine {
                        anchors.fill: parent
                        title: model.libelle
                        subtitle: model.description
                        iconSource: model.type === 1 ? Icons.homeOutline : Icons.landFields

                        onClicked: {
                            control.callback($Model.space.get(index))
                            control.close()
                        }
                    }
                }
            }
        }

    }
}
