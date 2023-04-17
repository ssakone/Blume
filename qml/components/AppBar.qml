import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import ThemeEngine 1.0

import "../"

Rectangle {
    id: control
    color: "#00c395"
    property alias leading: buttonBackBg
    property alias title: _label.text
    property alias titleLable: _label
    property alias actions: flowActions.children
    property bool noAutoPop: false

    width: parent.width
    height: Qt.platform.os == 'ios' ? 90 : 60

    RowLayout {
        width: parent.width
        anchors.verticalCenterOffset: Qt.platform.os == 'ios' ? 17 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        AppBarButton {
            id: buttonBackBg
            icon: "qrc:/assets/menus/menu_back.svg"
            Layout.preferredHeight: 64
            Layout.preferredWidth: 64
            Layout.alignment: Qt.AlignVCenter
            onClicked: {
                if (!noAutoPop)
                    control.parent.StackView.view.pop()
            }
        }
        Label {
            id: _label
            font.pixelSize: 21
            font.bold: true
            font.weight: Font.Medium
            color: "white"
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
        Flow {
            id: flowActions
            Layout.preferredHeight: 64
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
