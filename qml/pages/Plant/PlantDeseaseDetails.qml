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
    required property string diseaseName
    property string mainURL

    property var similarImages: []
    property variant gptDetails: null
    property bool isBlumeDisease: false
    property bool header_hidden: false
    property bool fullScreen: false
    property bool isLoaded: false
    property string error: ""

    background.opacity: 0.5

    onFullScreenChanged: {
        if(fullScreen) fullScreenPop.close()
        else fullScreenPop.open()
    }

    Component.onCompleted: {
        const url = `http://34.41.96.172/get_disease_info?disease_name=${diseaseName}`
        console.log("\n\n Fetching at ", url)
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
            console.log("Got GPT resp ", typeof response)
            let parsedResponse = {}
            try {
                parsedResponse = JSON.parse(response)
            } catch (e) {
                for(let i = 100; i < response.length ; i += 100) {
                    console.log(response.slice(i-100, i))
                }
            }

            if(parsedResponse.inconnu) {
                control.error = parsedResponse.inconnu
            }

            control.gptDetails = {
                    "common_names": parsedResponse?.inconnu || parsedResponse["other_names"],
                    "description": parsedResponse["description"],
                    "cause": parsedResponse["causes"],
                    "symptoms": parsedResponse["symptoms"],
                    "treatmentPreventive": parsedResponse["preventive_treatment"],
                    "treatmentChimical": parsedResponse["chimical_traitment"],
                    "treatmentBiological": parsedResponse["biological_traitment"]
                }

            control.isLoaded = true

        }).catch(function (err) {
            console.log("NOPE NOPE")
            console.log(Object.keys(err))
            console.log(err?.content, err?.status)
            console.log(err?.message)
            control.error = "Erreur inattendue"
            control.isLoaded = true
        })
    }


    padding: 0

    header: AppBar {
        title: gptDetails.name ?? ""
        backgroundColor: $Colors.colorPrimary
        foregroundColor: $Colors.white
    }

    FullScreenPopup {
        id: fullScreenPop
        onSwithMode: fullScreen = !fullScreen
    }

    Flickable {
        anchors.fill: parent
        contentHeight: _insideColumn.height + 50
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: _insideColumn
            width: parent.width
            spacing: 10

            Rectangle {
                height: singleColumn ? 300 : control.height / 3
                width: parent.width
                clip: true
                color: "#f0f0f0"

                Image {
                    source: mainURL
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            fullScreenPop.source = source
                            fullScreen = !fullScreen
                        }
                    }
                }
            }

            Column {
                width: parent.width



                Label {
                    text: control.error
                    visible: text
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: $Colors.red400
                    font {
                        pixelSize: 16
                        weight: Font.Light
                    }
                }

                Column {
                    width: parent.width - 40
                    padding: 20
                    topPadding: 0
                    spacing: 20

                    Column {
                        spacing: 3
                        width: parent.width
                        Label {
                            text: diseaseName
                            font.pixelSize: 32
                            font.weight: Font.Bold
                            width: parent.width
                            wrapMode: Text.Wrap
                        }

                        Row {
                            Repeater {
                                model: gptDetails?.common_names
                                delegate: Label {
                                    required property int index
                                    required property variant modelData

                                    text: (modelData)
                                          + (index < gptDetails?.common_names?.length ? ", " : "")
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: detailsColumn.height
                        color: $Colors.colorBgPrimary
                        radius: 15


                            Column {
                                id: detailsColumn
                                width: parent.width

                                Flickable {
                                    width: parent.width
                                    height: insideRow.height
                                    contentWidth: insideRow.width
                                    boundsBehavior: Flickable.StopAtBounds

                                    Rectangle {
                                        width: parent.width
                                        height: parent.height
                                        radius: 10
                                        color: "#DBF3ED"
                                        clip: true
                                        Row {
                                            id: insideRow
                                            height: 40
                                            Repeater {
                                                model: [qsTr("Description"), qsTr("Causes")]

                                                Rectangle {
                                                    height: parent.height
                                                    width: detailsColumn.width / 2
                                                    radius: 10
                                                    color: detailsBar.currentIndex === index ? $Colors.colorPrimary : Qt.rgba(0,0,0,0)

                                                    Label {
                                                        anchors.centerIn: parent
                                                        text: modelData
                                                        color: detailsBar.currentIndex === index ? $Colors.white : $Colors.colorPrimary
                                                        font {
                                                            weight: Font.DemiBold
                                                            pixelSize: 16
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: detailsBar.currentIndex = index
                                                        }
                                                    }

                                                }

                                            }

                                        }
                                    }
                                }

                                Item {
                                    width: parent.width
                                    height: 250

                                    BusyIndicator {
                                        running: control.gptDetails === null
                                        width: 50
                                        height: width
                                        anchors.centerIn: parent
                                    }

                                    StackLayout {
                                        id: detailsBar
                                        anchors.fill: parent
                                        currentIndex: 0

                                        Item {
                                            Flickable {
                                                anchors.fill: parent
                                                contentHeight: 500

                                                Column {
                                                    id: itemDescription
                                                    width: parent.width
                                                    Label {
                                                        text: control.gptDetails?.description
                                                        width: parent.width
                                                        wrapMode: Label.Wrap
                                                        padding: 10
                                                        font {
                                                            weight: Font.Light
                                                            pixelSize: 14
                                                        }
                                                    }

                                                }

                                            }

                                        }

                                        Item {
                                            Flickable {
                                                anchors.fill: parent
                                                contentHeight: 500

                                                Column {
                                                    id: itemCause
                                                    width: parent.width

                                                    Label {
                                                        text: control.gptDetails?.cause
                                                        width: parent.width
                                                        wrapMode: Label.Wrap
                                                        padding: 10
                                                        font {
                                                            weight: Font.Light
                                                            pixelSize: 14
                                                        }
                                                    }
                                                }

                                            }

                                        }

                                    }

                                }
                            }

                        }

                    Label {
                        text: "Traitements"
                        font.pixelSize: 24
                        color: $Colors.colorPrimary
                    }

                    Column {
                        width: parent.width
                        spacing: 10
                        Repeater {
                            model: [{
                                    "label": 'Traitement préventif',
                                    "field": 'treatmentPreventive'
                                }, {
                                    "label": 'Traitement chimique',
                                    "field": 'treatmentChimical'
                                }, {
                                    "label": 'Traitement biologique',
                                    "field": 'treatmentBiological'
                                }]

                            Rectangle {
                                required property variant modelData
                                height: treat_prevention_col.height
                                width: parent.width
                                radius: 10
                                color: "#f0f0f0f0"
//                                anchors.horizontalCenter: parent.horizontalCenter

                                BusyIndicator {
                                    height: 30
                                    width: height
                                    running: control.gptDetails === null
                                    anchors.centerIn: parent
                                }

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
                                            color: $Colors.colorPrimary
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        Text {
                                            text: qsTr(modelData.label)
                                            font.pixelSize: 16
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Label {
                                        text: control.gptDetails[modelData.field]
                                        textFormat: Label.MarkdownText
                                        color: Material.color(Material.Grey,
                                                              Material.Shade900)
                                        font.pixelSize: 14
                                        font.weight: Font.Light
                                        wrapMode: Text.Wrap
                                        width: parent.width - 10
                                        padding: 10
                                    }
                                }
                            }
                        }
                    }
                }




                }

            }

    }
}
