import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtQuick.Controls.Material
import ThemeEngine 1.0

import "../components_generic/"
import "../components_themed/"

Repeater {
    required property variant schema

    //    function validate() {
    //        for (var i = schema.length - 1; i >= 0; i--) {
    //            for (var j = schema[i].fields.length - 1; j >= 0; j--) {
    //                let item = schema[i].fields[j]
    //                if(item.validate) {
    //                    if(item.validate(item.value) !== null) return item
    //                } else if(validate_field(item)) return item
    //            }
    //        }
    //        return null
    //    }

    //    function validate_field(field) {
    //        if(field.is_required && !field.value) return field
    //    }
    model: schema
    delegate: Column {
        required property variant modelData
        required property int index
        property int group_index: index

        width: parent.width - (2 * parent.padding)
        spacing: 15

        Row {
            width: parent.width
            spacing: 10

            IconSvg {
                source: modelData.group_icon || ""
                width: 30
                height: 30
                color: Theme.colorPrimary
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: modelData.group_title
                font {
                    pixelSize: 13
                    weight: Font.Bold
                    capitalization: Font.AllUppercase
                }
                color: Theme.colorPrimary
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                wrapMode: Text.Wrap
            }
        }

        Repeater {
            model: modelData.fields
            delegate: Column {
                required property variant modelData
                required property int index

                width: parent.width
                spacing: 7
                Label {
                    text: (modelData.is_required ? "* " : "") + modelData.label
                    font {
                        pixelSize: 16
                        weight: Font.Bold
                    }
                    width: parent.width
                    wrapMode: Text.Wrap
                }

                TextField {
                    visible: modelData.type === undefined
                    placeholderText: modelData?.placeholder
                    padding: 5

                    width: parent.width
                    height: 50

                    verticalAlignment: Text.AlignVCenter

                    font {
                        pixelSize: 14
                        weight: Font.Light
                    }

                    background: Rectangle {
                        radius: 15
                        color: "#f5f5f5"
                        border {
                            color: "#ccc"
                            width: 1
                        }
                    }
                    onTextChanged: schema[group_index].fields[index].value = text
                }

                TextArea {
                    visible: modelData.type === "textarea"
                    enabled: visible
                    width: parent.width
                    height: 120
                    padding: 7
                    topPadding: 10
                    focus: false
                    font {
                        pixelSize: 14
                        weight: Font.Light
                    }
                    wrapMode: Text.Wrap
                    background: Rectangle {
                        color: "#f5f5f5"
                        radius: 15
                        border {
                            width: 1
                            color: "#ccc"
                        }
                    }
                    onTextChanged: schema[group_index].fields[index].value = text
                }
            }
        }
    }
}
