import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components_generic"

ClipRRect {
    id: root
    property string title: ""
    property string subtitle: ""
    property string iconSource: ""


    radius: 15

    Rectangle {
        anchors.fill: parent
        radius: parent.radius

        border {
            color: "#e5e5e5"
            width: 1
        }

    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
            topMargin: 2
            bottomMargin: 2
        }
        spacing: 10

        Rectangle {
            Layout.preferredHeight:  75
            Layout.preferredWidth: 75
            Layout.alignment: Qt.AlignCenter

            IconSvg{
                anchors.fill: parent
                source: iconSource
                color: "black"
            }

        }


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                text: title
                font.pixelSize: 18
            }
            Label {
                text: subtitle
                font.pixelSize: 12
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
            Label {
                text: roomName || ""
                color: "white"
                padding: 5
                font.capitalization: Font.AllUppercase
                background: Rectangle{
                    color: Theme.colorPrimary
                    radius: 5
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: page_view.push(
                       navigator.gardenSpaceDetails,
                       {
                           space_name: root.title,
                           space_id: 1,
                       })
    }
}

