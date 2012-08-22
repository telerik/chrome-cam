define [
    'mylibs/utils/utils',
    'mylibs/filesystem/filesystem',
    'text!mylibs/gallery/views/gallery.html'
], (utils, filesystem, template) ->
    pub =
        init: (selector) ->
            $container = $(selector)
            $container.append $(template)

            $("ul.thumbnails", $container).kendoListView
                dataSource: filesystem.dataSource
