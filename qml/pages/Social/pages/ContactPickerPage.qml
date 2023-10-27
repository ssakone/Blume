import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SortFilterProxyModel
import Qaterial as Qaterial
import "../components"

Page {
    id: page
//    Component.onCompleted: {
//        http.searchProfile(" ").then(
//            function (res) {
//                contactListView.model = JSON.parse(
//                            res)
//                searchInput.busy = false
//            }).catch(function (err) {
//                console.log(err)
//                console.log(JSON.stringify(err))
//                searchInput.busy = false
//            })
//    }

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
                        text: qsTr("Search")
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
                    placeholderText: qsTr("Search")
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
                spacing: 10
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
            Layout.fillHeight: true
            Layout.fillWidth: true

            MouseArea {
                id: mouseContext
                enabled: false
                anchors.fill: parent
                onClicked: {
                    searchInput.focus = false
                    enabled = false
                }
            }

            Column {
                id: insideCol
                width: parent.width
                spacing: 25
                padding: 10

                ListView {
                    id: contactListView
                    model: friendLists.filter(f => f.is_pined !== true && f.pubkey !== publicKey)
                    width: parent.width - 20
                    height: page.height - (categoriesColumn.height + headerColumn.height)
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip: true
                    anchors.topMargin: 15
                    delegate: Item {
                        required property var modelData
                        width: contactListView.width
                        height: delegateInsideCol.height

                        MouseArea {
                            anchors.fill: parent
                            onClicked: view.replace(messagePage, {"friend": modelData})
                        }

                        Column {
                            id: delegateInsideCol
                            width: parent.width
                            spacing: 10
                            anchors.topMargin: 5
                            RowLayout {
                                width: parent.width
                                spacing: 10
                                Avatar {
                                    source: JSON.parse(modelData["profile"]
                                                       || "{}").picture
                                            || Qaterial.Icons.faceManProfile
                                }
                                Label  {
                                    text: modelData.name ?? modelData.username
                                    font.weight: Font.DemiBold
                                    Layout.fillWidth: true
                                    horizontalAlignment: Label.AlignLeft
                                }
                            }
                            Rectangle {
                                height: 2
                                width: parent.width
                                color: Qaterial.Colors.gray200
                            }
                        }
                    }
                }
            }
        }
    }
}
