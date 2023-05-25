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
        tableName: "PlantInSpace01"
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

    function listSpacesOfPlantRemoteID(remote_id) {
        return new Promise(function (resolve, reject) {
            $Model.plant.sqlGetWhere({remote_id: remote_id}).then(function (res) {
                console.log("\n\n LEVEL 01 (plants) --", res[0].id, res.length)
                if(res.length > 0) {
                    const firstPlantID = res[0].id
                    console.log("\n firstID ", firstPlantID)
                    $Model.space.plantInSpace.sqlGetWhere({space_id: firstPlantID}).then(function (resPS) {
                        console.log("\n\n LEVEL 02 (plantInSpace) ---", JSON.stringify(resPS))
                        if(resPS.length > 0) {
                            const firstSpaceID = resPS[0].id
                            $Model.space.sqlGetWhere({id: firstSpaceID}).then(function (resS) {
                                console.log("\n\n LEVEL 03 (space) ----", JSON.stringify(resS))
                                resolve(resS)
                            })
                        } else {
                            resolve([])
                        }
                    })
                } else {
                    resolve([])
                }
            })

        })

    }
}
