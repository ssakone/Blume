import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine

import Qt5Compat.GraphicalEffects as QGE

import "../../components_generic"
import "../../components"

Container {
    id: root
    property string title: ""
    property string subtitle: ""
    property string iconSource: ""
    property variant imagesSourcesList: []
    property bool isOutdoor: false

    signal clicked
    contentItem: Column {
        width: parent.width - 20
        spacing: 10
        padding: 10
    }

//    background: Image {
//        source: "qrc:/assets/img/cactus.jpg"
//    }

    Row {
        Label {
            text: qsTr("Room : ")
            font.pixelSize: 16
        }
        Label {
            text: title
            font.pixelSize: 16
            font.weight: Font.DemiBold
            color: $Colors.colorPrimary
            MouseArea {
                anchors.fill: parent
                onClicked: root.clicked()
            }
        }
    }

    Flow {
        width: parent.width
        spacing: 10
        Repeater {
            model: imagesSourcesList.length > 0 ? imagesSourcesList.slice(0, 4) : ["", "", "", ""]
            ClipRRect {
                required property int index
                required property variant modelData
                width: root.width / 2.5
                height: width - 60

                Rectangle {
                    anchors.fill: parent
                    border {
                        width: 3
                        color: $Colors.colorPrimary
                    }
                    radius: 10
                    clip: true
                }

                Image {
                    source: {
                        console.log("STRT")
                        let plant = JSON.parse(modelData?.plant_json ?? null)
                        let file_id = plant?.images_plantes[0]?.directus_files_id
                        console.log("ID : ", file_id)
                        if(!file_id) return ""
                        return "https://blume.mahoudev.com/assets/" + file_id
                    }

                    anchors.fill: parent
                    anchors.margins: 2
                    fillMode: Image.PreserveAspectCrop
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.clicked()
                }
            }
        }
    }


}
