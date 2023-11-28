import QtQuick 2.15

import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../components_generic/"
import "../components_themed/"

Rectangle {
    id: root
    radius: 25
    color: "#f5f5f5f5"

    property alias input: txtField
    property alias icon: iconSvg

    RowLayout {
        anchors.fill: parent
        IconSvg {
            id: iconSvg
            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            color: "black"
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            Layout.leftMargin: 15
        }

        TextField {
            id: txtField
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 7
            font {
                pixelSize: 14
                weight: Font.Light
            }
            clip: true
            placeholderText: "Recherche"
        }

        Item {
            Layout.preferredWidth: 10
        }
    }
}
