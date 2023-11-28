import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../components_generic"
import "../../components"

BPage {
    property var resultsList: []
    required property string scanedImage

    header: AppBar {
        title: ""
        statusBarVisible: false
    }


    Flickable {
        anchors {
            fill: parent
            leftMargin: 15
            rightMargin: 15
        }
        contentHeight: insideCol.height + 50

        Column {
            id: insideCol
            width: parent.width
            spacing: 30

            Column {
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

            Column {
                width: parent.width

                Label {
                    color: $Colors.colorPrimary
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    text: qsTr("Detected insects")
                }

                Flow {
                    id: resultsListView
                    width: parent.width
                    clip: true
                    spacing: 10

                    Repeater {
                        model: resultsList

                        delegate: ItemDelegate {
                            id: card
                            required property int index
                            required property variant modelData

                            width: resultsListView.width / 2.15
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
                                            source: modelData["details"]["image"]['value']
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
                                        text: modelData["details"]["common_names"]?.length > 0 ? modelData["details"]["common_names"][0] : ""
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }

                            }



                            onClicked: {
                                page_view.push(navigator.insectDetailPage, {insect_data: modelData})

                            }
                        }

                    }


                }
            }


        }
    }




}
