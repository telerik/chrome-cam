define ["auth/auth"], (auth) ->
    printerId = null
    internal =
        print: (token, image) ->
            opts =
                type: "POST"
                headers: "Authorization": "OAuth " + token
                data:
                    content: image
                    printerid: printerId
                    contentType: "text/plain"
            $.ajax "https://www.google.com/cloudprint/submit", opts
    pub = 
        print: (image) ->
            auth.getToken (token) ->
                if printerId is null
                    opts =
                        headers: "Authorization": "OAuth " + token
                        dataType: "json"
                    $.ajax("https://www.google.com/cloudprint/search?format=json", opts).done (data) ->
                        # todo: don't always use first printer
                        printerId = data.printers[0].id
                        internal.print token, image
                else
                    internal.print token, image