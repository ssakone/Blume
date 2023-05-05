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

function request(method, url, params, api = "") {
    let query = {
        "method": method,
        "url": url,
        "headers": {
            "Accept": 'application/json',
            "Api-Key": api === "" ? "aryQrOSbo6YrsMQGRx5VRpc1dOazmjDxO23jeitWxX43V7b3Xq" : api,
            "Content-Type": 'application/json'
        },
        "params": params ?? null
    }
    return fetch(query)
}

function send_mail({to, recv_name, subject = "Blume: contacter un expert", content_html = "", content_txt ="Aide", attachements = [] }) {

    let auth = Qt.btoa("af7ef02f89cd85f6aa5fa5db1dd313e1:b4085a8615eff4b65de0f1ac8c58910c")
    let query = {
        "method": "POST",
        "url": "https://api.mailjet.com/v3.1/send",
        "headers": {
            "Accept": 'application/json',
            "Authorization": `Basic ${auth}`,
            "Content-Type": 'application/json'
        },
        "params": {
            "Messages": [
                {
                    "From": {
                        "Email": "marcleord.zomadi@mahoudev.com",
                        "Name": "Blume support"
                    },
                    "To": [
                        {
                            "Email": to,
                            "Name": recv_name
                        }
                    ],
                    "Subject": subject,
                    "TextPart": content_txt,
                    "HTMLPart": content_html,
                    "Attachments": attachements
                }
            ]
        }
    }
    return fetch(query)
}
