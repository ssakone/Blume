import QtQuick

import "../services/"

Model {
    debug: true
    tableName: "Plant00002"
    column: [{
            "name": "id",
            "type": "INTEGER",
            "key": "PRIMARY KEY"
        }, {
            "name": "libelle",
            "type": "TEXT"
        }, {
            "name": "image_url",
            "type": "TEXT"
        }, {
            "name": "uuid",
            "type": "TEXT"
        }, {
            "name": "plant_json",
            "type": "TEXT"
        }, {
            "name": "remote_id",
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
