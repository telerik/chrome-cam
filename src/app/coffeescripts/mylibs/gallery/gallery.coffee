define [
    'mylibs/utils/utils',
    'mylibs/filesystem/filesystem',
    'text!mylibs/gallery/views/gallery.html'
], (utils, filesystem, template) ->
    pub =
        init: (selector) ->
            $container = $(selector)
            $container.append $(template)

            $thumbnailList = $(".thumbnails", $container)

            $thumbnailList.kendoListView
                template: kendo.template($("#gallery-thumbnail").html())
                dataSource: filesystem.dataSource
            
            $thumbnailList.on "click", ".thumbnail", ->
                $.publish "/gallery/show", [$(this).data("file-name")]

            $.subscribe "/gallery/list", ->
                $.publish "/previews/pause", [true]
                $container.slideDown()
                $("#preview").slideUp()

            $.subscribe "/gallery/hide", ->
                $container.slideUp()
                $("#preview").slideDown ->
                    $.publish "/previews/pause", [false]

            $.subscribe "/gallery/show", (fileName) ->
                console.log fileName