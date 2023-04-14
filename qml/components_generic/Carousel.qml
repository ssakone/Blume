import QtQuick 2.15
import QtQuick.COntrols
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: plantScreenDetailsPopup.height / 3

    color: "#f0f0f0"
    radius: 10
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 2

        RowLayout {
            Layout.preferredHeight: 30
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

            Repeater {
                model : plant['images_maladies']
                delegate: Rectangle {
                    width: 10
                    height: 10
                    radius: 10
                    color: "black"
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }


        SwipeView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: plant['images_maladies']
                delegate: Image {
                    source: "https://blume.mahoudev.com/assets/"+model.modelData.directus_files_id
                }
            }

        }
    }
}

