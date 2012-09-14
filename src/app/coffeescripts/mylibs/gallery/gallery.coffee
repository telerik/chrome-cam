define [
    'Kendo'
    'mylibs/utils/utils'
    'mylibs/file/filewrapper'
    'text!mylibs/gallery/views/row.html'
], (kendo, utils, filewrapper, template) ->
    
    dim =
        cols: 4
        rows: 3
    ds = {}
    files = []
    container = {}
    el = {}
    selected = {} 
    total = 0
    index = 0

    animation = 
        effects: "pageturn:horizontal"
        reverse: false
        duration: 800      

    page = (direction) =>
        # TODO: add transition effect...
        if direction > 0 and @ds.page() > 1
            animation.reverse = true
            @ds.page @ds.page() - 1
        if direction < 0 and @ds.page() < @ds.totalPages()
            animation.reverse = false
            @ds.page @ds.page() + 1

    destroy = =>

        name = selected.find("img").data("file-name")
        
        selected.kendoStop(true).kendoAnimate
            effects: "zoomOut fadOut"
            hide: true
            complete: =>
                filewrapper.deleteFile(name).done -> 
                    selected.remove()
                    # TODO: not sure how it helps to remove
                    # the item from the datasource since its
                    # not hooked up to anything
                    # @ds.remove(@ds.get(name))

    get = (name) => 
        @ds.get(name)    

    pub =

        before: (e) ->

            container.parent().height($(window).height() - 50)
            container.parent().width($(window).width())

            # pause the camera. there is no need for it
            # right now.
            $.publish "/camera/pause", [ true ]

        hide: (e) ->
            $.publish "/camera/pause", [ false ]

        swipe: (e) ->
            page (e.direction == "right") - (e.direction == "left")

        init: (selector) =>

            # create the pages that hold the thumbnails
            # in order to page through previews, we need to create two pages. the current
            # page and the next page.
            page1 = new kendo.View(selector, null)
            page2 = new kendo.View(selector, null)

            # get a reference to the view container
            container = page1.container

            previousPage = page1.render().addClass("page gallery")
            nextPage = page2.render().addClass("page gallery")

            #delegate some events to the gallery
            page1.container.on "dblclick", ".thumbnail", ->
                media = $(this).children().first()
                index = get("#{media.data("file-name")}")
                data = { src: media.attr("src"), type: media.data("media-type"), name: media.data("file-name"), length: files.length, index: index }
                $.publish "/details/show", [data]

            page1.container.on "click", ".thumbnail", ->
                $.publish "/top/update", ["selected"]
                page1.find(".thumbnail").removeClass "selected"
                selected = $(@).addClass "selected"

            # resolves the deffered from images that
            # are loading in from the file system
            # filewrapper.list().done (f) =>
            # TESTING
            f = [{ name: "123456", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "1", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "2", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "3", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "4", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "5", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "6", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "7", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "8", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "9", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "10", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "11", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "12", file: "http://mantle.me/me.jpeg", type: "jpeg" },
            { name: "13", file: "http://mantle.me/me.jpeg", type: "jpeg" } ]
            do =>
            # END TESTING

                files = f
                total = files.length

                @ds = new kendo.data.DataSource
                    data: files
                    pageSize: dim.rows * dim.cols
                    change: ->

                        rows = (this.view()[i * dim.cols ... (i+1) * dim.cols] for i in [0 ... dim.rows])
                        for row in rows

                            # create a new row
                            line = new kendo.View(nextPage)
                            line.render().addClass("gallery-row")

                            for item in row

                                # the item isn't actually here yet, we need to go and
                                # get it

                                # FOR TESTING
                                thumbnail = new kendo.View(line.content, template, item)
                                thumbnail.render()

                                # do ->
                                #     filewrapper.readFile(item.name).done (file)->
                                #         thumbnail = new kendo.View(line.content, template, file)
                                #         thumbnail.render()

                        # move the current page out and the next page in
                        container.kendoAnimate {
                            effects: animation.effects
                            face: if animation.reverse then nextPage else previousPage
                            back: if animation.reverse then previousPage else nextPage
                            duration: animation.duration
                            reverse: animation.reverse
                            complete: ->
                                # the current page becomes the next page
                                justPaged = previousPage

                                previousPage = nextPage
                                nextPage = justPaged

                                justPaged.empty()

                                flipping = false
                        }

                    schema: 
                        model:
                            id: "name"
                    sort:
                        dir: "desc" 
                        field: "name"         
                
                @ds.read()

            $.publish "/postman/deliver", [ {}, "/file/read" ]

            $.subscribe "/gallery/delete", ->
                destroy()

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
