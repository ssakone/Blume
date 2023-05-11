import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import QtQuick.Shapes

import Qt5Compat.GraphicalEffects as QGE

import SortFilterProxyModel
import "components"
import "components_generic"

import "./pages/Garden"

BPage {
    id: control

    footer: BottomTabBar {}

    property var push: (page) => page_view.push(page)
    property var pop: () => page_view.pop()

    StackView {
        id: page_view
        property string previousState: ""

//        y: -appHeader.height
        width: parent.width
        height: parent.height + appHeader.height
        visible: true
        initialItem: Component {
            GardenScreen {}
        }
    }
}
