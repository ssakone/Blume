import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../components_generic"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property alias icon: iconSvg

    property bool time_inline: true
    property string hours: "15"
    property string minutes: "00"

    property var onClicked

    radius: 15
    border {
        color: "#e5e5e5"
        width: 1
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 5
            rightMargin: 5
        }
        spacing: 10
        Rectangle {
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            radius: 15
            color: "#fefefe"

            IconSvg {
                id: iconSvg
                anchors.centerIn: parent
            }
        }


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                Layout.fillHeight: true
            }

            Label {
                text: title
                font.pixelSize: 18
                Layout.fillWidth: true
                clip: true
            }

            Label {
                text: subtitle
                font.pixelSize: 14
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Item {
                Layout.fillHeight: true
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: "#ccc"
        }

        Column {
            visible: !time_inline
            Layout.preferredWidth: 50
            Label {
                text: qsTr(hours)
                font.pixelSize: 24
                color: Theme.colorPrimary
            }

            Label {
                text: qsTr(minutes)
                font.pixelSize: 24
                color: Theme.colorPrimary
            }
        }
       Label {
           visible: time_inline
            text: qsTr(hours + ":" + minutes)
            font.pixelSize: 24
            color: Theme.colorPrimary
        }


    }

    MouseArea {
        anchors.fill: parent
        cursorShape: "PointingHandCursor"
        onClicked: root.onClicked()

    }

}
