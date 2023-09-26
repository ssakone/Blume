import QtQuick
import QtQuick.Controls
import HotWatchBackend

import Qaterial as Qaterial

ApplicationWindow {
    id: windowGlobal
    visible: true
    minimumWidth: 480
    minimumHeight: 960

    flags: (Qt.platform.os === "android") ? Qt.Window : Qt.Window
                                            | Qt.MaximizeUsingFullscreenGeometryHint
    property string ip: "10.0.2.2:8000"
    //color: Theme.colorBackground
    Loader {
        id: loader
        active: true
        source: `http://${ip}/MobileApplication.qml`
        anchors.fill: parent
    }

    Qaterial.RoundButton {
        icon.source: Qaterial.Icons.refresh
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 50
        anchors.rightMargin: 20
        backgroundColor: Qaterial.Colors.gray
        onClicked: {
            loader.source = ""
            HotWatcher.clearCache()
            loader.source = `http://${ip}/MobileApplication.qml`
        }
    }

    Component.onCompleted: {
        Qaterial.Style.theme = Qaterial.Style.Theme.Light
    }
}
