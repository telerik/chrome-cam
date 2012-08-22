define [
    'mylibs/utils/utils'
], (utils) ->
    
    createTestFile = (fileName) ->
        file =
            fileName: fileName
            thumbnailUrl: fileName
            size: 128*1024
            dateTaken: new Date()

    pub = 
        init: ->
            data = (createTestFile i for i in [1..20])

            @dataSource = new kendo.data.DataSource
                data: data
                pageSize: 12
