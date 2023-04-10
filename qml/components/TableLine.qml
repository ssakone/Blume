import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    Layout.minimumHeight: _row.height + 20

    color: bgColor
    radius: 5

    property color bgColor: "#edeff2"
    property string title: ""
    property string description: ""

    RowLayout {
        id: _row
        width: parent.width

        Label {
            text: title
            font.pixelSize: 16

            Layout.topMargin: 5
            Layout.leftMargin: 7
            Layout.minimumWidth: 150
            wrapMode: Text.Wrap
            Layout.alignment: Qt.AlignTop
        }

        Label {
            id: _text
            text: description
            font.pixelSize: 14
            font.weight: Font.Light

            Layout.topMargin: 5
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.Wrap
        }


    }
}
