import QtQuick
import QtQuick.Controls
import QtQuick.Window

import QtCore

import ThemeEngine 1.0
import DeviceUtils 1.0

import "../pages/Plant/"
import "../services/"
import "../components/"
import "../components_js/"
import "../components_js/Http.js" as HTTP

Item {
    id: _relay
    property alias space: spaceModel
    property alias plant: plantModel
    property alias alarm: alarmModel
    property alias device: deviceModel
    property alias globalPlant: _globalPlantList
    property alias plantSelect: _searchPopup
    property alias _colors: __colors
    property alias _sqliClient: __sqliClient
    ////// MODEL BEBIN ->
    PlantModel {
        id: plantModel
        db: _sqliClient
    }

    SpaceModel {
        id: spaceModel
        db: _sqliClient
    }

    AlarmModel {
        id: alarmModel
        db: _sqliClient
    }

    DeviceModel {
        id: deviceModel
        db: _sqliClient
    }

    // OTHER MODE
    ListModel {
        id: _globalPlantList
    }

    PlantSearchPopup {
        id: _searchPopup
    }

    Colors {
        id: __colors
    }

    function replaceNullWithEmptyString(obj) {
        for (let key in obj) {
            if (obj[key] === null) {
                delete obj[key]
            } else if (typeof obj[key] === "object") {
                replaceNullWithEmptyString(obj[key])
            }
        }
        return obj
    }

    SqlClient {
        id: __sqliClient
        dbName: Qt.platform.os == "ios" || Qt.platform.os
                == "android" ? Qt.resolvedUrl(
                                   StandardPaths.writableLocation(
                                       StandardPaths.AppDataLocation)).toString(
                                   ).replace(
                                   "file://",
                                   "") + "/db00001.db" : "db00001.sqlite3"
        Component.onCompleted: open()
        onDatabaseOpened: {
            const shoulReset = false
            if (shoulReset) {
                __sqliClient.execute("DROP TABLE "+alarm.tableName)
                __sqliClient.execute("DROP TABLE "+plant.tableName)
                __sqliClient.execute("DROP TABLE "+space.plantInSpace.tableName)
                __sqliClient.execute("DROP TABLE "+space.tableName)
                __sqliClient.execute("DROP TABLE "+device.tableName)
            }

            Promise.all([alarmModel.init(), plantModel.init(), spaceModel.init(
                             ), deviceModel.init()]).then(function (rs) {
                                 console.info("[+] All table ready")
                             }).catch(function (rs) {
                                 console.error("Something happen when loading DB tables => ", rs)
                             })
        }
    }

    ///// <- END MODEL
    Component.onCompleted: {
        $Http.request(
                    "GET",
                    "https://blume.mahoudev.com/items/Plantes?fields[]=*.*").then(
                    function (res) {
                        let datas = replaceNullWithEmptyString(JSON.parse(
                                                                   res).data)
                        for (var i = 0; i < datas.length; i++) {
                            _globalPlantList.append(datas[i])
                        }
                    }).catch(function (err) {
                        console.log(err)
                    })
    }
}
