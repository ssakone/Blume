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
    id: askPage
    property string currentObj: ""
    header: AppBar {
        title: qsTr("Ask a botanist about")
        foregroundColor: $Colors.white
        backgroundColor: $Colors.colorPrimary
    }

    property variant form_schema: [{
            "group_title": "",
            "fields": [{
                    "name": "user_email",
                    "label": "User email",
                    "is_required": true,
                    "placeholder": ""
                }]
        }, {
            "group_title": "",
            "fields": [{
                    "name": "description",
                    "label": "Describe the issue",
                    "is_required": true,
                    "placeholder": "",
                    "type": "textarea"
                }]
        }, {
            "group_title": "Exposure and temperature",
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
            "fields": [{
                    "name": "sun_time",
                    "label": "How much sun your plant gets each day ?",
                    "is_required": true,
                    "placeholder": "6h a day"
                }, {
                    "name": "sun_temp",
                    "label": "What are the temperatures of its environment ?",
                    "is_required": false,
                    "placeholder": "Day: +24°C, Night: +1°C"
                }]
        }, {
            "group_title": "Parasites and diseases",
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
            "fields": [{
                    "name": "disease_list",
                    "label": "Are there webs or insects on the plant or in the soil ?",
                    "is_required": false,
                    "placeholder": "White insects under the leaves"
                }]
        }, {
            "group_title": "Arrosage",
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
            "fields": [{
                    "name": "watering_freq",
                    "label": "How often do you water your plant ?",
                    "is_required": false,
                    "placeholder": "1 to 2 times a week"
                }, {
                    "name": "watering_qty",
                    "label": "How much water do you use ?",
                    "is_required": false,
                    "placeholder": "A glass and a half"
                }, {
                    "name": "watering_drying",
                    "label": "Do you let the soil dry between waterings?",
                    "is_required": false,
                    "placeholder": "Yes, the first few inches"
                }, {
                    "name": "watering_container",
                    "label": "Is the bottom of the jar pierced?",
                    "is_required": false,
                    "placeholder": "yes"
                }]
        }, {
            "group_title": "Potting and fertilizing",
            "group_icon": "qrc:/assets/icons_material/baseline-autorenew-24px.svg",
            "fields": [{
                    "name": "rampotage",
                    "label": "How often do you pot your plant ?",
                    "is_required": false,
                    "placeholder": "1 to 2 times a year"
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
            var parts = uri.split(/[\\\/]/)
            // Séparer l'URI par des slashs ou des backslashes
            return parts[parts.length - 1] // Renvoyer la dernière partie qui est le nom du fichier
        }

        function submit() {
            loadingIndicator.running = true
            if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(
                        emailInput.text)) {
                // Collect form data
                let data = {}
                let html_string = ""

                for (var i = 0; i < form_schema.length; i++) {
                    html_string += `<h1>Partie ${i + 1}${form_schema[i].group_title ? (": " + form_schema[i].group_title) : ""}</h1> <br/>`
                    for (var j = 0; j < form_schema[i].fields.length; j++) {
                        let item = form_schema[i].fields[j]
                        data[item.name] = item.value
                        html_string += `<strong>${item.label}</strong> <br/> ${item.value
                                || ''} <hr/><br/><br/>`
                    }
                }

                let pre_content = `<h1>Blume: demande d'assitance</h1><br/>`
                pre_content += `Utilisateur: ${emailInput.text} <br/> Date: ${(new Date()).toLocaleDateString(
                            )} <br/><br/><br/>`

                // Format data for mailing
                let formatedData = {
                    "to": emailInput.text,
                    "recv_name": "Client",
                    "subject": "Blume: demande de l'avis d'un expert",
                    "content_html": pre_content + html_string,
                    "attachements": attached_images.filter(
                                        item => item.uri).map((item, index) => {
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
                                                  }).catch(res => {
                                                               loadingIndicator.running = false
                                                               errorArea.visible = true
                                                               console.log(
                                                                   JSON.stringify(
                                                                       res))
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
                text: qsTr("Your email address")
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

                validator: RegularExpressionValidator {
                    regularExpression: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/
                }

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
                text: qsTr("Incorrect email address")
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
                    text: qsTr("Back")
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
                    text: qsTr("Submit")
                    fullColor: $Colors.colorPrimary
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
                color: $Colors.colorPrimary
                Layout.preferredHeight: 100
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: qsTr("Your request is received and will be processed as soon as possible")
                color: $Colors.colorPrimary
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

            contentItem: ColumnLayout {
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
                text: qsTr(
                          "Please check your internet connection and try again")
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
            color: $Colors.colorPrimary

            ColumnLayout {
                anchors.fill: parent

                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Label {
                    text: qsTr("You will receive a diagnosis and care plan within three days of completing this form.")
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
                                text: qsTr("Attach images")
                                font {
                                    pixelSize: 16
                                    weight: Font.Bold
                                }

                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Label {
                                text: qsTr("Photograph the entire plant as well as the parts that appear diseased.")
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
                                                    image_source.toString(
                                                        ).replace(
                                                        Qt.platform.os
                                                        === "windows" ? "file:///" : "file://",
                                                        ""))
                                            attached_images[index] = {
                                                "content": b64str,
                                                "uri": image_source.toString()
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
                            width: parent.width - (2 * parent.padding)
                            Item {
                                Layout.fillWidth: true
                            }
                            ButtonWireframe {
                                text: qsTr("Next")
                                fullColor: $Colors.colorPrimary
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
