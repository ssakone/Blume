import QtQuick
import QtQuick.Controls
import ThemeEngine
import QtQuick.Layouts
import "../components_generic/"
import "../components_themed/"

Rectangle {
    id: root
    property int hhh: 8
    property bool animated: true

    property real value: 0
    property real valueMin: 0
    property real valueMax: 100
    property real limitMin: -1
    property real limitMax: -1

    property string prefix
    property string suffix
    property int floatprecision: 0
    property bool warning: false

    property string legend
    property int legendWidth: 80
    property int legendContentWidth: item_legend.contentWidth

    // colors
    property string colorText: Theme.colorText
    property string colorForeground: Theme.colorPrimary
    property string colorBackground: Theme.colorForeground

    radius: 15
    color: "#e5e5e5"
    height: 80

    Label {
        id: item_legend
        text: legend
        font {
            weight: Font.Light
            pixelSize: 16
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    Column {
        anchors {
            right: parent.right
            rightMargin: 20
            //            left: parent.left
            //            leftMargin: (2*root.width)/3
            verticalCenter: parent.verticalCenter
        }

        spacing: 5

        Item {
            width: parent.width
            height: _row.height

            Row {
                id: _row
                anchors.right: parent.right
                Label {
                    text: value.toFixed(1)
                    color: (valueMin <= value
                            && value <= valueMax) ? $Colors.green400 : $Colors.red400
                    font {
                        pixelSize: 24
                    }
                }
                IconSvg {
                    source: Icons.chevronDown
                    visible: !(valueMin <= value && value <= valueMax)
                    color: $Colors.red400
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Label {
            text: valueMin + ' - ' + valueMax + ' (' + suffix + ')'
            font {
                weight: Font.Light
                pixelSize: 14
            }
        }
    }
}
