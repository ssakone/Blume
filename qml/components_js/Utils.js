let Flatted = (function (exports) {
    'use strict'

    function _typeof(obj) {
        "@babel/helpers - typeof"

        return _typeof = "function" == typeof Symbol
                && "symbol" == typeof Symbol.iterator ? function (obj) {
                    return typeof obj
                } : function (obj) {
                    return obj && "function" == typeof Symbol
                            && obj.constructor === Symbol
                            && obj !== Symbol.prototype ? "symbol" : typeof obj
                }
        _typeof(obj)
    }

    /*! (c) 2020 Andrea Giammarchi */
    var $parse = JSON.parse, $stringify = JSON.stringify
    var keys = Object.keys
    var Primitive = String

    // it could be Number
    var primitive = 'string'

    // it could be 'number'
    var ignore = {}
    var object = 'object'

    var noop = function noop(_, value) {
        return value
    }

    var primitives = function primitives(value) {
        return value instanceof Primitive ? Primitive(value) : value
    }

    var Primitives = function Primitives(_, value) {
        return _typeof(value) === primitive ? new Primitive(value) : value
    }

    var revive = function revive(input, parsed, output, $) {
        var lazy = []

        for (var ke = keys(
                 output), length = ke.length, y = 0; y < length; y++) {
            var k = ke[y]
            var value = output[k]

            if (value instanceof Primitive) {
                var tmp = input[value]

                if (_typeof(tmp) === object && !parsed.has(tmp)) {
                    parsed.add(tmp)
                    output[k] = ignore
                    lazy.push({
                                  "k": k,
                                  "a": [input, parsed, tmp, $]
                              })
                } else
                    output[k] = $.call(output, k, tmp)
            } else if (output[k] !== ignore)
                output[k] = $.call(output, k, value)
        }

        for (var _length = lazy.length, i = 0; i < _length; i++) {
            var _lazy$i = lazy[i], _k = _lazy$i.k, a = _lazy$i.a
            output[_k] = $.call(output, _k, revive.apply(null, a))
        }

        return output
    }

    var set = function set(known, input, value) {
        var index = Primitive(input.push(value) - 1)
        known.set(value, index)
        return index
    }

    var parse = function parse(text, reviver) {
        var input = $parse(text, Primitives).map(primitives)
        var value = input[0]
        var $ = reviver || noop
        var tmp = _typeof(value) === object && value ? revive(input, new Set(),
                                                              value, $) : value
        return $.call({
                          "": tmp
                      }, '', tmp)
    }
    var stringify = function stringify(value, replacer, space) {
        var $ = replacer && _typeof(replacer) === object ? function (k, v) {
            return k === '' || -1 < replacer.indexOf(k) ? v : void 0
        } : replacer || noop
        var known = new Map()
        var input = []
        var output = []
        var i = +set(known, input, $.call({
                                              "": value
                                          }, '', value))
        var firstRun = !i

        while (i < input.length) {
            firstRun = true
            output[i] = $stringify(input[i++], replace, space)
        }

        return '[' + output.join(',') + ']'

        function replace(key, value) {
            if (firstRun) {
                firstRun = !firstRun
                return value
            }

            var after = $.call(this, key, value)

            switch (_typeof(after)) {
            case object:
                if (after === null)
                    return after
            case primitive:
                return known.get(after) || set(known, input, after)
            }

            return after
        }
    }
    var toJSON = function toJSON(any) {
        return $parse(stringify(any))
    }
    var fromJSON = function fromJSON(any) {
        return parse($stringify(any))
    }

    exports.fromJSON = fromJSON
    exports.parse = parse
    exports.stringify = stringify
    exports.toJSON = toJSON

    return exports
})({})

function humanizeToISOString(date) {
    const d = date.getDate()
    const m = date.getMonth() + 1
    const y = date.getFullYear()
    const formated = `${y}/${m>9 ? m : '0'+m }/${d > 9 ? d : '0'+d}`
//    console.log(formated , " -->> ", new Date(formated))
    return formated
}

function humanizeDayPeriod(freq) {
    let period = "NULL"
    let periodIndex = 3

    // Is it yearly
    if(freq > 365 ) {
        period = qsTr("Year")
        periodIndex = 3
        freq = Math.floor(freq/365)
    } else  {
        // is it monthly
        if(freq > 30 ) {
            period = qsTr("Month")
            periodIndex = 2
            freq = Math.floor(freq/30)
        } else {
            // is it weekly
            if(freq > 7 ) {
                period = qsTr("Week")
                periodIndex = 1
                freq = Math.floor(freq/7)
            } else {
                // else, it is certainly a number of days between [0-7]
                if(freq > 0) {
                    period = qsTr("Day")
                    periodIndex = 0
                } else period = qsTr("Never")
            }
        }
    }

    if(freq > 1) {
        period += "s"
    }

    const data = {
        freq: freq,
        period_label: period,
        period_index: periodIndex
    }
    return data
}

function getNextDate(from, daysAfter) {
    // returns the day after 'daysAfter' from date 'from'

    const tms1 = from.getTime()
    const tms2 = (daysAfter) * 24 * 60 * 60 * 1000
    const tms = tms1 + tms2
    const nextDate = new Date(tms)
    return nextDate
}

function getDateBefore(from, daysBefore) {
    // returns the day before 'daysAfter' from date 'from'

    const tms1 = from.getTime()
    const tms2 = (daysBefore) * 24 * 60 * 60 * 1000

    const tms = tms1 - tms2
    const dateBefore = new Date(tms)
    return dateBefore
}
