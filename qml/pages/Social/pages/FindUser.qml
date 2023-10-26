import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SortFilterProxyModel
import Qaterial as Qaterial
import "../components"

Page {
    id: page
    ColumnLayout {
        anchors.fill: parent
        Column {
            id: headerColumn
            Layout.fillWidth: true
            leftPadding: 5
            rightPadding: 5
            topPadding: 10
            bottomPadding: 25
            spacing: 20
            RowLayout {
                width: parent.width - 30
                height: 60
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10

                Row {
                    id: globalBackBtn
                    Layout.fillWidth: true

                    IconImage {
                        width: 60
                        height: width
                        source: Qaterial.Icons.chevronLeftCircleOutline
                        color: $Colors.colorPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                view.pop()
                            }
                        }

                    }

                    Label {
                        text: qsTr("Search for friend")
                        font.pixelSize: 18
                        color: Qaterial.Colors.gray600
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }


                ToolBarButton {
                    id: inputBackBtn
                    visible: false
                    Layout.preferredHeight: 45
                    Layout.preferredWidth: 45
                    icon {
                        source: Qaterial.Icons.chevronLeft
                        color: $Colors.colorPrimary
                    }
                    onClicked: {
                        visible = false
                        spacer.visible = true
                        globalBackBtn.visible = true
                        searchBtn.visible = true
                        searchInput.visible = false
                        searchInput.focus = false
                    }
                }



                TextField {
                    id: searchInput
                    property bool busy: false
                    visible: false
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    font.pixelSize: 16
                    padding: 5
                    leftPadding: 10
                    rightPadding: 10
                    placeholderText: qsTr("Search for a friend")
                    background: Rectangle {
                        color: Qaterial.Colors.gray100
                        radius: 15
                    }
                    onTextChanged: {
                        searchInput.busy = true
                        http.searchProfile(text).then(
                                    function (res) {
                                        contactListView.model = JSON.parse(
                                                    res)
                                        searchInput.busy = false
                                    }).catch(function (err) {
                                        console.log(err)
                                        console.log(JSON.stringify(err))
                                        searchInput.busy = false
                                    })
                    }
                    BusyIndicator {
                        running: searchInput.busy
                        width: 30
                        height: width
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 15
                        }
                    }
                }

                Item {
                    id: spacer
                    visible: true
                    Layout.fillWidth: true
                }

                ToolBarButton {
                    id: searchBtn
                    visible: true
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    icon.source: Qaterial.Icons.magnify
                    onClicked: {
                        visible = false
                        spacer.visible = false
                        globalBackBtn.visible = false
                        inputBackBtn.visible = true
                        searchInput.visible = true
                        searchInput.focus = true
                        searchInput.text = ""
                        mouseContext.enabled = true
                    }
                }
            }

            Column {
                id: categoriesColumn
                width: parent.width
                leftPadding: 10
                rightPadding: 10
                Label {
                    text: qsTr("Categories")
                    font {
                        weight: Font.DemiBold
                        pixelSize: 16
                    }
                }
                Row {
                    spacing: 10
                    Label {
                        text: qsTr("All")
                        color: $Colors.gray600
                        padding: 5
                        background: Rectangle {
                            radius: 5
                            border {
                                width: 1
                                color: $Colors.colorPrimary
                            }
                        }
                    }
                    Label {
                        text: qsTr("Friends")
                        color: $Colors.gray600
                        padding: 5
                        background: Rectangle {
                            radius: 5
                            border {
                                width: 1
                                color: $Colors.colorPrimary
                            }
                        }
                    }
                }
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                anchors.fill: parent
                contentHeight: insideCol.height
                clip: true

                Column {
                    id: insideCol
                    width: parent.width
                    padding: 10

                    Flow {
                        id: grid
                        width: parent.width - 20
                        spacing: 10

                        Repeater {
                            id: contactListView
                            delegate: Rectangle {
                                required property var modelData
                                width: grid.width / 2.1
                                height: insideDelegateColumn.height
                                radius: 5
                                color: Qt.rgba(0,0,0,0)
                                border {
                                    width: 1
                                    color: Qaterial.Colors.gray200
                                }
                                anchors.bottomMargin: 20
                                Column {
                                    id: insideDelegateColumn
                                    spacing: 5
                                    width: parent.width - 10

                                    Qaterial.ClipRRect {
                                        width: parent.width
                                        height: width * (9/16)
                                        radius: 5

                                        Image {
                                            anchors.centerIn: parent
                                            anchors.fill: parent
                                            fillMode: Image.PreserveAspectCrop
                                            source: JSON.parse(modelData["profile"]
                                                               || "{}").picture
                                                    || Qaterial.Icons.faceManProfile
                                        }
                                    }

                                    Column {
                                        spacing: 5
                                        width: parent.width
                                        padding: 7

                                        Label {
                                            text: modelData.name || modelData.username
                                            width: parent.width
                                            elide: Label.ElideRight
                                            color: $Colors.colorPrimary
                                            font {
                                                pixelSize: 16
                                                weight: Font.DemiBold
                                            }
                                        }
                                        RowLayout {
                                            spacing: 5
                                            IconImage {
                                                source: Qaterial.Icons.mapMarker
                                                color: Qaterial.Colors.blue800
                                            }

                                            Label {
                                                text: "France, Paris"
                                                Layout.fillWidth: true
                                                wrapMode: Label.Wrap
                                                color: Qaterial.Colors.gray400
                                                font {
                                                    pixelSize: 12
                                                    weight: Font.Light
                                                }
                                            }
                                        }
                                        RowLayout {
                                            width: parent.width - 10
                                            spacing: 10
                                            NiceButton {
                                                Layout.fillWidth: true
                                                text: qsTr("Add")
                                                radius: 5
                                                padding: 5
                                                backgroundColor: $Colors.colorPrimary
                                                foregroundColor: "white"
                                            }
                                            NiceButton {
                                                Layout.fillWidth: true
                                                text: qsTr("Delete")
                                                radius: 5
                                                padding: 5
                                                backgroundColor: Qt.rgba(0,0,0,0)
                                                foregroundColor: $Colors.colorPrimary
                                                backgroundBorderWidth: 1
                                                backgroundBorderColor: $Colors.colorPrimary
                                            }
                                        }

                                    }
                                }

                            }
                        }
                    }
                }
            }

            MouseArea {
                id: mouseContext
                enabled: false
                anchors.fill: parent
                onClicked: {
                    console.log("CLICKKP ")
                    searchInput.focus = false
                    enabled = false
                }
            }

        }
    }
}
