import QtQuick

import "../services/"

Model {
    id: control
    debug: true
    tableName: "Space0001"
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
