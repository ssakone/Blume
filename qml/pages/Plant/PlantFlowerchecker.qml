import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine


import "../../components_generic"
import "../../components_js"
import "../../components"
import "../../"
import "../../components_js/Http.js" as Http

BPage {
    id: control
    required property string plantName
    property var images: []
    property bool isLoaded: false
    property string error: ""

    header: AppBar {
        title: ""
        statusBarVisible: false
        leading.icon: Icons.close
        color: Qt.rgba(12, 200, 25, 0)
        foregroundColor: $Colors.colorPrimary
    }

    onFocusChanged: {
        console.log("Received plantName ", plantName)
        console.log("Received iamges ", images)
        if(focus) {
            if(isLoaded) {
                plantLoader.item.open()
                return
            }
            let appLang = Qt.locale().name.slice(0, 2)
            control.isLoaded = true

        }
    }

    Loader {
        id: plantLoader
        active: control.isLoaded && !control.error
        sourceComponent: PlantScreenDetails {
            id: pop
            plant: {
                "name_scientific": plantName,
                "nom_botanique": plantName
            }
            imagesURL: control.images

            hideBaseHeader: true
            parent: parent
            Component.onCompleted: open()
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: !control.isLoaded
    }

    Label {
        text: control.error
        visible: text
        anchors.centerIn: parent
        color: $Colors.red400
        font {
            pixelSize: 16
            weight: Font.Light
        }
    }
}
