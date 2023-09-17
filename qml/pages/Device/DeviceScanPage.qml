import QtQuick
import QtQuick.Controls
import "../../components_generic"
import "../../components"

BPage {
    property int spaceID
    property string spaceName: ""
    property string spaceDescription: ""
    property bool isOutDoor: false
    property bool shouldCreate: spaceName === "" && spaceDescription === ""
    property var callback: function () {}


    background.opacity: 0.5
//    background.color: Qt.rgba(12, 200, 25, 0)


    header: AppBar {
        id: header
        title: shouldCreate ? qsTr("Créer une nouvelle salle") : qsTr("Modifier la salle")
        statusBarVisible: false
        leading.icon: Icons.close
        color: Qt.rgba(12, 200, 25, 0)
        foregroundColor: $Colors.colorPrimary

        ButtonWireframeIcon {
            visible: spaceID
            height: 36
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            primaryColor: $Colors.red300
            secondaryColor: Qt.rgba(0, 0, 0, 0)
            fulltextColor: $Colors.colorPrimary

            background: Item {}

            source: Icons.trashCan
            sourceSize: 30

            onClicked: confirmRoomDeletionPopup.open()
        }
    }
    Flickable {
        anchors.fill: parent
        contentHeight: _insideCol.height
        Column {
            id: _insideCol
            padding: 10
            width: parent.width - 2*padding
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Scan en cours...")
                font {
                    weight: Font.DemiBold
                    pixelSize: 24
                }
            }

            Image {
                width: parent.width
                source: "qrc:/assets/icons_custom/radar-sensors.svg"
            }

            Column {
                width: parent.width
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Scan en cours...")
                    font {
                        weight: Font.DemiBold
                    }
                }
            }

        }
    }
}
