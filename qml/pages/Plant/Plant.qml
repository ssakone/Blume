import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../../components_generic"
import "../../components"
import "qrc:/qml"
import "../../components_js/Http.js" as Http

BPage {
    id: control
    required property var plant
    property bool isLoaded: false
    property string error: ""

    header: AppBar {
        title: plant["name_scientific"]?? ""
    }

    onFocusChanged: {
        if(focus) {
            const url = `https://public.blume.mahoudev.com/plants/${plant.id}?fields=*.*`


            let appLang = "en"
            for (var i = 0; i < $Constants.cbAppLanguage.count; i++) {
                if ($Constants.cbAppLanguage.get(i).code === settingsManager.appLanguage)
                    appLang = $Constants.cbAppLanguage.get(i).code
            }

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
                control.plant = JSON.parse(response).data
                control.isLoaded = true
            }).catch(function (err) {
                console.log(Object.keys(err))
                control.error = "Erreur inattendue"
                control.isLoaded = true
            })
        }
    }

    Loader {
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
