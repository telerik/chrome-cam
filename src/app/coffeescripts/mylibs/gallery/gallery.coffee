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

                # set up the subscription events
                $.subscribe "/gallery/hide", ->
                    $container.slideUp()
                    $("#preview").slideDown ->
                        $.publish "/previews/pause", [false]

                $.subscribe "/gallery/show", (fileName) ->
                    console.log fileName

                $.subscribe "/gallery/list", ->
                    $.publish "/previews/pause", [true]
                    $container.slideDown()
                    $("#preview").slideUp()
                
                $thumbnailList.kendoListView
                    template: kendo.template $("#gallery-thumbnail").html()
                    dataSource: dataSource