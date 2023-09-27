import QtQuick
import QtQuick.Controls
import Qaterial as Qaterial

MouseArea {
    height: 50
    width: 50
    property alias source: _insideImageButton.source
    property alias sourceWidth: _insideImageButton.width
    property alias sourceHeight: _insideImageButton.height

    Qaterial.RoundImage {
        id: _insideImageButton
        width: 32
        height: 32
        anchors.centerIn: parent
        source: `data:image/svg+xml,%3Csvg xmlns="http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg" width="512" height="512" viewBox="0 0 512 512"%3E%3Cpath fill="none" stroke="%23676767" stroke-linecap="round" stroke-linejoin="round" stroke-width="48" d="M328 112L184 256l144 144"%2F%3E%3C%2Fsvg%3E`
    }
}
