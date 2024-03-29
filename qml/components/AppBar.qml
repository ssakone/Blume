import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import ThemeEngine 1.0

import "../"

import "../components_generic/"
import "../components_themed/"

Rectangle {
    id: control
    color: backgroundColor
    property color backgroundColor: Qt.rgba(12, 200, 25, 0)
    property color foregroundColor: $Colors.colorPrimary
    property alias leading: buttonBackBg
    property alias title: _label.text
    property alias titleLabel: _label
    property alias actions: flowActions.children
    property bool noAutoPop: false
    property bool statusBarVisible: Qt.platform.os === 'ios'
    property bool shouldPreventDefaultBackPress: false

    // You display a menu icon that opens drawer or back icon that go back inside current stack
    property bool isHomeScreen: false

    signal backButtonClicked

    width: parent.width
    height: statusBarVisible ? screenPaddingStatusbar + screenPaddingNotch
                               + 52 : screenPaddingNotch + 52

    onBackButtonClicked: {
        if(shouldPreventDefaultBackPress) return
        if (isHomeScreen)
            appDrawer.open()
        else if (!noAutoPop)
            control.parent.StackView.view.pop()
    }

    RowLayout {
        width: parent.width
        anchors.verticalCenterOffset: statusBarVisible ? (screenPaddingNotch
                                                          + screenPaddingStatusbar) / 2 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        AppBarButton {
            id: buttonBackBg
            icon {
                source: isHomeScreen ? "qrc:/assets/icons_material/baseline-menu-24px.svg" : Icons.close
//                color: foregroundColor
            }

            Layout.preferredHeight: 64
            Layout.preferredWidth: 64
            Layout.alignment: Qt.AlignVCenter
            foregroundColor: control.foregroundColor
            onClicked: backButtonClicked()
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
            //            Layout.preferredHeight: 64
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
