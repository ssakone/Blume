import QtQuick

import "../services/"
import "../components_js/Utils.js" as Utils
Model {
    id: control
    debug: true
    tableName: "Alarm01"
    column: [{
            "name": "id",
            "type": "INTEGER",
            "key": "PRIMARY KEY"
        }, {
            "name": "libelle",
            "type": "TEXT"
        }, {
            "name": "type",
            "type": "INTEGER"
        }, {
            "name": "done",
            "type": "BOOLEAN",
            "def": "false"
        },{
            "name": "hours",
            "type": "INTEGER"
        }, {
            "name": "minute",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "mon",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "tue",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "wed",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "thu",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "fri",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "sat",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "sun",
            "type": "INTEGER",
            "def": "0"
        }, {
            "name": "frequence", // Nombre de jours
            "type": "INTEGER",
            "def": "1"
        }, {
            // toISOString() format
            "name": "last_done",
            "type": "TEXT"
        }, {
            "name": "space",
            "type": "INTEGER"
        },{
            "name": "plant",
            "type": "INTEGER"
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

    function sqlUpdateTaskStatus(id, newStatus, preventDateUpdate = false) {
        console.log("Start update status as = ", newStatus)
        if (beforeUpdate !== undefined) {
            data = control.beforeUpdate(data)
        }
        return new Promise(function (resolve, reject) {
            const today = Utils.humanizeToISOString(new Date())
            let completer = "SET done = %1".arg(newStatus)
            if(preventDateUpdate===false) {
                completer += ", last_done=quote('%2')".arg(today)
            }

            const query = logQuery(__query__update__.arg(
                                                           completer).arg(
                                                           id))

            control.db.executeSql(query).then(function (rs) {
                console.log("Inserted ", JSON.stringify(rs))
                                                   control.updated(data)
                                                   resolve(data)
                                               }).catch(function (err) {
                                                   reject(err)
                                               })
        })
    }

    function sqlFormatFrequence(id) {
        return new Promise(function (resolve, reject){
            sqlGet(id).then(function (res) {
                // console.log("Formating ", res.frequence, JSON.stringify(res))
                let freq = res.frequence
                let period = "NULL"
                let periodIndex = 3

                // Is it yearly
                if(freq > 365 ) {
                    period = qsTr("Years")
                    periodIndex = 3
                    freq = Math.floor(freq/365)
                } else  {
                    // is it monthly
                    if(freq > 30 ) {
                        period = qsTr("Months")
                        periodIndex = 2
                        freq = Math.floor(freq/30)
                    } else {
                        // is it weekly
                        if(freq > 7 ) {
                            period = qsTr("Weeks")
                            periodIndex = 1
                            freq = Math.floor(freq/7)
                        } else {
                            // else, it is certainly a number of days between [0-7]
                            if(freq > 0) {
                                period = qsTr("Days")
                                periodIndex = 0
                            } else period = qsTr("Never")
                        }
                    }
                }

                const data = {
                    freq: freq,
                    period_label: period,
                    period_index: periodIndex
                }
                console.log(data)
                resolve(data)
            }).catch(err => reject(err))
        })
    }
}
