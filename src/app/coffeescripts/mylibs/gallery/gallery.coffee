define [
    'Kendo'
    'mylibs/utils/utils'
    'mylibs/file/filewrapper'
    'text!mylibs/gallery/views/gallery.html'
    'text!mylibs/gallery/views/details.html'
], (kendo, utils, filewrapper, templateSource, detailsTemplateSource) ->
    template = kendo.template(templateSource)
    detailsTemplate = kendo.template(detailsTemplateSource)

    rowLength = 4
    numberOfRows = 4

    loadImages = ->
        deferred = $.Deferred()

        $.publish "/bar/preview/update", [thumbnailURL: "derpderpin"]

        filewrapper.list().done (files) ->
            # if files && files.length > 0
            #     $.publish "/bar/preview/update", [thumbnailURL: files[files.length - 1].file]

            dataSource = new kendo.data.DataSource
                data: files
                pageSize: rowLength * numberOfRows
                change: ->
                    $.publish "/gallery/page", [ dataSource ]
                sort:
                    dir: "desc"
                    field: "name"
            
            dataSource.read()

            deferred.resolve dataSource

        deferred.promise()

    createPage = (dataSource, $container) -> 
        rows = (dataSource.view()[i * rowLength ... (i+1) * rowLength] for i in [0 ... numberOfRows])

        for file in dataSource.view()
            filewrapper.readFile(file.name).done (file) ->
                $container.find("[data-file-name='#{file.name}']").attr("src", file.file)

        $container.html template(rows: rows)

    createDetailsViewModel = (message) ->
        $.extend {}, message,
            deleteItem: ->
                filewrapper.deleteFile(message.name).done =>
                    this.close()
            close: ->
                $.publish "/gallery/details/hide"
            canGoToNext: ->
                true
            canGoToPrevious: ->
                true
            goToNext: ->
                console.log "Next"
            goToPrevious: ->
                console.log "Previous"

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
            # HACK
            $("#wrap").show()
            console.log "hide gallery"

            # TODO: Use kendoAnimate for this
            $("#footer").animate "margin-top": "-60px"
            $("#wrap")[0].style.height = "100%";

            $.publish "/camera/pause", [false]
            $.publish "/bar/gallerymode/hide"
            $container.hide()

        $.subscribe "/gallery/list", ->
            console.log "show gallery"
            $.publish "/camera/pause", [true]
            $container.show()
            $("#footer").animate "margin-top": 0

            # TODO: Use kendoAnimate for this
            wrap = $("#wrap")
            wrap.addClass "animate"
            wrap.css(height: 0)

            # HACK
            setTimeout (-> wrap.hide()), 1000

            $.publish "/bar/gallerymode/show"

        $.subscribe "/gallery/page", (dataSource) ->
            createPage dataSource, $container

    pub =
        init: (selector) ->
            $container = $(selector)

            # after loading the images
            loadImages().done (dataSource) ->
                # set up the DOM events
                $container.on "dblclick", ".thumbnail", ->
                    $media = $(this).children().first()
                    $.publish "/gallery/details/show", [{ src: $media.attr("src"), type: $media.data("media-type"), name: $media.data("file-name") }]

                $container.on "click", ".thumbnail", ->
                    $(selector).find(".thumbnail").each ->
                        $(this).removeClass("selected")

                    $(this).addClass("selected")

                changePage = (direction) ->
                    # TODO: add transition effect...
                    if direction > 0 and dataSource.page() > 1
                        dataSource.page dataSource.page() - 1
                    if direction < 0 and dataSource.page() < dataSource.totalPages()
                        dataSource.page dataSource.page() + 1

                $container.kendoMobileSwipe (e) ->
                     #changePage (e.direction == "up") - (e.direction == "down")
                     changePage (e.direction == "right") - (e.direction == "left")

                $.subscribe "/events/key/arrow", (e) ->
                    changePage (e == "down") - (e == "up")

                setupSubscriptionEvents $container
                
                # TODO: trigger refresh of items in list
                $.subscribe "/gallery/add", (file) ->
                    dataSource.add file

                $.publish "/gallery/page", [ dataSource ]