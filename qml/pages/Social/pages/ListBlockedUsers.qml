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

                RowLayout {
                    id: globalBackBtn
                    Layout.fillWidth: true

                    IconImage {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: width
                        Layout.alignment: Qt.AlignVCenter
                        source: Qaterial.Icons.chevronLeftCircleOutline
                        color: $Colors.colorPrimary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                view.pop()
                            }
                        }

                    }

                    Label {
                        text: qsTr("Users you blocked")
                        font.pixelSize: 18
                        color: Qaterial.Colors.gray600
                        Layout.fillWidth: true
                        elide: Label.ElideRight
                        Layout.alignment: Qt.AlignVCenter
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

                    Column {
                        id: grid
                        width: parent.width - 20
                        spacing: 10

                        Repeater {
                            id: contactListView
                            model: Object.keys(root.blockedUsers)
                            delegate: Rectangle {
                                id: delegateItem
                                required property string modelData
                                property var user: root.author[modelData]
                                property var blockedFields: root.blockedUsers[modelData]
                                property bool arePostsBlocked: root.blockedUsers[modelData]["posts"]
                                property bool areDiscussionssBlocked: root.blockedUsers[modelData]["discussion"]
                                property bool updating: false


                                width: grid.width
                                height: insideDelegateColumn.height
                                radius: 5
                                color: Qt.rgba(0,0,0,0)
                                border {
                                    width: 2
                                    color: Qaterial.Colors.gray200
                                }
                                anchors.bottomMargin: 20

                                Column {
                                    id: insideDelegateColumn
                                    spacing: 5
                                    width: parent.width

                                    Qaterial.ClipRRect {
                                        width: parent.width
                                        height: width * (9/16)
                                        radius: 5

                                        Image {
                                            anchors.centerIn: parent
                                            anchors.fill: parent
                                            fillMode: Image.PreserveAspectCrop
                                            source: user?.picture
                                                    || Qaterial.Icons.faceManProfile // qrc:/assets/icons_custom/default-profile.svg
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: view.push(userProfile, {"profile": user})
                                        }
                                    }

                                    Column {
                                        spacing: 5
                                        width: parent.width
                                        padding: 7

                                        Label {
                                            text: user.display_name || user.name || user.username
                                            width: parent.width
                                            elide: Label.ElideRight
                                            color: $Colors.colorPrimary
                                            font {
                                                pixelSize: 16
                                                weight: Font.DemiBold
                                            }
                                        }


                                        Flow {
                                            width: parent.width - 10
                                            spacing: 10

                                            NiceButton {
                                                enabled: !delegateItem.updating
                                                text: arePostsBlocked ? qsTr("Unlock posts") : qsTr("Block posts")
                                                radius: 5
                                                padding: 5
                                                icon {
                                                    source: arePostsBlocked ? Qaterial.Icons.lockOpen : Qaterial.Icons.lockOutline
                                                    color: arePostsBlocked ? Qaterial.Colors.white : Qaterial.Colors.red400
                                                }
                                                backgroundColor: arePostsBlocked ? $Colors.colorPrimary : Qt.rgba(0,0,0,0)
                                                foregroundColor: arePostsBlocked ?  "white" : $Colors.red400
                                                backgroundBorderWidth: 1
                                                backgroundBorderColor: delegateItem.arePostsBlocked ? $Colors.colorPrimary : $Colors.red400
                                                onClicked: {
                                                    delegateItem.updating = true
                                                    arePostsBlocked ? root.unblockUserPosts(modelData) : root.blockUserPosts(modelData)
                                                    delegateItem.updating = false
                                                }

                                                BusyIndicator {
                                                    running: delegateItem.updating
                                                    anchors.centerIn: parent
                                                    width: 40
                                                    height: width
                                                }
                                            }

                                            NiceButton {
                                                enabled: !delegateItem.updating
                                                text: areDiscussionssBlocked ? qsTr("Unlock discussion") : qsTr("Block discussion")
                                                radius: 5
                                                padding: 5
                                                icon {
                                                    source: areDiscussionssBlocked ? Qaterial.Icons.lockOpen : Qaterial.Icons.lockOutline
                                                    color: areDiscussionssBlocked ? Qaterial.Colors.white : Qaterial.Colors.red400
                                                }
                                                backgroundColor: areDiscussionssBlocked ? $Colors.colorPrimary : Qt.rgba(0,0,0,0)
                                                foregroundColor: areDiscussionssBlocked ?  "white" : $Colors.red400
                                                backgroundBorderWidth: 1
                                                backgroundBorderColor: delegateItem.areDiscussionssBlocked ? $Colors.colorPrimary : $Colors.red400
                                                onClicked: {
                                                    delegateItem.updating = true
                                                    delegateItem.areDiscussionssBlocked ? root.unblockUserDiscussion(modelData) : root.blockUserDiscussion(modelData)
                                                    delegateItem.updating = false
                                                }

                                                BusyIndicator {
                                                    running: delegateItem.updating
                                                    anchors.centerIn: parent
                                                    width: 40
                                                    height: width
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
