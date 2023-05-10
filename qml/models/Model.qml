import QtQuick

import "../services/"

ListModel {
    id: control
    property SqlClient db
    property bool debug: false
    property string tableName
    property variant column: []

    signal fetched
    signal ready
    signal removed(var id)
    signal removeds(var ids)
    signal created(var id)
    signal createds(var id)
    signal updated(var id)

    property variant beforeCreate
    property variant beforeCreates
    property variant beforeDelete
    property variant beforeUpdate

    property string __query__fetch__: 'SELECT * FROM %1 WHERE status = 0'.arg(
                                          tableName)
    property string __query__get__: 'SELECT * FROM %1 WHERE id=%2'.arg(
                                        tableName)
    property string __query__get__where__: 'SELECT * FROM %1 WHERE %2'.arg(
                                               tableName)
    property string __query__create__: 'INSERT INTO %1(%2) VALUES(%3)'
    property string __query__creates__: 'INSERT INTO %1(%2) VALUES%3'
    property string __query__update__: 'UPDATE %1 %2 WHERE id = %3'.arg(
                                           tableName)

    property string __order__by__: 'ORDER BY %1 DESC'
    property string __order__by__field: 'id'

    function sqlCreate(data) {
        if (beforeCreate !== undefined) {
            data = control.beforeCreate(data)
        }
        return new Promise(function (resolve, reject) {
            let column = [], value = [], column_str = '', completer = ''
            for (let col in data) {
                column.push(col)
            }
            column_str = column.join(',')
            column.map(col => value.push(data[col]))
            completer = "?,".repeat(column.length).slice(0, -1)
            for (var i = 0; i < value.length; i++) {
                let v = column[i]
                for (var u = 0; u < control.column.length; u++) {
                    let uu = control.column[u]
                    if (uu['name'] === v) {
                        if (uu['type'] === "TEXT") {
                            let argument = value[i].toString()

                            argument = argument.replace(/'+/g, "")
                            if(!v.includes('json')) {
                                completer = completer.replace(
                                            '?', "quote('%1')".arg(argument))
                            } else {
                                console.log("Found a JSON field ", v)
                                completer = completer.replace(
                                            '?', "'%1'".arg(argument))
                            }

                        } else {
                            completer = completer.replace(
                                        '?', "%1".arg(value[i].toString()))
                        }
                    }
                }
            }
            control.db.executeSql(logQuery(__query__create__.arg(
                                               control.tableName).arg(
                                               column_str).arg(
                                               completer))).then(function (rs) {
//                                                   console.log('CREATEd', rs)
                                                   data['id'] = parseInt(
                                                               rs.insertId)
                                                   control.append(data)
                                                   control.created(data)
                                                   resolve(data)
                                               }).catch(function (err) {
                                                   console.log("CREATE ERR", JSON.stringify(err))
                                                   reject(err)
                                               })
        })
    }

    function sqlCreates(datas) {
        if (beforeCreates !== undefined) {
            datas = beforeCreates(datas)
        }
        return new Promise(function (resolve, reject) {
            let column = [], value = [], column_str = '', completer = ''
            for (let col in datas[0]) {
                column.push(col)
            }
            column_str = column.join(',')
            completer = "?,".repeat(column.length).slice(0, -1)
            completer = '(%1)'.arg(completer)

            let finalString = ''
            for (var b = 0; b < datas.length; b++) {
                finalString = finalString + '%1,'.arg(completer)
                let data = datas[b]
                let vv = []
                for (var vi = 0; vi < column.length; vi++) {
                    //value.push(data[column[vi]])
                    vv.push(data[column[vi]].toString())
                }

                for (var i = 0; i < vv.length; i++) {
                    let v = column[i]
                    for (var u = 0; u < control.column.length; u++) {
                        let uu = control.column[u]
                        if (uu['name'] === v) {
                            if (uu['type'] === "TEXT") {
                                finalString = finalString.replace(
                                            '?', "'%1'".arg(vv[i]))
                            } else {
                                finalString = finalString.replace(
                                            '?', "%1".arg(vv[i]))
                            }
                        }
                    }
                }
            }
            finalString = finalString.slice(0, -1)
            var rs = control.db.executeSql(
                        logQuery(__query__creates__.arg(control.tableName).arg(
                                     column_str).arg(finalString)), value)
            resolve(rs)
        })
    }

    function sqlUpdate(id, data) {
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
                        if(i !== value.length-1) completer += ','
                    }
                }
            }
//            console.log("Start update 4", completer)
//            completer = "SET wed = 0"
            const query = logQuery(__query__update__.arg(
                                                           completer).arg(
                                                           id))

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

    function sqlDelete(id) {
        return new Promise(function (resolve, reject) {
            let query = 'DELETE FROM %1 WHERE id=%2'.arg(
                    control.tableName).arg(id)
            db.executeSql(logQuery(query)).then(function (rs) {
                fetchAll()
                resolve(rs)
            }).catch(console.warn)
        })
    }

    function sqlDeleteAll(idList) {
        return new Promise(function (resolve, reject) {
            let query
            query = 'DELETE FROM %1 WHERE id IN (%2)'.arg(
                        control.tableName).arg(idList.join())
            control.db.executeSql(logQuery(query)).then(function (rs) {
                removeds(idList)
                resolve(rs)
            })
        })
    }

    function sqlQuery(query) {
        return new Promise(function (resolve, reject) {
            control.db.executeSql(logQuery(query)).then(function (rs) {
                resolve(rs)
            })
        })
    }

    function sqlGet(id) {
        return new Promise(function (resolve, reject) {
            db.executeSql(logQuery(__query__get__.arg(id))).then(function (rs) {
                if (rs.isValid()) {
                    resolve(rs.datas[0])
                } else {
                    resolve({})
                }
            })
        })
    }

    function sqlGetWhere(data) {
        console.log("Batsta")
        return new Promise(function (resolve, reject) {
            console.log("\n Gonna sqlGetWhere")
            let values = "", column = []
            for (var i in data) {
                if (typeof (data[i]) === "string") {
                    column.push("%1 = '%2'".arg(i).arg(data[i]))
                } else {
                    column.push("%1 = %2".arg(i).arg(data[i]))
                }
            }
            console.log(column)
            values = column.join(' and ')
            console.log(values)
            let query = logQuery(__query__get__where__.arg(values))
            var rs = db.executeSql(query)
            resolve(rs.rows)
        })
    }

    function init() {
        return new Promise(function (resolve, reject) {
            let query = "", columns = [], cols = []
            control.column.forEach(function (info) {
                cols = []
                cols.push("%1 %2".arg(info.name).arg(
                              info.type === "BOOLEAN" ? "INTEGER" : info.type))
                if ("key" in info) {
                    cols.push(info.key)
                }
                if ("def" in info) {
                    if (info.type !== "INTEGER" && info.type !== "REAL") {
                        cols.push("DEFAULT '%1'".arg(info.def))
                    } else if (info.type === "BOOLEAN") {
                        cols.push("DEFAULT %1".arg(info.def))
                    } else {
                        cols.push("DEFAULT %1".arg(info.def))
                    }
                }
                columns.push(cols.join(' '))
            })

            query = "CREATE TABLE IF NOT EXISTS %1(%2)".arg(
                        control.tableName).arg(columns.join(', '))
            let res = control.db.executeSql(logQuery(query))
            ready()
            resolve(res)
        })
    }

    function logQuery(query) {
        if (debug)
            console.log("[SQL_COMMAND] %1".arg(query))
        return query
    }

    function fetchAll() {
        db.executeSql(logQuery(__query__fetch__)).then(function (rs) {
            if (rs.isValid()) {
                clear()
                rs.datas.forEach(function (el) {
                    append(el)
                })
            }
        })
    }

    onReady: fetchAll()
}
