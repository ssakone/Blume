import QtQuick

import "../services/"

Model {
    id: control
    property string __query__get__by_address: "SELECT * FROM %1 WHERE device_address = quote('%2')".arg(
                                                  tableName)

    property string __query__update__by__address: "UPDATE %1 %2 WHERE device_address = quote('%3')".arg(
                                                      tableName)

    property string __query__get__by__plant_id: "SELECT * FROM %1 WHERE plant_id = %2".arg(
                                                    tableName)

    property string __query__delete_all__by__plant_id: "DELETE FROM %1 WHERE plant_id = %2".arg(
                                                           tableName)

    debug: true
    tableName: "Device01"
    column: [{
            "name": "id",
            "type": "INTEGER",
            "key": "PRIMARY KEY"
        }, {
            "name": "device_address",
            "type": "TEXT"
        }, {
            "name": "plant_id",
            "type": "INTEGER"
        }, {
            "name": "space_id",
            "type": "INTEGER"
        }, {
            "name": "space_name",
            "type": "TEXT"
        }, {
            "name": "plant_name",
            "type": "TEXT"
        }, {
            "name": "plant_json",
            "type": "TEXT"
        }, {
            "name": "status",
            "type": "INTEGER",
            "def": 0
        }, {
            "name": "created_at",
            "type": "REAL"
        }, {
            "name": "updated_at",
            "type": "REAL"
        }]

    function sqlGetByDeviceAddress(address) {
        return new Promise(function (resolve, reject) {
            db.executeSql(logQuery(__query__get__by_address.arg(address))).then(
                        function (rs) {
                            console.log("sqlGet ", JSON.stringify(rs))
                            if (rs.isValid()) {
                                resolve(rs.datas[0])
                            } else {
                                resolve(null)
                            }
                        }).catch(rr => console.log("rr ", JSON.stringify(rr)))
        })
    }

    function sqlGetAllByPlantID(plantID) {
        return new Promise(function (resolve, reject) {
            db.executeSql(logQuery(__query__get__by__plant_id.arg(
                                       plantID))).then(function (rs) {
                                           console.log("sqlGet ",
                                                       JSON.stringify(rs))
                                           if (rs.isValid()) {
                                               resolve(rs.datas)
                                           } else {
                                               resolve(null)
                                           }
                                       }).catch(rr => console.log(
                                                    "rr ", JSON.stringify(rr)))
        })
    }

    function sqlDeleteAllByPlantID(plantID) {
        return new Promise(function (resolve, reject) {
            db.executeSql(logQuery(__query__delete_all__by__plant_id.arg(
                                       plantID))).then(function (rs) {
                                           console.log("sqlDeleteAllByPlantID ",
                                                       JSON.stringify(rs))
                                           resolve(rs)
                                       }).catch(rr => console.log(
                                                    "rr ", JSON.stringify(rr)))
        })
    }

    function sqlUpdateByDeviceAddress(address, data) {
        if (beforeUpdate !== undefined) {
            data = control.beforeUpdate(data)
        }
        return new Promise(function (resolve, reject) {
            let column = [], value = [], column_str = '', completer = ''
            for (let col in data) {
                column.push(col)
            }
            column_str = column.join(',')
            column.map(col => value.push(data[col]))
            completer = "SET "
            console.log("Start update 3 ) ", value.length)

            for (var i = 0; i < value.length; i++) {
                //                console.log("In val ", i)
                let v = column[i]
                for (var u = 0; u < control.column.length; u++) {
                    let uu = control.column[u]
                    //                    console.log("\tIn col ", uu['name'], uu['type'])
                    if (uu['name'] === v) {
                        const val = value[i]
                        //                        console.log(v, ' ->>> ', value[i], ' ******* ', completer)
                        if (uu['type'] === "TEXT") {
                            //                            console.log("Chic")
                            completer += " %1 = '%2'".arg(v).arg(val.toString())
                            //                            console.log("Choc")
                        } else {
                            //                            console.log("Bif")
                            completer += " %1 = %2".arg(v).arg(val.toString())
                            //                            console.log("Bof")
                        }
                        if (i !== value.length - 1)
                            completer += ','
                    }
                }
            }
            //            console.log("Start update 4", completer)
            //            completer = "SET wed = 0"
            const query = logQuery(__query__update__by__address.arg(
                                       completer).arg(address))

            //            console.log(" p ", p)
            control.db.executeSql(query).then(function (rs) {
                console.log("Inserted ", JSON.stringify(rs))
                control.updated(data)
                resolve(data)
            }).catch(function (err) {
                reject(err)
            })
        })
    }

    function sqlUpdateByRemoteID(remoteID, data) {
        return new Promise(function (resolve, reject) {
            sqlGetWhere({
                            "plant_id": remoteID
                        }).then(function (res) {
                            for (let i in res) {
                                sqlUpdate(res[i].id, data)
                            }
                            resolve({
                                        "update_count": res.length
                                    })
                        })
        })
    }

    function sqlDeleteByDeviceAddress(address) {
        return new Promise(function (resolve, reject) {
            let query = "DELETE FROM %1 WHERE device_address=quote('%2')".arg(
                    control.tableName).arg(address)
            db.executeSql(logQuery(query)).then(function (rs) {
                fetchAll()
                control.deleted(rs.insertId)
                resolve(rs)
            }).catch(console.warn)
        })
    }
}
