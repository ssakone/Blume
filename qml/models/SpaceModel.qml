import QtQuick

import "../services/"

Model {
    id: control
    debug: true
    tableName: "Space01"
    column: [{
            "name": "id",
            "type": "INTEGER",
            "key": "PRIMARY KEY"
        }, {
            "name": "libelle",
            "type": "TEXT"
        }, {
            "name": "description",
            "type": "TEXT"
        }, {
            "name": "type",
            "type": "INTEGER"
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
    onReady: {
        plantInSpace.init().catch(function (err) {
            console.log(err)
        })
    }

    property Model plantInSpace: Model {
        debug: true
        db: control.db
        tableName: "PlantInSpace0001"
        column: [{
                "name": "id",
                "type": "INTEGER",
                "key": "PRIMARY KEY"
            }, {
                "name": "space_id",
                "type": "INTEGER"
            }, {
                "name": "space_name",
                "type": "TEXT"
            }, {
                "name": "plant_json",
                "type": "TEXT"
            }, {
                "name": "plant_id",
                "type": "INTEGER"
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
    }
}
