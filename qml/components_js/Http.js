function fetch(opts) {
    return new Promise(function (resolve, reject) {
        var xhr = new XMLHttpRequest()
        xhr.onload = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status == 200 || xhr.status == 201) {
                    var res = xhr.responseText.toString()
                    resolve(res)
                } else {
                    let r = {
                        "status": xhr.status,
                        "statusText": xhr.statusText,
                        "content": xhr.responseText
                    }
                    reject(r)
                }
            } else {
                let r = {
                    "status": xhr.status,
                    "statusText": xhr.statusText,
                    "content": xhr.responseText
                }
                reject(r)
            }
        }
        xhr.onerror = function () {
            let r = {
                "status": xhr.status,
                "statusText": 'NO CONNECTION, ' + xhr.statusText + xhr.responseText
            }
            reject(r)
        }

        xhr.open(opts.method ? opts.method : 'GET', opts.url, true)

        if (opts.headers) {
            Object.keys(opts.headers).forEach(function (key) {
                xhr.setRequestHeader(key, opts.headers[key])
            })
        }

        let obj = opts.params

        var data = obj ? JSON.stringify(obj) : ''

        xhr.send(data)
    })
}

function request(method, url, params) {
    let query = {
        "method": method,
        "url": url,
        "headers": {
            "Accept": 'application/json',
            "Api-Key": "aryQrOSbo6YrsMQGRx5VRpc1dOazmjDxO23jeitWxX43V7b3Xq",
            "Content-Type": 'application/json'
        },
        "params": params ?? null
    }
    return fetch(query)
}