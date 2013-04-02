define ["auth/auth"], (auth) ->
    printerId = null
    pub = 
        list: (callback) ->
            auth.getToken (token) ->
                opts =
                    headers: "Authorization": "OAuth " + token
                    dataType: "json"
                $.ajax("https://www.google.com/cloudprint/search?format=json", opts).done (data) ->
                    # todo: don't always use first printer
                    callback data.printers
        select: (id) ->
            printerId = id
        print: (doc) ->
            auth.getToken (token) ->
                data = new FormData()
                data.append('printerid', printerId)
                data.append('title', "Chrome Camera")
                data.append('contentType', doc.contentType)
                data.append('content', doc.content)
                opts =
                    type: "POST"
                    headers: "Authorization": "OAuth " + token
                    contentType: false
                    processData: false
                    data: data
                $.ajax "https://www.google.com/cloudprint/submit", opts
        init: ->
            $.subscribe "/printer/list", ->
                pub.list (printers) ->
                    $.publish "/postman/deliver", [printers, "/printer/list/response"]

            $.subscribe "/printer/select", (id) ->
                pub.select id

            $.subscribe "/printer/print", (doc) ->
                pub.print doc