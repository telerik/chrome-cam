define [
    'mylibs/utils/utils'
], (utils) ->
    
    createTestFile = (fileName) ->
        file =
            fileName: fileName
            thumbnailUrl: fileName
            size: 128*1024
            dateTaken: new Date()

    dataSource = new kendo.data.DataSource
        data: [createTestFile for x in 0..20]
        pageSize: 8
    pub = 
        dataSource: dataSource
