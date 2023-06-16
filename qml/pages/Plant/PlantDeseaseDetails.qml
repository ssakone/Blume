import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import SortFilterProxyModel
import QtMultimedia
import QtQuick.Dialogs
import ImageTools
import Qt.labs.platform

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

import MaterialIcons
import "../../"
import "../../components/"
import "../../components_generic"
import "../../components_js/Http.js" as Http

BPage {
    id: control
    property variant desease_data
    property variant details: desease_data["disease_details"] ?? {}
    property bool header_hidden: false
    property bool fullScreen: false
    property bool isLoaded: false
    property string error: ""

    onFullScreenChanged: {
        if(fullScreen) fullScreenPop.close()
        else fullScreenPop.open()
    }

    Component.onCompleted: {
        const url = `https://public.blume.mahoudev.com/diseases/${control.desease_data.id}?fields=*.*`

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

            const parsedResponse = JSON.parse(response)
            const data = parsedResponse.data
            if(!data) {
                control.error = "Erreur inattendue"
                control.isLoaded = true
                return
            }

            let formated = {}

            let desease_details = {
                "common_names": [],
                "treatment": {
                    "prevention": data.traitement_preventif || "",
                    "chemical": data.traitement_chimique || "",
                    "biological": data.traitement_biologique || ""
                },
                "description": data.description,
                "cause": data.cause
            }

            formated['name'] = data.nom_scientifique
            formated['similar_images'] = []

            for(let i=0; i<data.noms_communs.length; i++ ) {
                desease_details["common_names"].push(data.noms_communs[i])
            }

            for(let j=0; j<data.images.length; j++ ) {
                formated['similar_images'].push({"url": "https://blume.mahoudev.com/assets/" + data.images[j].directus_files_id})
            }

            formated['disease_details'] = desease_details

            control.desease_data = formated
            control.isLoaded = true

        }).catch(function (err) {
            console.log(Object.keys(err))
            console.log(err?.content, err?.status)
            console.log(err?.message)
            control.error = "Erreur inattendue"
            control.isLoaded = true
        })
    }


    padding: 0

    header: AppBar {
        title: desease_data.name ?? ""
    }

    FullScreenPopup {
        id: fullScreenPop
        onSwithMode: fullScreen = !fullScreen
    }

    Loader {
        active: control.isLoaded && !control.error
        anchors.fill: parent
        sourceComponent:
            Flickable {
            anchors.fill: parent
            contentHeight: _insideColumn.height

            Column {
                id: _insideColumn
                width: parent.width
                spacing: 10

                Rectangle {
                    height: singleColumn ? 300 : control.height / 3
                    width: parent.width
                    clip: true
                    color: "#f0f0f0"

                    SwipeView {
                        id: imageSwipeView
                        anchors.fill: parent
                        Repeater {
                            model: desease_data['similar_images']
                            delegate: Image {
                                source: modelData.url || modelData || ""
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        fullScreenPop.source = source
                                        fullScreen = !fullScreen
                                    }
                                }
                            }
                        }
                    }

                    PageIndicator {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                        currentIndex: imageSwipeView.currentIndex
                        count: desease_data['similar_images'].length || desease_data['similar_images'].count
                    }
                }

                Column {
                    width: parent.width
                    padding: 10
                    topPadding: 0
                    spacing: 10

                    Column {
                        spacing: 3
                        width: parent.width
                        Label {
                            text: desease_data['name']
                            font.pixelSize: 32
                            font.weight: Font.Bold
                            width: parent.width
                            wrapMode: Text.Wrap
                        }

                        RowLayout {
                            width: parent.width
                            Repeater {
                                model: details['common_names']
                                delegate: Label {
                                    required property int index
                                    required property variant modelData

                                    text: (modelData?.name ?? modelData)
                                          + (index < details['common_names'].length ? ", " : "")
                                }
                            }
                        }
                    }

                    Text {
                        text: details['description']
                        font.pixelSize: 14
                        font.weight: Font.Light
                        wrapMode: Text.Wrap
                        width: parent.width - 10
                    }

                    Label {
                        text: "Cause"
                        color: Theme.colorPrimary
                        font.pixelSize: 24
                        textFormat: Text.MarkdownText
                    }

                    Rectangle {
                        width: parent.width - 30
                        height: text_cause.implicitHeight + 15
                        color: "#f0f0f0"
                        radius: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        TextEdit {
                            id: text_cause
                            text: details['cause'] || "Inconnue"
                            readOnly: true
                            font.pixelSize: 14
                            color: Material.color(Material.Grey, Material.Shade800)

                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: Text.Wrap
                            textFormat: Text.MarkdownText
                            textMargin: 10
                        }
                    }

                    Label {
                        text: "Traitements"
                        font.pixelSize: 24
                        color: Theme.colorPrimary
                    }

                    Column {
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10
                        Repeater {
                            model: [{
                                    "label": 'Traitement préventif',
                                    "field": 'prevention'
                                }, {
                                    "label": 'Traitement chimique',
                                    "field": 'chemical'
                                }, {
                                    "label": 'Traitement biologique',
                                    "field": 'biological'
                                }]

                            Rectangle {
                                required property variant modelData
                                height: treat_prevention_col.height
                                width: parent.width - 10
                                radius: 10
                                color: "#f0f0f0f0"
                                anchors.horizontalCenter: parent.horizontalCenter

                                Column {
                                    id: treat_prevention_col
                                    width: parent.width
                                    padding: 10

                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        IconImage {
                                            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
                                            width: 25
                                            height: 25
                                            color: Theme.colorPrimary
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        Text {
                                            text: qsTr(modelData.label)
                                            font.pixelSize: 16
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Label {
                                        text: (details['treatment']
                                               && typeof details['treatment'][modelData.field]
                                               === 'string') ? details['treatment'][modelData.field] : ""
                                        textFormat: Label.MarkdownText
                                        color: Material.color(Material.Grey,
                                                              Material.Shade900)
                                        font.pixelSize: 14
                                        font.weight: Font.Light
                                        wrapMode: Text.Wrap
                                        width: parent.width - 10
                                        padding: 10
                                    }

                                    Column {
                                        spacing: 2
                                        width: parent.width
                                        padding: 10
                                        leftPadding: 0
                                        visible: (details['treatment']
                                                  && typeof details['treatment'][modelData.field])
                                                 === 'object'
                                        Repeater {
                                            model: details['treatment'][modelData.field]
                                            delegate: Label {
                                                required property int index
                                                required property variant modelData
                                                text: qsTr(modelData)
                                                color: Material.color(
                                                           Material.Grey,
                                                           Material.Shade900)
                                                font.pixelSize: 14
                                                font.weight: Font.Light
                                                wrapMode: Text.Wrap
                                                width: parent.width - 10
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    NiceButton {
                        visible: details['url']
                        text: qsTr("More informations on Wikipedia")
                        icon.source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                        height: 55
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            Qt.openUrlExternally(details['url'])
                        }
                    }
                }
            }
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
