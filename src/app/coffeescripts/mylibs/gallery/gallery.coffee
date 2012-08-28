define [
    'mylibs/utils/utils',
    'text!mylibs/gallery/views/gallery.html'
], (utils, templateSource) ->
    template = kendo.template(templateSource)

    loadImages = ->
        deferred = $.Deferred()

        token = $.subscribe "/pictures/bulk", (result) ->
            if result.message instanceof Array and result.message.length > 0
                $.publish "/bar/preview/update", [thumbnailURL: result.message[-1..][0].image]

            $.unsubscribe token
            dataSource = new kendo.data.DataSource
                data: result.message
                pageSize: 12
                change: ->
                    $.publish "/gallery/page", [ dataSource ]
            dataSource.read()

            deferred.resolve dataSource

        $.publish "/postman/deliver", [ {}, "/file/read", [] ]

        deferred.promise()

    createPage = (dataSource, $container) -> 
        # handle paging now!
        rowLength = 4
        rows = [
            dataSource.view()[0 * rowLength ... 1 * rowLength]
            dataSource.view()[1 * rowLength ... 2 * rowLength]
            dataSource.view()[2 * rowLength ... 3 * rowLength]
        ]

        $container.html template(rows: rows)

    setupSubscriptionEvents = ($container) ->
        $.subscribe "/gallery/show", (fileName) ->
            console.log fileName

        $.subscribe "/gallery/hide", ->
            $container.hide()
            $("#wrap").show -> $.publish "/previews/pause", [false]

        $.subscribe "/gallery/list", ->
            $.publish "/previews/pause", [true]
            $container.show()
            $("#wrap").hide()

        $.subscribe "/gallery/page", (dataSource) ->
            createPage dataSource, $container

    pub =
        init: (selector) ->
            $container = $(selector)

            # after loading the images
            loadImages().done (dataSource) ->
                # set up the DOM events
                $container.on "click", ".thumbnail", ->
                    $.publish "/gallery/show", [$(this).data("file-name")]

                # TODO: add transition effect...
                $container.kendoMobileSwipe (e) -> 
                    if e.direction == "right" && dataSource.page() > 1
                        dataSource.page dataSource.page() - 1
                    
                    if e.direction == "left" && dataSource.page() < dataSource.totalPages()
                        dataSource.page dataSource.page() + 1

                setupSubscriptionEvents $container
                
                # TODO: trigger refresh of items in list
                $.subscribe "/gallery/add", (file) ->
                    dataSource.add file

                $.publish "/gallery/page", [ dataSource ]