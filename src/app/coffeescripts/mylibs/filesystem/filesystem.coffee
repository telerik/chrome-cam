define [
    'mylibs/utils/utils'
], (utils) ->
    dataSource = new kendo.data.DataSource
        data: []
        pageSize: 8
    pub = 
        dataSource: dataSource
