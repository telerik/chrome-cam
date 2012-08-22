define [
    'mylibs/utils/utils',
    'mylibs/filesystem/filesystem',
    'text!mylibs/gallery/views/gallery.html'
], (utils, filesystem, template) ->
    pub =
        init: (selector) ->
            $container = $(selector)
            $container.append $(template)

            $thumbnailList = $("ul.thumbnails", $container)

            $thumbnailList.kendoListView
                template: kendo.template($("#gallery-thumbnail").html())
                dataSource: filesystem.dataSource
            
            $thumbnailList.on "click", "li", ->
                $.publish "/gallery/show", [$(this).data("file-name")]

            $.subscribe "/gallery/show", (fileName) ->
                console.log fileName