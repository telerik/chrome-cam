define ["auth/auth"], (auth) ->
    printerId = null
    internal =
        print: (token, content, contentType) ->
            data = new FormData()
            data.append('printerid', printerId)
            data.append('title', "Chrome Camera")
            data.append('contentType', 'dataUrl')
            data.append('content', content)
            opts =
                type: "POST"
                headers: "Authorization": "OAuth " + token
                contentType: false
                processData: false
                data: data
            $.ajax "https://www.google.com/cloudprint/submit", opts
    pub = 
        print: (content, contentType) ->
            auth.getToken (token) ->
                if printerId is null
                    opts =
                        headers: "Authorization": "OAuth " + token
                        dataType: "json"
                    $.ajax("https://www.google.com/cloudprint/search?format=json", opts).done (data) ->
                        # todo: don't always use first printer
                        printerId = data.printers[0].id
                        internal.print token, content, contentType
                else
                    internal.print token, content, contentType