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

    files = []

    loadImages = ->
        deferred = $.Deferred()

        filewrapper.list().done (f) ->
            files = f

            if files and files.length > 0
                photos = (file for file in files when file.type == 'jpg')
                if photos.length > 0
                    filewrapper.readFile(photos[photos.length - 1].name).done (latestPhoto) ->
                        $.publish "/bar/preview/update", [thumbnailURL: latestPhoto.file]


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

        $.publish "/postman/deliver", [ {}, "/file/read" ]

        deferred.promise()

    createPage = (dataSource, $container) -> 
        rows = (dataSource.view()[i * rowLength ... (i+1) * rowLength] for i in [0 ... numberOfRows])

        for file in dataSource.view()
            filewrapper.readFile(file.name).done (file) ->
                $container.find("[data-file-name='#{file.name}']").attr("src", file.file)

        $container.html template(rows: rows)

    createDetailsViewModel = (message) ->
        # back and next seem ... backwards
        viewModel =
            deleteItem: ->
                filewrapper.deleteFile(@filename).done =>
                    @close()
            close: ->
                $.publish "/gallery/details/hide"
            canGoToNext: ->
                @get("indexInGallery") > 0
            canGoToPrevious: ->
                @get("indexInGallery") < files.length - 1
            goToNext: ->
                @init files[@get("indexInGallery") - 1]
            goToPrevious: ->
                @init files[@get("indexInGallery") + 1]
            getIndexInGallery: ->
                return i for i in [0...files.length] when files[i].name == @get("filename")
            isVideo: ->
                @get("type") == "webm"
            init: (message) ->
                @set "filename", message.name
                @set "src", message.file || ""
                @set "type", message.type
                @set "indexInGallery", @getIndexInGallery()
                if not message.file
                    filewrapper.readFile(@get("filename")).done (file) =>
                        @set "src", file.file
                return this

        kendo.observable(viewModel).init(message)

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

            # TODO: Use kendoAnimate for this
            $("#footer").animate "margin-top": "-60px"
            $("#wrap").kendoAnimate { effects: "slideIn:down", duration: 500 }
            $("#wrap")[0].style.height = "100%";

            $.publish "/camera/pause", [false]
            $.publish "/bar/gallerymode/hide"

        $.subscribe "/gallery/list", ->
            console.log "show gallery"
            $.publish "/camera/pause", [true]
            $("#footer").animate "margin-top": 0

            # TODO: Use kendoAnimate for this
            $("#wrap").addClass "animate"
            $("#wrap").kendoAnimate { effects: "slide:up", duration: 500 }
            $("#wrap").css "height", 0

            $.publish "/bar/gallerymode/show"

        $.subscribe "/gallery/page", (dataSource) ->
            createPage dataSource, $container

    pub =
        init: (selector) ->
            $container = $(selector)

            # after loading the images
            loadImages().done (dataSource) ->

                console.log "done loading images"
                
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