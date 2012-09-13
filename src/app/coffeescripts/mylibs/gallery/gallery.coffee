define [
    'Kendo'
    'mylibs/utils/utils'
    'mylibs/file/filewrapper'
    'text!mylibs/gallery/views/row.html'
], (kendo, utils, filewrapper, template) ->
    
    dim =
        cols: 4
        rows: 4
    ds = {}
    files = []
    gallery = {}
    el = {}

    viewModel = kendo.observable {
        thumbnail:
            click: (e) ->
                gallery.container.find(".thumbnail").removeClass "selected"
                $(e).addClass "selected"
    }

    deleteFile = (filename) ->
        filewrapper.deleteFile(filename).done ->
            $.publish "/gallery/remove", [ filename ]

    # setupSubscriptionEvents = ->

    #     kendo.fx.hide =
    #         setup: (element, options) ->
    #             $.extend { height: 25 }, options.properties

    #     $.subscribe "/gallery/hide", ->
    #         # TODO: Use kendoAnimate for this
    #         # $("#footer").animate "margin-top": "-60px"
    #         # $("#wrap")[0].style.height = "100%";

    #         $.publish "/camera/pause", [false]
    #         $.publish "/bar/gallerymode/hide"

    #     $.subscribe "/gallery/page", (dataSource) ->
    #         createPage dataSource

    page = (direction) =>
        # TODO: add transition effect...
        if direction > 0 and @ds.page() > 1
            @ds.page @ds.page() - 1
        if direction < 0 and @ds.page() < @ds.totalPages()
            @ds.page @ds.page() + 1

    destroy = ->
        gallery.find("[data-file-name='#{fileName}']").kendoAnimate
            effects: "fadeOut"
            complete: ->
                # HACK: Don't access 'private' member
                deleted = file for file in @ds._data when file.name == filename
                @ds.remove deleted

    pub =

        before: (e) ->

            gallery.container.parent().height($(window).height())
            gallery.container.parent().width($(window).width())

            # pause the camera. there is no need for it
            # right now.
            $.publish "/camera/pause", [ true ]

        hide: (e) ->
            $.publish "/camera/pause", [ false ]

        init: (selector) =>

            # create the gallery view
            gallery = new kendo.View(selector)
            gallery.render(viewModel).addClass("gallery")

            # delegate some events to the gallery
            gallery.container.on "dblclick", ".thumbnail", ->
                console.log "Double Down!"
                media = $(this).children().first()
                $.publish "/details/show", [{ src: media.attr("src"), type: media.data("media-type"), name: media.data("file-name") }]

            gallery.container.on "click", ".thumbnail", ->
                gallery.find(".thumbnail").removeClass "selected"
                $(@).addClass "selected"

            # resolves the deffered from images that
            # are loading in from the file system
            filewrapper.list().done (f) =>
            # TESTING
            # f = [{ name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            # { name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            # { name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            # { name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            # { name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            # { name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            # { name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" }  ]
            # do =>
            # END TESTING

                files = f

                @ds = new kendo.data.DataSource
                    data: files
                    pageSize: dim.rows * dim.cols
                    change: ->
                    
                        rows = (this.view()[i * dim.cols ... (i+1) * dim.cols] for i in [0 ... dim.rows])
                        for row in rows

                            # create a new row
                            line = new kendo.View(gallery.content)
                            line.render().addClass("gallery-row")

                            for item in row

                                # the item isn't actually here yet, we need to go and
                                # get it

                                do ->
                                    filewrapper.readFile(item.name).done (file)->
                                        thumbnail = new kendo.View(line.content, template, file)
                                        thumbnail.render()

                    sort:
                        dir: "desc" 
                        field: "name"         
                
                @ds.read()

                # update the thumbnail
                if files and files.length > 0
                    photos = (file for file in files when file.type == 'jpg')
                    if photos.length > 0
                        filewrapper.readFile(photos[photos.length - 1].name).done (latestPhoto) ->
                            $.publish "/bottom/thumbnail", [latestPhoto.file]

            $.publish "/postman/deliver", [ {}, "/file/read" ]

                # after loading the images
                # load().done ->

                #     console.log "done loading images"
                    
                #     # set up the DOM events
                #     gallery.container.on "dblclick", ".thumbnail", ->
                #         media = $(this).children().first()
                #         $.publish "/gallery/details/show", [{ src: media.attr("src"), type: media.data("media-type"), name: media.data("file-name") }]

                #     gallery.container.on "click", ".thumbnail", ->
                #         gallery.el.thumbnail.each ->
                #             $(this).removeClass("selected")

                #         $(this).addClass("selected")
                #         item = $(this).children().first()

                #         # gotta find out what image what clicked here
                #         $.publish "/item/selected", [ { name: item.data("file-name"), file: item.attr("src") }] 
                        
                #     gallery.container.kendoMobileSwipe (e) ->
                #          page (e.direction == "right") - (e.direction == "left")

                #     # subscribe to events
                #     $.subscribe "/keyboard/arrow", (e) ->
                #         page (e == "down") - (e == "up")

                #     $.subscribe "/gallery/add", (file) ->
                #         ds.add file

                #     setupSubscriptionEvents()
                    

                #     $.subscribe "/gallery/remove", (filename) ->
                #         destroy();

                #     ds.read()

            return gallery
