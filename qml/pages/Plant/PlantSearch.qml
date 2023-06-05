import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import ThemeEngine 1.0

import SortFilterProxyModel

import "../../components"
import "../../components_generic"
import "../../components_js/Http.js" as Http

import "../.."

BPage {
    id: plantListView

    header: AppBar {
        title: "Chercher une plante"
    }

    SearchPlants {
        anchors.fill: parent
    }

}
