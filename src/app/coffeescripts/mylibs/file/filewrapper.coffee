define [], (file) ->

    asyncFileRequest = (requestMessage, responseMessage, data) ->
        deferred = $.Deferred()

        token = $.subscribe responseMessage, (result) ->
            $.unsubscribe token
            deferred.resolve (result || {}).message

        $.publish "/postman/deliver", [ data, requestMessage, [] ]

        deferred.promise()

    pub = window.filewrapper =
        deleteFile: (filename) ->
            asyncFileRequest "/file/delete", "/file/deleted/#{filename}", name: filename

        clear: ->
            asyncFileRequest "/file/clear", "/file/cleared", {}

        save: (filename, blob) ->
            asyncFileRequest "/file/save", "/file/saved/#{filename}", name: filename, file: blob

        fileListing: ->
            asyncFileRequest "/file/listing", "/file/listing/response", {}

        readFile: (file) ->
            asyncFileRequest "/file/read", "/file/read/#{file.name}", file: file.name

        readBulk: (files) ->
            token = new Date().getTime()
            asyncFileRequest "/file/bulk", "/file/bulk/#{token}", files: files, token: token