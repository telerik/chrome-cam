define [
    'mylibs/utils/utils'
], (utils) ->
    KIBIBYTE = 1024
    MEBIBYTE = KIBIBYTE * 1024
    FILE_SYSTEM_SIZE = 5 * MEBIBYTE # todo: define this better

    createTestFile = (fileName) ->
        file =
            fileName: fileName
            thumbnailUrl: fileName
            size: 128*1024
            dateTaken: new Date()

    utils.getFileSystem(
        window.PERSISTENT
        FILE_SYSTEM_SIZE
        (fileSystem) ->
            $.publish "/filesystem/ready"
        (fileError) ->
            $.publish "/filesystem/error"
    )

    pub = 
        init: ->
            data = (createTestFile i for i in [1..20])

            @dataSource = new kendo.data.DataSource
                data: data
                pageSize: 12
