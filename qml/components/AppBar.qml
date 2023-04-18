import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import ThemeEngine 1.0

import "../"

Rectangle {
    id: control
    color: Theme.colorPrimary
    property alias leading: buttonBackBg
    property alias title: _label.text
    property alias titleLable: _label
    property alias actions: flowActions.children
    property bool noAutoPop: false

    width: parent.width
    height: screenPaddingStatusbar + screenPaddingNotch + 52

    RowLayout {
        width: parent.width
        anchors.verticalCenterOffset: (screenPaddingNotch + screenPaddingStatusbar) / 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
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
