define ['utils/utils'],
(utils) ->
    ###     File

    The file module takes care of all the reading and writing to and from the file system

    ###

    # normalize file system
    window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem

    # object level vars
    fileSystem = null
    myPicturesDir = {}
    blobBuiler = {}

    # custom compare function that sorts images by their date
    compare = (a,b) ->

        if a.name < b.name
            return -1

        if a.name > b.name
            return 1

        return 0

    getFileExtension = (filename) ->
            filename.split('.').pop()

    # generic error handler. called everytime there is an exception thrown here.
    errorHandler = (e) ->

        msg = ''

        console.log e

        if e.type == "error"
            switch e.code || e.target.error.code
                when FileError.QUOTA_EXCEEDED_ERR
                    msg = 'QUOTA_EXCEEDED_ERR'
                when FileError.NOT_FOUND_ERR
                    msg = 'NOT_FOUND_ERR'
                when FileError.SECURITY_ERR
                    msg = 'SECURITY_ERR'
                when FileError.INVALID_MODIFICATION_ERR
                    msg = 'INVALID_MODIFICATION_ERR'
                when FileError.INVALID_STATE_ERR
                    msg = 'INVALID_STATE_ERR'
                else
                    msg = 'Unknown Error'

        $.publish "/notify/show", [ "File Error", msg, true ]

        $.publish "/notify/show", [ "File Access Denied", "Access to the file system could not be obtained.", false ]

    withFileSystem = (fn) ->
        if fileSystem
            fn fileSystem
        else
            # request storage. requested amount is 50 meg but storage is specified as unlimited in manifest?
            window.webkitStorageInfo.requestQuota PERSISTENT, 5000 * 1024, (grantedBytes) ->
                success = (fs) ->
                    fileSystem = fs
                    fn fs
                # get a persistant storage grant
                window.requestFileSystem PERSISTENT, grantedBytes, success, errorHandler

    # saves a file to the file system. overwrites the file if it exists.
    save = (name, blob) ->

        if typeof blob == "string"
            blob = utils.toBlob blob

        window.theBlob = blob

        onwrite = (e) ->
            $.publish "/share/gdrive/upload", [ blob ]
            $.publish "/postman/deliver", [ {}, "/file/saved/#{name}", [] ]
            $.publish "/file/saved/#{name}"

        # get the file from the file system, creating it if it doesn't exist
        withFileSystem (fs) ->
            fs.root.getFile name, create: true, (fileEntry) ->

                # create a writer
                fileEntry.createWriter (fileWriter) ->

                    # called when the write ends
                    fileWriter.onwrite = onwrite

                    # called when the write pukes
                    fileWriter.onerror = errorHandler

                    # write the blob to the file system
                    fileWriter.write blob

            # we didn't get access to the file system for some reason
            , errorHandler

    # deletes a file if it exists, throws an exception if it does not.
    destroy = (name) ->

            # get the file reference from the file system by name
            withFileSystem ->
                fileSystem.root.getFile name, create: false, (fileEntry) ->

                    # kill it
                    fileEntry.remove ->

                            # dispatch events that we killed it
                            $.publish "/postman/deliver", [ { message: "" }, "/file/deleted/#{name}", [] ]

                    # file couldn't be deleted
                    , errorHandler

                # access to the file system could not be had
                , errorHandler

    # allows user to save the file to a specific place on their hard drive
    download = (filename) ->
        withFileSystem (fs) ->
            fs.root.getDirectory "MyPictures", create: true, (dirEntry) ->

                deferred = loadFile dirEntry, filename

                deferred.done (data) ->
                    # convert the incoming data url to a blob
                    blob = utils.toBlob(data.file)

                    # invoke the chrome file chooser saying that we are going to save a file
                    chrome.fileSystem.chooseEntry { type: "saveFile", suggestedName: name }, (fileEntry) ->

                        return unless fileEntry?

                        # create the writer
                        fileEntry.createWriter (fileWriter) ->

                            # called when the file has been written successfully
                            fileWriter.onwriteend = (e) ->

                            # the file could not be written.
                            fileWriter.onerror = (e) ->

                                errorHandler e

                            # save the file to the user specified file and folder
                            fileWriter.write blob

    fileListing = ->
        withFileSystem (fs) ->
            fs.root.getDirectory "MyPictures", create: true, (dirEntry) ->

                entries = []

                dirReader = fs.root.createReader()

                dirReader.readEntries (results) ->
                    for entry in results
                        if entry.isFile
                            entries.push { name: entry.name, type: entry.name.split(".").pop() }

                    $.publish "/postman/deliver", [ { message: entries }, "/file/listing/response" ]
            , errorHandler

    loadFile = (dirEntry, filename) ->
        deferred = $.Deferred()

        dirEntry.getFile "/#{filename}", create: false, (fileEntry) ->

            name = fileEntry.name
            type = name.split(".").pop()

            fileEntry.file (file) ->
                reader = new FileReader()

                reader.onloadend = (e) ->
                    data =
                        name: name
                        type: type
                        file: this.result

                    deferred.resolve(data)

                reader.readAsDataURL file

        , errorHandler

        return deferred.promise()

    readFile = (filename) ->
        withFileSystem (fs) ->
            fs.root.getDirectory "MyPictures", create: true, (dirEntry) ->
                loadFile(dirEntry, filename).done (data) ->
                    $.publish "/postman/deliver", [ { message: data }, "/file/read/#{filename}" ]

    readBulk = (files, token) ->
        withFileSystem (fs) ->
            fs.root.getDirectory "MyPictures", create: true, (dirEntry) ->
                entries = []

                deferreds = (loadFile dirEntry, file for file in files)

                $.when.apply($, deferreds).then ->
                    entries = Array::slice.call(arguments, 0)
                    $.publish "/postman/deliver", [ { message: entries }, "/file/bulk/#{token}" ]

    clear = ->
        withFileSystem (fs) ->
            dirReader = fs.root.createReader()
            dirReader.readEntries (entries) ->

                deletedCount = 0
                totalCount = entries.length

                for entry in entries
                    do (entry) ->
                        entry.remove ->
                            ++deletedCount
                            if deletedCount == totalCount
                                $.publish "/postman/deliver", [ {}, "/file/cleared" ]

    pub =

        init: (kb) ->

            # subscribe to events
            $.subscribe "/file/save", (message) ->
                save message.name, message.file

            $.subscribe "/file/delete", (message) ->
                destroy message.name

            $.subscribe "/file/download", (message) ->
                download message.name

            $.subscribe "/file/clear", (message) ->
                clear()

            $.subscribe "/file/listing", (message) ->
                fileListing()

            $.subscribe "/file/read", (message) ->
                readFile message.file

            $.subscribe "/file/bulk", (message) ->
                readBulk message.files, message.token
