import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle {
    id: root
    width: parent.width
    height: main.height
    color: is_opened ? content_color_expanded : content_color
    radius: 10


    property bool is_opened: false
    property string header: ""
    property string content: ""

    property color header_color: "#edeff2"
    property color header_color_expanded: "#ccc"

    property color content_color: "#f0f0f0"
    property color content_color_expanded: "#edeff2"

    property int header_radius: 10
    property alias contentItems: trueContent.children


    property string header_icon_src: "qrc:/assets/icons_material/baseline-info-24px.svg"
    property string closed_icon_src: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"
    property string opened_icon_src:  "qrc:/assets/icons_material/baseline-close-24px.svg"
    property string content_text: ""

    property int expanded_height_min: 60

    Component.onCompleted: {
        contentItems.forEach((item, index) => {
                            main.children[index] = item
        })
    }

    MouseArea {
        anchors.fill: parent
        onClicked: is_opened = !is_opened
    }

    ColumnLayout {
        id: main
        width: parent.width
        spacing: 0

        Rectangle {

            Layout.preferredWidth: parent.width
            Layout.preferredHeight: header_content.height + 20
            color: is_opened ? header_color_expanded : header_color

            radius: header_radius
            RowLayout {
                id: header_content
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
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
                }

                IconSvg {
                    source: is_opened ? opened_icon_src : closed_icon_src
                    width: 60
                    height: 60
                }
            }

        }

        ColumnLayout {
            id: trueContent
            visible: is_opened
            enabled: is_opened

            Layout.fillWidth: true

        }
    }

}
