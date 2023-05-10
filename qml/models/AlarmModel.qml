import QtQuick

import "../services/"

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
            "name": "space",
            "type": "INTEGER"
        }, {
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

    function sqlUpdateTaskStatus(id, newStatus) {
        console.log("Start update status as = ", newStatus)
        if (beforeUpdate !== undefined) {
            data = control.beforeUpdate(data)
        }
        return new Promise(function (resolve, reject) {
            let completer = "SET done = %1".arg(newStatus)

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

}
