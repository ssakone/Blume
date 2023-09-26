import QtQuick 2.15

QtObject {
    property string apihost: "http://10.0.2.2:8001/"
    //property string apihost: "http://localhost:5000/"
    //property string apihost: "http://10.0.2.2:5000/"
    //property string apihost: "http://192.168.1.97:5000/"
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
                "Content-Type": 'application/json'
            },
            "params": params ?? null
        }
        return fetch(query)
    }

    function auth(username, password) {
        return fetch({
                         "method": "POST",
                         "url": apihost + "create_account",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {
                             "username": username,
                             "password": password
                         }
                     })
    }

    function updateProfile(privateKey, data) {
        return fetch({
                         "method": "POST",
                         "url": apihost + "update_profile",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {
                             "privateKey": privateKey,
                             "profile": data
                         }
                     })
    }

    function addContact(privateKey, contacts, friendpubKey) {
        console.log("adding friend", friendpubKey, "to", privateKey)
        return fetch({
                         "method": "POST",
                         "url": apihost + "add_contact",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {
                             "privateKey": privateKey,
                             "contacts": contacts,
                             "new": friendpubKey
                         }
                     })
    }

    function getContacts() {
        return fetch({
                         "method": "GET",
                         "url": apihost + "get_contacts",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": null
                     })
    }

    function sendMessage(privateKey, pubkey, message) {
        return fetch({
                         "method": "POST",
                         "url": apihost + "send_message",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {
                             "privateKey": privateKey,
                             "message": message,
                             "to": pubkey
                         }
                     })
    }

    function sendPost(privateKey, post) {
        return fetch({
                         "method": "POST",
                         "url": apihost + "send_post",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {
                             "privateKey": privateKey,
                             "post": post
                         }
                     })
    }

    function replyPost(privateKey, post, reply) {
        return fetch({
                         "method": "POST",
                         "url": apihost + "reply_post",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {
                             "privateKey": privateKey,
                             "parent": post,
                             "content": reply
                         }
                     })
    }

    function uploadImage(ext, data) {
        return fetch({
                         "method": "POST",
                         "url": apihost + "upload_file_base64",
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {
                             "data": data,
                             "ext": ext
                         }
                     })
    }

    function searchProfile(key) {
        return fetch({
                         "method": "GET",
                         "url": apihost + "search_profile?q=" + key,
                         "headers": {
                             "Accept": 'application/json',
                             "Content-Type": 'application/json'
                         },
                         "params": {}
                     })
    }
}
