import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Flickable {
    id: flickable
    property alias text: textArea.text
    property alias font: textArea.font
    property alias textArea: textArea
    flickableDirection: Flickable.VerticalFlick
    smooth: true
    antialiasing: true
    boundsMovement: Flickable.StopAtBounds
    boundsBehavior: Flickable.DragAndOvershootBounds
    NativeTextArea.flickable: NativeTextArea {
        id: textArea
        textFormat: Qt.RichText
        wrapMode: NativeTextArea.Wrap
        font.family: 'Roboto'
        font.pixelSize: 20
        selectByMouse: true
        selectByKeyboard: true
        leftPadding: 10
        rightPadding: 6
        topPadding: 0
        bottomPadding: 0
        background: null
        smooth: false
        overwriteMode: false
        renderType: Text.NativeRendering
        focusReason: Qt.NoFocusReason
        inputMethodHints:  Qt.ImhSensitiveData
        placeholderText: 'content...'
        placeholderTextColor: '#ccc'
        onLinkActivated: Qt.openUrlExternally(link)
    }
}
