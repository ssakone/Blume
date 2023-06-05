import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../components_generic"
import "../../components"
import "qrc:/qml"

BPage {
    required property var plant

    header: AppBar {
        title: plant["name_scientific"]?? ""
    }

    ScrollView {
        anchors.fill: parent
        contentHeight: _insideCol.height

        ColumnLayout {
            id: _insideCol
            width: parent.width
            spacing: 2

            TableLine {
                title: qsTr("Watering frequency")
                description: plant['frequence_arrosage'] || ""
            }

            TableLine {
                color: "#e4f0ea"
                title: qsTr("Fertilization frequency")
                description: plant['frequence_fertilisation'] || ""
            }

            TableLine {
                title: qsTr("Paddling frequency")
                description: plant['frequence_rampotage'] || ""
            }

            TableLine {
                color: "#e4f0ea"
                title: qsTr("Cleaning frequency")
                description: plant['frequence_nettoyage'] || ""
            }

            TableLine {
                title: qsTr("Spray frequency")
                description: plant['frequence_vaporisation'] || ""
            }
        }

    }

}
