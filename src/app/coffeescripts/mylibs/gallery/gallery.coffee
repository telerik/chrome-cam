define [
    'mylibs/utils/utils',
    'text!mylibs/gallery/views/gallery.html',
    'text!mylibs/gallery/views/details.html'
], (utils, templateSource, detailsTemplateSource) ->
    template = kendo.template(templateSource)
    detailsTemplate = kendo.template(detailsTemplateSource)

    rowLength = 4
    numberOfRows = 4

    loadImages = ->
        deferred = $.Deferred()

        token = $.subscribe "/pictures/bulk", (result) ->
            if result.message && result.message.length > 0
                $.publish "/bar/preview/update", [thumbnailURL: result.message[result.message.length - 1].file]

            $.unsubscribe token
            dataSource = new kendo.data.DataSource
                data: result.message
                pageSize: rowLength * numberOfRows
                change: ->
                    $.publish "/gallery/page", [ dataSource ]
                sort:
                    dir: "desc"
                    field: "name"
            
            dataSource.read()

            deferred.resolve dataSource

        $.publish "/postman/deliver", [ {}, "/file/read", [] ]

        deferred.promise()

    createPage = (dataSource, $container) -> 
        rows = (dataSource.view()[i * rowLength ... (i+1) * rowLength] for i in [0 ... numberOfRows])

        $container.html template(rows: rows)

    createDetailsViewModel = (message) ->
        $.extend {}, message,
            deleteItem: ->
                deleteToken = $.subscribe "/file/deleted/#{message.name}", =>
                    $.unsubscribe deleteToken
                    this.close()
                $.publish "/postman/deliver", [  name: message.name, "/file/delete", [] ]
            close: ->
                $.publish "/gallery/details/hide"


    setupSubscriptionEvents = ($container) ->

        kendo.fx.hide =
            setup: (element, options) ->
                $.extend { height: 25 }, options.properties

        $.subscribe "/gallery/details/hide", ->
            $container.find(".details").kendoStop(true).kendoAnimate
                effects: "zoomOut"
                hide: true

        $.subscribe "/gallery/details/show", (message) ->
            model = createDetailsViewModel(message)
            $container.find(".details").remove()
            $details = $(detailsTemplate(model))

            kendo.bind($details, model)
            $container.append $details
            
            $details.kendoStop(true).kendoAnimate
                effects: "zoomIn"
                show: true

        $.subscribe "/gallery/hide", ->
            console.log "hide gallery"
            $("#footer").animate "margin-top": "-60px"
            $("#wrap").kendoStop(true).css(height: "100%").kendoAnimate
                effects: "expand"
                show: true
                duration: 1000
                complete: ->
                    $.publish "/camera/pause", [false]
                    $container.hide()

        $.subscribe "/gallery/list", ->
            console.log "show gallery"
            $.publish "/camera/pause", [true]
            $container.show()
            $("#footer").animate "margin-top": 0
            $("#wrap").kendoStop(true).kendoAnimate
                effects: "expand"
                reverse: true
                hide: true
                duration: 1000

        $.subscribe "/gallery/page", (dataSource) ->
            createPage dataSource, $container

    pub =
        init: (selector) ->
            $container = $(selector)

            # after loading the images
            loadImages().done (dataSource) ->
                console.log "done loading images"
                
                # set up the DOM events
                $container.on "click", ".thumbnail", ->
                    $media = $(this).children().first()
                    $.publish "/gallery/details/show", [{ src: $media.attr("src"), type: $media.data("media-type"), name: $media.data("file-name") }]

                changePage = (direction) ->
                    # TODO: add transition effect...
                    if direction > 0 and dataSource.page() > 1
                        dataSource.page dataSource.page() - 1
                    if direction < 0 and dataSource.page() < dataSource.totalPages()
                        dataSource.page dataSource.page() + 1

                $container.kendoMobileSwipe (e) ->
                     #changePage (e.direction == "up") - (e.direction == "down")
                     changePage (e.direction == "left") - (e.direction == "right")

                $.subscribe "/events/key/arrow", (e) ->
                    changePage (e == "down") - (e == "up")

                setupSubscriptionEvents $container
                
                # TODO: trigger refresh of items in list
                $.subscribe "/gallery/add", (file) ->
                    dataSource.add file

                $.publish "/gallery/page", [ dataSource ]