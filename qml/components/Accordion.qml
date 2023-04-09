import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle {
    id: root
    width: parent.width
    height: main.height
    color: accrodion_color


    property bool is_opened: false
    property string header: ""
    property string content: ""
    property color accrodion_color: "white"


    property string header_icon_src: "qrc:/assets/icons_material/baseline-info-24px.svg"
    property string closed_icon_src: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
    property string opened_icon_src:  "qrc:/assets/icons_material/baseline-close-24px.svg"
    property string content_text: ""

    MouseArea {
        anchors.fill: parent
        onClicked: is_opened = !is_opened
    }

    ColumnLayout {
        id: main
        Layout.fillWidth: true
//        width: parent.width
//        anchors.fill: parent
        spacing: 0

        Rectangle {

            width: parent.width
            height: header_content.height + 20

            radius: 10
            RowLayout {
                id: header_content
                anchors.fill: parent
                IconSvg {
                    source: header_icon_src
                    width: 60
                    height: 60
                }
                Label {
                    text: header
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }
                Item {
                    Layout.fillWidth: true
                    height: 10
                }

                IconSvg {
                    source: is_opened ? opened_icon_src : closed_icon_src
                    width: 60
                    height: 60
                }
            }

        }

        Label {
            text: content

            visible: is_opened
            width: parent.width -20
            Layout.maximumWidth: width
            Layout.leftMargin: 10
            wrapMode: Text.Wrap
        }
    }

}
