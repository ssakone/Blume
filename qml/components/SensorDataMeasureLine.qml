import QtQuick
import QtQuick.Controls
import ThemeEngine
import QtQuick.Layouts
import "../components_generic"

Rectangle {
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

    Column {
        width: parent.width
        height: parent.height
        padding: 20

        RowLayout {
            id: row
            width: parent.width - 2*parent.padding
            Layout.alignment: Qt.AlignVCenter

            Label {
                id: item_legend
                text: legend
                font {
                    weight: Font.Light
                    pixelSize: 16
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Column {
                spacing: 5

                Row {
                    Label {
                        text: value.toFixed(1)
                        color: (valueMin <= value && value <= valueMax) ? $Colors.green400 : $Colors.red400
                        font {
                            pixelSize: 24
                        }
                    }
                    IconSvg {
                        source: (valueMin <= value && value <= valueMax) ? Icons.arrowUp : Icons.arrowDown
                        color: (valueMin <= value && value <= valueMax) ? $Colors.green400 : $Colors.red400
                    }
                }

                Label {
                    text: valueMin + ' - ' + valueMax
                    font {
                        weight: Font.Light
                        pixelSize: 14
                    }
                }
            }

        }
    }




}
