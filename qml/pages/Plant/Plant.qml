import QtQuick
import QtQuick.Layouts
import QtQuick.Controls


import "../../components_generic"
import "../../components_js"
import "../../components"
import "qrc:/qml"

BPage {
    id: control
    required property var plant

    header: AppBar {
        title: plant["name_scientific"]?? ""
    }

    onFocusChanged: {
        if(focus) {
            pop.open()
        }
    }

    PlantScreenDetails {
        id: pop
        plant: control.plant
        hideBaseHeader: true

        parent: parent
    }
}
