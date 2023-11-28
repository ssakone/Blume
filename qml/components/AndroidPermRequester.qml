import QtQuick
import QtAndroidTools

Loader {
    property var permissionsNameList: []
    property bool granted: false
    property string seed: "value"
    active: Qt.platform.os === "android" && permissionsNameList.length > 0
    sourceComponent: Component {
        Item {
            Connections {
                target: QtAndroidAppPermissions
                function onRequestPermissionsResults(results) {
                    console.log(JSON.stringify(results))
                    let areAllGranted = true
                    for (var i = 0; i < results.length; i++) {
                        if (results[i].granted === true) {
                            console.log(results[i].name, true)
                        } else {
                            if (QtAndroidAppPermissions.shouldShowRequestPermissionInfo(
                                        results[i].name) !== true) {
                                areAllGranted = false
                                console.log(results[i].name, false)
                            }
                        }
                    }
                    granted = areAllGranted
                }
            }
            Component.onCompleted: {
                QtAndroidAppPermissions.requestPermissions(
                                                       permissionsNameList)
            }
        }
    }
}
