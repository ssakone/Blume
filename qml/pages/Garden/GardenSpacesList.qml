import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ThemeEngine

import "../../components"
import "../../components_generic"
import SortFilterProxyModel

BPage {
    id: control
    header: AppBar {
        id: header
        title: qsTr("Liste des salles")
        statusBarVisible: false
//        leading.icon: Icons.close
        color: Qt.rgba(12, 200, 25, 0)
        foregroundColor: $Colors.colorPrimary
    }

    SortFilterProxyModel {
        id: sortedSpaceModel
        sourceModel: $Model.space

        sorters: StringSorter {
            roleName: "libelle"
            sortOrder: Qt.AscendingOrder
        }
    }

    RowLayout {
        anchors.fill: parent
        Item {
            Layout.preferredWidth: 10
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: sortedSpaceModel
            spacing: 10
            delegate: GardenSpaceLinePreview {
                width: control.width
                title: (libelle[0] === "'" ? libelle.slice(1, -1) : libelle)
                subtitle: description[0] === "'" ? description.slice(1, -1) : description
                isOutdoor: type === 1
                iconSource: type === 1 ? Icons.homeOutline : Icons.landFields
                onClicked: {
                    let data = {
                        "name": libelle,
                        "type": type,
                        "description": description,
                        "status": model.status ?? 0,
                        "space_id": id
                    }
                    page_view.push(navigator.gardenSpaceDetails, data)
                }
                imagesSourcesList: {
                    const result = []
                    for(let i = 0; i < $Model.space.plantInSpace.count; i++) {
                        let space = $Model.space.plantInSpace.get(i)
                        if(space.space_id === model.id) {
                            result.push(space)
                        }
                    }
                    return result
                }
            }
        }

        Item {
            Layout.preferredWidth: 10
        }
    }


    NiceButton {
        text: "+ Ajouter une nouvelle salle"
        height: 50
        radius: 30
        leftPadding: 10
        rightPadding: 10
        font.weight: Font.DemiBold
        anchors {
            bottom: parent.bottom
            bottomMargin: 30

            right: parent.right
            rightMargin: 20
        }

        onClicked: page_view.push(navigator.gardenEditSpace)

        Behavior on scale {
            NumberAnimation {
                duration: 50
                easing.type: Easing.InOutCubic
            }
        }

        Timer {
            id: animationTimer
            property double min: 1.0
            property double max: 1.15
            property bool up: true
            interval: 50
            repeat: true
            running: $Model.space.count === 0
            onTriggered: {
                if(up) {
                    if(parent.scale <= max) {
                        parent.scale += 0.01
                    } else {
                        up = false
                    }
                } else {
                    if(parent.scale >= min) {
                        parent.scale -= 0.01
                    } else {
                        up = true
                    }
                }

            }
        }

    }

}
