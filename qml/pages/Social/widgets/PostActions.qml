import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qaterial as Qaterial

Qaterial.ClipRRect {
    id: control
    width: parent.width
    height: parent.height - 70
    radius: 30
    z: 100
    //visible: false

    function display () {
        drawer.open()
        //drawerLoader.active = true
    }

    function close () {
        drawer.close()
        //drawerLoader.active = false
    }

    Component {
        id: successPage
        Item {
            Column {
                anchors.centerIn: parent
                spacing: 10
                IconImage {
                    width: 300
                    height: width
                    source: Qaterial.Icons.check
                    color: $Colors.colorPrimary
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 200
                    text: qsTr("Your report have been submitted !")
                }

                Button {
                    text: qsTr("Close")
                    width: 200
                    height: 50
                    onClicked: control.close()
                    anchors.horizontalCenter: parent.horizontalCenter

                    background: Rectangle {
                        color: $Colors.colorPrimary
                    }
                }
            }
        }
    }

    Component {
        id: mainPage
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: insideCol.height
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: insideCol
                width: parent.width
                leftPadding: 10
                rightPadding: 10

                Column {
                    width: parent.width - 20
                    Rectangle {
                        radius: 5
                        width: parent.width
                        height: _insideCol1.height
                        color: "white"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: postOptionsView.push(reportPostReasonPage)
                        }

                        Column {
                            id: _insideCol1
                            width: parent.width
                            padding: 10

                            RowLayout {
                                width: parent.width - 20
                                spacing: 10
                                IconImage {
                                    source: Qaterial.Icons.commentAlert
                                }
                                Column {
                                    Layout.fillWidth: true
                                    Label {
                                        text: qsTr("Report this post")
                                        font.weight: Font.DemiBold
                                        font.pixelSize: 16
                                    }
                                    Label {
                                        text: qsTr("The author won't know who reported him")
                                        width: parent.width
                                        wrapMode: Label.Wrap
                                    }
                                }
                            }

                        }

                    }
                }
            }
        }
    }

    Component {
        id: reportPostReasonPage
        Item {

            Flickable {
                anchors.fill: parent
                contentHeight: insideCol.height + 100
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: insideCol
                    width: parent.width
                    leftPadding: 10
                    rightPadding: 10


                    Column {
                        width: parent.width - 20
                        spacing: 10
                        Row {
                            IconImage {
                                source: Qaterial.Icons.chevronLeft
                                width: 50
                                height: width
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: postOptionsView.pop()
                                }
                            }
                            Label {
                                text: qsTr("Report")
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Repeater {
                            model: 20
                            Rectangle {
                                radius: 5
                                width: parent.width
                                height: _insideCol1.height
                                color: "white"
                                Column {
                                    id: _insideCol1
                                    width: parent.width
                                    padding: 10

                                    Row {
                                        spacing: 10
                                        CheckBox {
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Label {
                                            text: qsTr("Violence")
                                            font.weight: Font.DemiBold
                                            font.pixelSize: 16
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                }

                            }
                        }
                    }
                }
            }

            Button {
                width: 150
                height: 50
                text: qsTr("Confirm")
                onClicked: postOptionsView.push(successPage)

                background: Rectangle {
                    color: $Colors.colorPrimary
                }

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15

                anchors {
                    right: parent.right
                    rightMargin: 10
                }
            }
        }

    }


    FocusScope {
        anchors.fill: parent
        Keys.onBackPressed: console.log("Back back")
        Drawer {
                id: drawer
                width: parent.width
                height: parent.height
                edge: Qt.BottomEdge
                dim: false
                modal: true
                interactive: true

                background: Rectangle {
                    color: Qaterial.Colors.lightBlue50
                }

                onClosed: {
                    postOptionsView.clear()
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20

                    Rectangle {
                        width: 80
                        height: 7
                        color: Qaterial.Colors.gray400
                        radius: 2
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 15
                    }

                    StackView {
                        id: postOptionsView
                        initialItem: mainPage
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }



    }

}
