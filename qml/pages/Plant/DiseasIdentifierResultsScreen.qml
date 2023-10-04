import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../components_generic"
import "../../components"

BPage {

    property var resultsList: []
    required property string scanedImage
    required property bool isPlant
    required property int healthyProbability

    header: AppBar {
        title: ""
    }

    Item {
        anchors {
            fill: parent
            leftMargin: 15
            rightMargin: 15
        }

        Flickable {
            id: rootFlickable
            anchors.fill: parent
            contentHeight: insideCol.height + 50

            Column {
                id: insideCol
                width: parent.width
                spacing: 30

                Column {
                    id: selectedImageCol
                    width: parent.width
                    spacing: 10

                    Label {
                        color: $Colors.colorPrimary
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        text: qsTr("Your image")
                    }

                    ClipRRect {
                       width: parent.width
                       height: 180
                       radius: 20

                        Image {
                            anchors.fill: parent
                            source: scanedImage
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }

                ColumnLayout {
                    width: parent.width

                    Label {
                        color: $Colors.colorPrimary
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        text: qsTr("Detected diseases")
                        visible: isPlant
                    }

                    Rectangle {
                        visible: !isPlant
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        color: $Colors.red50
                       radius: 20

                        border {
                            width: 1
                            color: $Colors.red500
                        }

                        Column {
                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Image {
                                source: "qrc:/assets/img/flower-pot.png"
                                width: 100
                                height: width
                                anchors.horizontalCenter: parent.horizontalCenter

                            }

                            Label {
                                text: qsTr("Your image does not contain a plant")
                                color: $Colors.red500
                                width: parent.width / 2
                                wrapMode: Text.Wrap
                                font.pixelSize: 18
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                    }

                    Flow {
                        id: identifedPlantListView
                        visible: isPlant
                        Layout.fillWidth: true
                        clip: true
                        spacing: 10

                        Repeater {
                            model: resultsList

                            delegate: ItemDelegate {
                                id: card
                                required property int index
                                required property variant modelData

                                width: rootFlickable.width / 2.15
                                height: width + 60


                                ColumnLayout {
                                    anchors.fill: parent
                                    ClipRRect {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: width
                                        radius: 15

                                        Rectangle {
                                            anchors.fill: parent
                                            color: $Colors.colorTertiary
                                            Image {
                                                source: modelData["similar_images"][0]["url_small"]
                                                anchors.fill: parent
                                            }
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Label {
                                            text: modelData["name"]
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                            color: $Colors.colorPrimary
                                            width: parent.width
                                            elide: Text.ElideRight
                                        }
                                        Label {
                                            text: modelData["disease_details"]["local_name"]
                                            font.pixelSize: 11
                                            color: $Colors.colorPrimary
                                            width: parent.width
                                            elide: Text.ElideRight
                                        }
                                    }

                                }



                                onClicked: {
                                    page_view.push(navigator.deseaseDetailsPage, {
                                                       "desease_data": modelData
                                                   })

                                }
                            }

                        }


                    }


                }


            }

        }

    }



}
