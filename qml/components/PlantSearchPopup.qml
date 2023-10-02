import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import SortFilterProxyModel

import "../components_generic/"
import "../components_themed/"

Drawer {
    id: control
    width: parent.width
    height: Qt.platform.os === "ios" ? parent.height - 45 : parent.height - 20
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
                title: "Choose plant"
                statusBarVisible: false
                leading.onClicked: {
                    control.close()
                }
                noAutoPop: true
            }
            SearchPlants {
                anchors.fill: parent
                preventDefaultOnClick: true
                hideCameraSearch: true
                property variant cool: ({})
                onItemClicked: data => {
                                   control.callback(data)
                                   control.close()
                               }
            }
        }
    }
}
