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
    signal deleted(var id)

    property variant beforeCreate
    property variant beforeCreates
    property variant beforeDelete
    property variant beforeUpdate

    property string __query__fetch__: 'SELECT * FROM %1 WHERE status = 0'.arg(
                                          tableName)
    property string __query__get__: 'SELECT * FROM %1 WHERE id=%2'.arg(
                                        tableName)
    property string __query__get__all__: 'SELECT * FROM %1'.arg(
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
        return new Promise(function (resolve, reject) {
            if (control.beforeCreate !== undefined) {
                data = control.beforeCreate(data);
            }

            let columns = [], values = [], placeholders = [];
            for (let column in data) {
                if (!data.hasOwnProperty(column)) continue;
                columns.push(column);
                values.push(data[column]);
                placeholders.push("?");
            }

            columns.push("created_at")

            var i, j;

            for (i = 0; i < values.length; i++) {
                let value = values[i];
                for (j = 0; j < control.column.length; j++) {
                    let columnDef = control.column[j];
                    if (columnDef['name'] === columns[i]) {
                        if (columnDef['type'] === "TEXT") {
                            value = value.toString().replace(/'+/g, "");
                            placeholders[i] = columns[i].includes('json') ? `'${value}'` : `quote('${value}')`;
                        } else {
                            placeholders[i] = value.toString();
                        }
                    }
                }
            }

            placeholders.push((new Date()).getTime())

            let query = `INSERT INTO ${control.tableName} (${columns.join(', ')}) VALUES (`;

            for (let i = 0; i < placeholders.length; i++) {
                if (i > 0) query += ', ';
                query += placeholders[i];
            }
            query += ')';

            control.db.executeSql(query).then(function (rs) {
                data['id'] = parseInt(rs.insertId);
                control.append(data);
                control.created(data);
                resolve(data);
            }).catch(function (err) {
                console.log("CREATE ERR", JSON.stringify(err));
                reject(err);
            });
        });
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
                console.log("sqlGet ", JSON.stringify(rs))
                if (rs.isValid()) {
                    resolve(rs.datas[0])
                } else {
                    console.log("sqlGet 02 ", JSON.stringify(rs))
                    resolve({})
                }
            }).catch(rr => console.log("rr ", JSON.stringify(rr)))
        })
    }

    function sqlGetAll() {
        return new Promise(function (resolve, reject) {
            db.executeSql(logQuery(__query__get__all__)).then(function (rs) {
                console.log("sqlGetAll valid ", JSON.stringify(rs) )
                resolve(rs?.datas || [])

            }).catch(rr => console.log("rr ", JSON.stringify(rr)))
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
            values = column.join(' and ')
            let query = logQuery(__query__get__where__.arg(values))
            db.executeSql(query).then(function (rs) {
                    resolve(rs?.datas || [])
            }).catch(rr => console.log("rr ", JSON.stringify(rr)))
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
