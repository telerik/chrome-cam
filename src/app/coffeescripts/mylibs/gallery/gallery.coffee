define [
    'mylibs/utils/utils',
    'text!mylibs/gallery/views/gallery.html'
], (utils, template) ->
    loadImages = ->
        deferred = $.Deferred()

        token = $.subscribe "/pictures/bulk", (result) ->
            $.unsubscribe token
            dataSource = new kendo.data.DataSource
                data: result.message
                pageSize: 12
            deferred.resolve dataSource

        $.publish "/postman/deliver", [ {}, "/file/read", [] ]

        deferred.promise()

    setupSubscriptionEvents = ($container) ->
        $.subscribe "/gallery/show", (fileName) ->
            console.log fileName

        $.subscribe "/gallery/hide", ->
            $container.kendoStop().kendoAnimate
                effect: "slide:down"
                duration: 1000
                hide: true
            $("#preview").kendoStop().kendoAnimate
                effect: "slideIn:down"
                duration: 1000
                show: true
                complete: ->
                    $.publish "/previews/pause", [false]

        $.subscribe "/gallery/list", ->
            $.publish "/previews/pause", [true]
            $container.kendoStop().kendoAnimate
                effect: "slideIn:up"
                duration: 1000
                show: true
            $("#preview").kendoStop().kendoAnimate
                effect: "slide:up"
                duration: 1000
                hide: true

    pub =
        init: (selector) ->
            $container = $(selector)
            $container.append $(template)

            $thumbnailList = $(".thumbnails", $container)

            # after loading the images
            loadImages().done (dataSource) ->
                console.log dataSource

                # set up the DOM events
                $thumbnailList.on "click", ".thumbnail", ->
                    $.publish "/gallery/show", [$(this).data("file-name")]

                # TODO: add transition effect...
                $container.kendoMobileSwipe (e) -> 
                    if e.direction == "right" && dataSource.page() > 1
                        dataSource.page dataSource.page() - 1
                    
                    if e.direction == "left" && dataSource.page() < dataSource.totalPages()
                        dataSource.page dataSource.page() + 1

                setupSubscriptionEvents $container
                
                $thumbnailList.kendoListView
                    template: kendo.template $("#gallery-thumbnail").html()
                    dataSource: dataSource