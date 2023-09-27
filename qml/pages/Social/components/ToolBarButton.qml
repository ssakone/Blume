import QtQuick
import Qaterial as Qaterial
import QtQuick.Layouts

Item {
    id: control
    Layout.fillHeight: true
    Layout.preferredWidth: 60
    property alias icon: _button.icon
    signal clicked
    Qaterial.AppBarButton {
        id: _button
        height: 60
        width: 60
        anchors.centerIn: parent
        icon.width: 28
        icon.height: 28
        onClicked: control.clicked()
    }
}
