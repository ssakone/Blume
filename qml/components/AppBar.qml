import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import ThemeEngine 1.0

import "../"

Rectangle {
    id: control
    color: backgroundColor
    property color backgroundColor: Theme.colorPrimary
    property color foregroundColor: Theme.colorHeaderContent
    property alias leading: buttonBackBg
    property alias title: _label.text
    property alias titleLabel: _label
    property alias actions: flowActions.children
    property bool noAutoPop: false
    property bool statusBarVisible: true

    width: parent.width
    height: statusBarVisible ? screenPaddingStatusbar + screenPaddingNotch
                               + 52 : screenPaddingNotch + 52

    RowLayout {
        width: parent.width
        anchors.verticalCenterOffset: statusBarVisible ? (screenPaddingNotch
                                                          + screenPaddingStatusbar) / 2 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        AppBarButton {
            id: buttonBackBg
            icon: "qrc:/assets/menus/menu_back.svg"
            Layout.preferredHeight: 64
            Layout.preferredWidth: 64
            Layout.alignment: Qt.AlignVCenter
            foregroundColor: control.foregroundColor
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
            color: control.foregroundColor
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
