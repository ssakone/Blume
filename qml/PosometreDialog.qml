import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtSensors
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Popup {
    id: posometrePop
    width: parent.width - 20
    height: width
    anchors.centerIn: parent
    dim: true
    modal: true
    onOpened: als.start()
    onClosed: als.stop()
    Column {
        anchors.centerIn: parent
        spacing: 20
        IconSvg {
            width: 64
            height: 64
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/assets/icons_custom/posometre.svg"
            color: 'black'
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Posometre"
            font.weight: Font.Medium
        }
        Label {
            id: alsV
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Label.Wrap
            width: parent.width - 20
            horizontalAlignment: Label.AlignHCenter
            text: {
                if (als.reading != null){
                    switch (als.reading.lightLevel) {
                        case 0:
                            return "Niveau inconnue"
                        case 1:
                            return "Sombre"
                        case 2:
                            return "Peu Sombre"
                        case 3:
                            return "Lumineux"
                        case 4:
                            return "Tres lumineux"
                        case 5:
                            return "Ensolleille"
                    }
                }
                return "Information sensor indisponible"
            }

            font.pixelSize: 44
        }
        AmbientLightSensor {
            id: als
        }
    }
}
