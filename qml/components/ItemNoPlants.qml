import QtQuick

import ThemeEngine 1.0

Rectangle {
    id: itemNoPlants
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -40


    width: singleColumn ? (parent.width*0.5) : (parent.height*0.4)
    height: width
    radius: width
    color: Theme.colorForeground

    property alias textItem: textItem
    signal clicked()

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.66
        height: width

        source: "qrc:/assets/logos/blume_monochrome.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorSubText
        opacity: 0.8
        smooth: true
    }

    Text {
        id: textItem
        anchors.top: parent.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("No plants found...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContentBig

        width: parent.width
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }
}
