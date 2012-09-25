define([

  'mylibs/utils/utils'

], (utils) ->

  ###   File

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
    console.log blob

    onwrite = (e) ->
      $.publish "/share/gdrive/upload", [ blob ]
      $.publish "/postman/deliver", [ {}, "/file/saved/#{name}", [] ]

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

          fileWriter.abort()
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
              $.publish "/notify/show", [ "File Deleted!", "The picture was deleted successfully", false ]
              $.publish "/postman/deliver", [ { message: "" }, "/file/deleted/#{name}", [] ]

          # file couldn't be deleted
          , errorHandler

        # access to the file system could not be had
        , errorHandler

  # allows user to save the file to a specific place on their hard drive
  download = (name, dataURL) ->

    # convert the incoming data url to a blob
    blob = utils.toBlob(dataURL)

    # invoke the chrome file chooser saying that we are going to save a file
    chrome.fileSystem.chooseEntry { type: "saveFile", suggestedName: name }, (fileEntry) ->

      # create the writer
      fileEntry.createWriter (fileWriter) ->

        # called when the file has been written successfully
        fileWriter.onwriteend = (e) ->

          $.publish "/notify/show", [ "File Saved", "The picture was saved succesfully", false ]

        # the file could not be written.
        fileWriter.onerror = (e) ->

          errorHandler e

        # save the file to the user specified file and folder
        fileWriter.write blob

  list = ->
    withFileSystem (fs) ->
      dirReader = fs.root.createReader()
      dirReader.readEntries (results) ->
        files = (name: entry.name, type: getFileExtension(entry.name) for entry in results when entry.isFile)
        files.sort(compare)

        $.publish "/postman/deliver", [ { message: files }, "/file/listResult", [] ]

  readSingleFile = (filename) ->
    withFileSystem ->
      fileSystem.root.getFile filename, null, (fileEntry) ->
        fileEntry.file (file) ->
          reader = new FileReader()

          reader.onloadend = (e) ->
            result =
              name: filename
              type: getFileExtension filename
              file: this.result

            # send it down to the app
            $.publish "/postman/deliver", [ { message: result }, "/pictures/#{filename}", [] ]

          reader.readAsDataURL file


  # reads all images from the "MyPictures" folder in the file system
  read = ->

    # we were granted storage
    withFileSystem (fs) ->

      # get the pictures directory. create it if it doesn't yet exist.
      fs.root.getDirectory "MyPictures", create: true, (dirEntry) ->

        # cache the directory entry returned
        myPicturesDir = dirEntry

        # create an array for file entries
        entries = []

        # create an array for actual files
        files = []
        
        # create a reader for reading files
        dirReader = fs.root.createReader()

        # read from the file system
        read = ->

          # loop through the reader
          dirReader.readEntries (results) ->

            # get a count of how many files we are expecting by adding them to an array
            # if they are of type 'file'
            for entry in results  
              if entry.isFile
                entries.push(entry)

            # read the current file
            readFile = (i) ->

              # add the current file entry to the array
              entry = entries[i]

              # only process this file if it is in fact a file, and not a directory
              if entry and entry.isFile

                # store the name and type
                name = entry.name
                type = name.split(".").pop()

                # get a reference to the file so we can ready from it
                entry.file (file) ->

                    # create a file reader
                    reader = new FileReader()

                    # when the reader loads, we are going to read all the files in one pop
                    reader.onloadend = (e) ->

                      # we are going to add this to an array of files to be sent over.  They need to display in the same order everytime
                      # in order to do that we need to collect them here by checking the length of the array we are building against the length
                      # of the array that is holding the file entries.  Once they are the same, we know we have them all and we can sort by name
                      # which is the timestamp, and send them down to the app.
                      files.push({ name: name, file: this.result, type: type, strip: false })

                      if files.length == entries.length
                          
                        # sort the files array by name
                        files.sort(compare)

                        # send it down to the app
                        $.publish "/postman/deliver", [ { message: files }, "/pictures/bulk", [] ]

                      else
                        readFile(++i)

                    # read files as data urls
                    reader.readAsDataURL(file)

            # if our entries array has files in it, start reading them.
            if entries.length > 0
              readFile(0)
            else
              $.publish "/postman/deliver", [ { message: [] }, "/pictures/bulk", [] ]

        read()

      # we did not get file system access
      , errorHandler

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

      $.subscribe "/file/read", (message) ->
        read()

      $.subscribe "/file/download", (message) ->
        download message.name, message.file

      $.subscribe "/file/list", (message) ->
        list()
      
      $.subscribe "/file/readFile", (message) ->
        readSingleFile message.name

      $.subscribe "/file/clear", (message) ->
        clear()

)