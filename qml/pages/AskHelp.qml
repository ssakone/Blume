import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0
import "../components"
import "../components_generic"
import "../components_js/Http.js" as Http

Page {
    header: AppBar {
        title: "Demander à un botaniste"
    }

    property variant form_schema: [{
            "group_title": "",
            "fields": [{
                    "name": "description",
                    "label": "Décrivez le problème",
                    "is_required": true,
                    "placeholder": "",
                    "type": "textarea"
                }]
        }, {
            "group_title": "Exposition et température",
            "fields": [{
                    "name": "sun_time",
                    "label": "De combien d'ensoleillement bénéficie votre plante chaque jour ?",
                    "is_required": true,
                    "placeholder": "6h de lumière naturelle indirecte"
                }, {
                    "name": "sun_temp",
                    "label": "Quelles sont les température de son environnement ?",
                    "is_required": false,
                    "placeholder": "Journée: +24°C, Nuit: +1°C"
                }]
        }, {
            "group_title": "Parasites et maladies",
            "fields": [{
                    "name": "disease_list",
                    "label": "Y a-t-il des toiles ou des insectes sur la plante ou dans la terre ?",
                    "is_required": false,
                    "placeholder": "Insectes blancs sous les feuilles"
                }]
        }, {
            "group_title": "Arrosage",
            "fields": [{
                    "name": "watering_freq",
                    "label": "A quelle fréquence arrosez-vous votre plante ?",
                    "is_required": false,
                    "placeholder": "1 à 2 fois par semaine"
                }, {
                    "name": "watering_qty",
                    "label": "Quelle quantité d'eau utilisez-vous ?",
                    "is_required": false,
                    "placeholder": "Un verre et demi"
                }, {
                    "name": "watering_drying",
                    "label": "Laissez-vous la terre sécher entre les arrosages ?",
                    "is_required": false,
                    "placeholder": "Oui, les premiers centimètres"
                }, {
                    "name": "watering_container",
                    "label": "Le fond du pot est-il percé ?",
                    "is_required": false,
                    "placeholder": "Oui"
                }]
        }, {
            "group_title": "Rempotage et engrais",
            "fields": [{
                    "name": "rampotage",
                    "label": "A quelle fréquence arrosez-vous votre plante ?",
                    "is_required": false,
                    "placeholder": "1 à 2 fois par semaine"
                }]
        }]

    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            id: head
            Layout.preferredHeight: 120
            Layout.fillWidth: true
            color: Theme.colorPrimary

            ColumnLayout {
                anchors.fill: parent

                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Label {
                    text: "Vous receverez un diagnostic et un plan de soin dans les trois jours après avoire rempli ce formulaire"
                    color: "white"
                    font.pixelSize: 16
                    font.weight: Font.Light
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: colHeadFaqForm.height
            topMargin: -60

            Column {
                id: colHeadFaqForm
                width: parent.width

                Rectangle {
                    width: parent.width
                    height: insideCol2.height
                    color: "white"
                    radius: 50

                    Column {
                        id: insideCol2
                        width: parent.width
                        padding: width < 500 ? 10 : width / 11
                        topPadding: 30
                        bottomPadding: 70

                        spacing: 30

                        Column {
                            width: parent.width
                            spacing: 10
                            Label {
                                text: "Ajouter des images"
                                font {
                                    pixelSize: 16
                                    weight: Font.Bold
                                }

                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Label {
                                text: "Photographiez la plante entière ainsi que les parties qui semblent malades"
                                font.weight: Font.Light
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 10
                                Item {
                                    Layout.fillWidth: true
                                }

                                Repeater {
                                    model: 4
                                    ImagePickerArea {
                                        width: 70
                                        height: 70
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Repeater {
                            model: form_schema
                            delegate: Column {
                                required property variant modelData
                                required property int index
                                property int group_index: index

                                width: parent.width - (2 * parent.padding)
                                spacing: 15

                                Row {
                                    width: parent.width
                                    spacing: 10

                                    IconSvg {
                                        source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                                        width: 30
                                        height: 30
                                        color: Theme.colorPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Label {
                                        text: modelData.group_title
                                        font {
                                            pixelSize: 13
                                            weight: Font.Bold
                                            capitalization: Font.AllUppercase
                                        }
                                        color: Theme.colorPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        wrapMode: Text.Wrap
                                    }
                                }

                                Repeater {
                                    model: modelData.fields
                                    delegate: Column {
                                        required property variant modelData
                                        required property int index

                                        width: parent.width
                                        spacing: 7
                                        Label {
                                            text: (modelData.is_required ? "* " : "")
                                                  + modelData.label
                                            font {
                                                pixelSize: 16
                                                weight: Font.Bold
                                            }
                                            width: parent.width
                                            wrapMode: Text.Wrap
                                        }

                                        TextField {
                                            id: textInput
                                            visible: modelData.type === undefined
                                            placeholderText: modelData?.placeholder
                                            padding: 5

                                            width: parent.width
                                            height: 50

                                            verticalAlignment: Text.AlignVCenter

                                            font {
                                                pixelSize: 14
                                                weight: Font.Light
                                            }

                                            background: Rectangle {
                                                radius: 15
                                                color: "#f5f5f5"
                                                border {
                                                    color: "#ccc"
                                                    width: 1
                                                }
                                            }
                                            onTextChanged: form_schema[group_index].fields[index].value = text
                                        }

                                        TextArea {
                                            visible: modelData.type === "textarea"
                                            enabled: visible
                                            width: parent.width
                                            height: 120
                                            padding: 7
                                            topPadding: 10
                                            focus: false
                                            font {
                                                pixelSize: 14
                                                weight: Font.Light
                                            }
                                            wrapMode: Text.Wrap
                                            background: Rectangle {
                                                color: "#f5f5f5"
                                                radius: 15
                                                border {
                                                    width: 1
                                                    color: "#ccc"
                                                }
                                            }
                                            onTextChanged: form_schema[group_index].fields[index].value = text
                                        }
                                    }
                                }
                            }
                        }

                        ButtonWireframe {
                            text: "Envoyer"
                            fullColor: Theme.colorPrimary
                            fulltextColor: "white"
                            componentRadius: 10
                            padding: 15
                            topPadding: 5
                            bottomPadding: 5

                            onClicked: {
                                // Collect form data
                                let data = {}
                                for (var i = form_schema.length - 1; i >= 0; i--) {
                                    for (var j = form_schema[i].fields.length - 1; j >= 0; j--) {
                                        let item = form_schema[i].fields[j]
                                        console.log(`${item.name} =>>> ${item.value}`)
                                        data[item.name] = item.value
                                    }
                                }

                                // Format data for mailing
                                let html_string = ""
                                // ...

                                // Send mail
                                Http.send_mail(
                                            "marcleord.zomadi@mahoudev.com",
                                            "Marcleord ZOMADI",
                                            "Blume: demande de l'avis d'un expert",
                                            html_string).then(
                                            res => console.log(JSON.stringify(
                                                                   res))).catch(
                                            res => console.warn(
                                                JSON.stringify(res)))
                            }
                        }

                        Item {
                            height: 70
                        }
                    }
                }
            }
        }
    }
}
