import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ThemeEngine 1.0

import "../components_generic"
import "../components/"
import "../"

Page {
    header: AppBar {
        title: "FAQ"
    }
    Flickable {
        anchors.fill: parent
        width: parent.width
        height: parent.height
        contentHeight: colHeadFaqSimple.height
        Column {
            id: colHeadFaqSimple
            width: parent.width
            topPadding: 10
            spacing: 20

            Label {
                text: qsTr("Frequently asked questions")
                color: $Colors.colorPrimary
                font.pixelSize: 32
                wrapMode: Text.Wrap
                width: parent.width
                horizontalAlignment: Label.AlignHCenter
            }

            Column {
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 1

                Repeater {
                    model: 12
                    delegate: Accordion {
                        id: according
                        header_color: Qt.lighter("#ccc")
                        content_color_expanded: "white"
                        header_radius: 0
                        header: "Question " + index

                        contentItems: [
                            Label {
                                text: "Sed at orci accumsan, pretium lorem sed, varius erat. Nunc id urna vitae diam laoreet maximus in at sapien. Maecenas eu massa augue. Proin nisi risus, consectetur sit amet efficitur eget, pharetra in felis. Quisque pretium neque nulla, eu pretium est hendrerit nec. Cras quis scelerisque neque. Nunc dignissim sem nec est vehicula congue. Donec sapien metus, lacinia vel sapien vitae, consectetur dictum ipsum. Nulla sagittis ante eget sem vestibulum cursus. "
                                wrapMode: Text.Wrap
                                width: according.width - 20

                                font.pixelSize: 14
                                font.weight: Font.Light
                            }
                        ]
                    }
                }
            }
        }
    }

    ButtonWireframe {
        text: qsTr("Contacting an expert")
        componentRadius: 15
        fullColor: $Colors.colorPrimary
        fulltextColor: "white"
        onClicked: page_view.push(askMore)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        anchors.right: parent.right
        anchors.rightMargin: 20
    }
}
