import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageTools

import QtQuick.Controls.Material
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
                    "name": "user_email",
                    "label": "Adresse email de l'utilisateur",
                    "is_required": true,
                    "placeholder": "",
                }]
        },{
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
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
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
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
            "fields": [{
                    "name": "disease_list",
                    "label": "Y a-t-il des toiles ou des insectes sur la plante ou dans la terre ?",
                    "is_required": false,
                    "placeholder": "Insectes blancs sous les feuilles"
                }]
        }, {
            "group_title": "Arrosage",
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
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
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
            "fields": [{
                    "name": "rampotage",
                    "label": "A quelle fréquence arrosez-vous votre plante ?",
                    "is_required": false,
                    "placeholder": "1 à 2 fois par semaine"
                }]
        }]
    property variant attached_images: []

    Popup {
        id: userDataPopup
        width: parent.width
        height: parent.height

        property bool submited: false

        background: Rectangle {
            radius: 15
            color: "#f5f5f5"
        }

        function extractFileNameFromURI(uri) {
          var parts = uri.split(/[\\\/]/); // Séparer l'URI par des slashs ou des backslashes
          return parts[parts.length - 1]; // Renvoyer la dernière partie qui est le nom du fichier
        }

        function submit() {
            loadingIndicator.running = true
            if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(
                        emailInput.text)) {
                // Collect form data
                let data = {}
                let html_string = ""

                for (var i = 0; i < form_schema.length; i++) {
                    html_string += `<h1>Partie ${i+1}${form_schema[i].group_title ? (": "+form_schema[i].group_title) : "" }</h1> <br/>`
                    for (var j = 0; j < form_schema[i].fields.length; j++) {
                        let item = form_schema[i].fields[j]
                        data[item.name] = item.value
                        html_string += `<strong>${item.label}</strong> <br/> ${item.value || ''} <hr/><br/><br/>`
                    }
                }

                let pre_content = `<h1>Blume: demande d'assitance</h1><br/>`
                pre_content += `Utilisateur: ${emailInput.text} <br/> Date: ${(new Date()).toLocaleDateString()} <br/><br/><br/>`

                // Format data for mailing
                let formatedData = {
                   "to": emailInput.text,
                   "recv_name": "Client",
                   "subject": "Blume: demande de l'avis d'un expert",
                   "content_html": pre_content + html_string,
                    "attachements": attached_images.filter(item => item.uri).map((item, index) => {
                                                                                     return {
                                                                                       "ContentType": "text/plain",
                                                                                       "Filename": extractFileNameFromURI(item.uri),
                                                                                       "Base64Content": item.content
                                                                               }
                                                                                 })
                }

                // Send mail
                Http.send_mail(formatedData).then(res => {
                                           loadingIndicator.running = false
                                            userDataPopup.submited = true
                                       }).catch(
                            res => {
                                loadingIndicator.running = false
                                errorArea.visible = true
                                console.log(JSON.stringify(res))
                            })
            } else {
                loadingIndicator.running = false
                txtError.visible = true
            }
        }

        Column {
            visible: !userDataPopup.submited
            width: parent.width
            anchors.centerIn: parent

            spacing: 10

            Label {
                text: "Votre adresse email"
                font {
                    pixelSize: 16
                    weight: Font.Bold
                }
                width: parent.width
                wrapMode: Text.Wrap
            }

            TextField {
                id: emailInput
                placeholderText: "ex: jonh@gmail.com"
                padding: 5

                width: parent.width
                height: 50

                validator: RegularExpressionValidator { regularExpression: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }

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

                onAccepted: userDataPopup.submit()
                onTextChanged: {
                    txtError.visible = false
                    form_schema[0].fields[0].value = text
                }
            }

            Label {
                id: txtError
                visible: false
                text: "Votre adresse email est incorrecte"
                color: 'red'
                font {
                    weight: Font.Light
                    pixelSize: 14
                }
            }

            RowLayout {
                width: parent.width

                ButtonWireframe {
                    id: backBtn
                    text: "Retour"
                    fullColor: Material.color(Material.Grey, Material.Shade400)
                    fulltextColor: "back"
                    componentRadius: 10
                    padding: 25
                    topPadding: 5
                    bottomPadding: 5
                    onClicked: {
                        emailInput.text = ""
                        txtError.visible = false
                        userDataPopup.close()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ButtonWireframe {
                    id: sendBtn
                    text: "Envoyer"
                    fullColor: Theme.colorPrimary
                    fulltextColor: "white"
                    componentRadius: 10
                    padding: 25
                    topPadding: 5
                    bottomPadding: 5

                    onClicked: userDataPopup.submit()
                }


            }

        }

        ColumnLayout {
            visible: userDataPopup.submited
            width: parent.width - 30
            anchors.centerIn: parent
            spacing: 10
            IconSvg {
                source: Icons.checkCircleOutline
                color: Theme.colorPrimary
                Layout.preferredHeight: 100
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: "Votre requête est bien reçue et sera traitée dans les plus bref délais"
                color: Theme.colorPrimary
                font {
                    pixelSize: 16
                    weight: Font.Bold
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }

        Container {
            id: errorArea
            anchors.top: parent.top
            width: parent.width
            visible: userDataPopup.submited
            onVisibleChanged: errorTimer.start()

            Timer {
                id: errorTimer
                interval: 3000
                running: false
                repeat: false
                onTriggered: errorArea.visible = false

            }


            contentItem:  ColumnLayout {
                width: parent.width
                spacing: 10
            }

            IconSvg {
                source: Icons.alertBoxOutline
                color: Material.color(Material.Red, Material.Shade500)
                Layout.preferredHeight: 100
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: "Veuillez vérifier votre connexion internet et reéssayez"
                font {
                    pixelSize: 14
                    weight: Font.Light
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }


        }


        BusyIndicator {
            id: loadingIndicator
            running: false
            anchors.centerIn: parent
        }
    }

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

                        spacing: 15

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

                                Image2Base64 {
                                    id: imgTool
                                }

                                Repeater {
                                    model: 4
                                    ImagePickerArea {
                                        required property int index
                                        width: 70
                                        height: 70
                                        onImgChanged: function () {
                                            let b64str = imgTool.getBase64(
                                                image_source.toString().replace(
                                                    Qt.platform.os
                                                    === "windows" ? "file:///" : "file://",
                                                    ""))
                                            attached_images[index] = {
                                                content: b64str,
                                                uri: image_source.toString()
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        FormGroup {
                            id: form01
                            schema: form_schema.slice(1)
                        }

                        RowLayout {
                            width: parent.width - (2*parent.padding)
                            Item {
                                Layout.fillWidth: true
                            }
                            ButtonWireframe {
                                text: "Suivant"
                                fullColor: Theme.colorPrimary
                                fulltextColor: "white"
                                componentRadius: 10
                                padding: 25
                                topPadding: 5
                                bottomPadding: 5

                                onClicked: userDataPopup.open()
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
