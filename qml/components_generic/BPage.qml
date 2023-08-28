import QtQuick
import QtQuick.Controls

Page {
    property color backgroundColor: $Colors.gray50
    background: Rectangle {
        color: backgroundColor
        IconSvg {
            source: "qrc:/assets/img/bg_plant.svg"
            color: $Colors.colorPrimary
            opacity: 0.7
            anchors.fill: parent
        }
    }
}
