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
                color: "#e4f0ea"
                title: qsTr("Type of plant")
                description: plant['type_de_plante'] || ""
            }

            TableLine {
                title: qsTr("Dimensions")
                description: plant['taill_adulte'] || ""
            }

            TableLine {
                color: "#e4f0ea"
                title: qsTr("Sun exposure")
                description: plant['exposition_au_soleil'] || ""
            }

            TableLine {
                title: qsTr("Ground type")
                description: plant['type_de_sol'] || ""
            }

            TableLine {
                color: "#e4f0ea"
                title: qsTr("Color")
                description: plant['couleur'] || ""
            }

            TableLine {
                title: qsTr("Flowering period")
                description: plant['periode_de_floraison'] || ""
            }

            TableLine {
                color: "#e4f0ea"
                title: qsTr("Hardiness area")
                description: plant['zone_de_rusticite'] || ""
            }

            TableLine {
                title: "PH"
                description: plant['ph'] || ""
            }

            TableLine {
                color: "#e4f0ea"
                title: qsTr("Toxicity")
                description: plant['toxicity'] ? 'Toxic' : 'Non-toxic'
            }

            TableLine {
                title: qsTr("Lifecycle")
                description: plant['cycle_de_vie'] || ""
            }
        }

    }

}
