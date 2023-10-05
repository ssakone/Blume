import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine


import "../../components_generic"
import "../../components_js"
import "../../components"
import "qrc:/qml"
import "../../components_js/Http.js" as Http

BPage {
    id: control
    required property var plant
    property bool isLoaded: false
    property string error: ""

    header: AppBar {
        title: ""
        statusBarVisible: false
    }

    onFocusChanged: {
        console.log("\n Plant Page :: ", focus, isLoaded)
        if(focus) {
            if(isLoaded) {
                plantLoader.item.open()
                return
            }

            const url = `https://public.blume.mahoudev.com/plants/${plant.id}?fields=*.*`


            let appLang = Qt.locale().name.slice(0, 2)

            Http.fetch({
                    method: "GET",
                    url: url,
                    headers: {
                       "Accept": 'application/json',
                       "Content-Type": 'application/json',
                       "Content-Lang": appLang
                    },
                }).then(function(response) {
                console.log(response)
                const parsedResponse = JSON.parse(response)
                control.plant = parsedResponse.data ?? parsedResponse
                control.isLoaded = true
            }).catch(function (err) {
                console.log(Object.keys(err))
                console.log(err, JSON.stringify(err))
                control.error = "Erreur inattendue"
                control.isLoaded = true
            })
        }
    }

    Loader {
        id: plantLoader
        active: control.isLoaded && !control.error
        sourceComponent: PlantScreenDetails {
            id: pop
            plant: control.plant
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
