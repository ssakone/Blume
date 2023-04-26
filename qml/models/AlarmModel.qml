import QtQuick

import "../services/"

Model {
    id: control
    debug: true
    tableName: "Alarm0001"
    column: [{
            name: "id",
            type: "INTEGER",
            key: "PRIMARY KEY"
        },
        {
            name: "libelle",
            type: "TEXT"
        },
        {
            name: "type",
            type: "INTEGER"
        },
        {
            name: "space",
            type: "INTEGER"
        },
        {
            name: "plant_list",
            type: "TEXT"
        },
        {
            name: "status",
            type: "INTEGER",
            def: 0
        },
        {
            name: "created_at",
            type: "REAL"
        },
        {
            name: "updated_at",
            type: "REAL"
        }
    ]
}
