define [
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'text!mylibs/preview/views/preview.html'
  'text!mylibs/preview/views/half.html'
  'text!mylibs/preview/views/page.html'
], (effects, utils, previewTemplate, halfTemplate, pageTemplate) ->
    
    ###     Select Preview

    Select preview shows pages of 6 live previews using webgl effects

    ###

    # object level vars

    paused = false
    canvas = {}
    ctx = {}
    previews = []
    frame = 0
    ds = {}
    flipping = false

    shouldUpdateThumbnails = true
    setThumbnailsToBeUpdated = ->
        shouldUpdateThumbnails = true if not flipping
    setInterval setThumbnailsToBeUpdated, 1000
    
    # define the animations. we slide different directions depending on if we are going forward or back.
    animation = 
        effects: "pageturn:horizontal"
        reverse: false
        duration: 800
        
    # the main draw loop which renders the live video effects      
    draw = ->

        $.subscribe "/camera/stream", (stream)->

            if not paused

                # get the 2d canvas context and draw the image
                # this happens at the curent framerate
                ctx.drawImage stream.canvas, 0, 0, canvas.width, canvas.height
                
                # for each of the preview objects, create a texture of the 
                # 2d canvas and then apply the webgl effect. these are live
                # previews
                for preview in previews

                    # increment the curent frame counter. this is used for animated effects
                    # like old movie and vhs. most effects simply ignore this
                    frame++
               
                    preview.filter preview.canvas, canvas, frame, stream.track

                    if shouldUpdateThumbnails
                        previewContext = preview.canvas.getContext("2d")
                        imageData = previewContext.getImageData(0, 0, preview.canvas.width, preview.canvas.height)
                        eventData = 
                            width: imageData.width
                            height: imageData.height
                            data: imageData.data
                            key: preview.name
                        $.publish "/postman/deliver", [ data: eventData, "/preview/thumbnail/request" ]

                shouldUpdateThumbnails = false

    keyboard = (enabled) ->

        # if we have enabled keyboard navigation
        if enabled

            # subscribe to the left arrow key
            $.subscribe "/keyboard/arrow", (e) ->

                if not flipping
                    page e

        # otherwise
        else

            # unsubscribe from events
            $.unsubcribe "/keyboard/arrow"

    page = (direction) ->

        # if the direction requested was left
        if direction == "left"

            animation.reverse = false

            # if the current page is less than the total 
            # number of pages
            if ds.page() < ds.totalPages()

                # go to the next page
                ds.page ds.page() + 1

        # otherwise
        else

            animation.reverse = true

            # if this isn't page one
            if ds.page() > 1

                # go to the previous page
                ds.page(ds.page() - 1)


    # anything under here is public
    pub = 

        # makes the internal draw function publicly accessible
        draw: ->
            draw()

        before: ->
            # make sure the camera isn't paused cause we need it now
            $.publish "/camera/pause", [ false ]

        swipe: (e) ->
            # page in the direction of the swipe
            if not flipping
                page e.direction
            
        init: (selector) ->
        
            # initialize effects
            # TODO: this should be initialized somewhere else
            effects.init()

            # bind to keyboard events
            keyboard true

            # subscribe to the pause and unpause events
            $.subscribe "/previews/pause", (isPaused) ->
                paused = isPaused 

            # create an internal canvas that contains a copy of the video. this
            # is so we can resize the video stream without resizing the original canvas
            # which contains our unadulturated stream
            canvas = document.createElement("canvas")
            ctx = canvas.getContext("2d")

            # set the width and height of the previews
            canvas.width = 360 
            canvas.height = 240

            # in order to page through previews, we need to create two pages. the current
            # page and the next page.
            page1 = new kendo.View(selector, null)
            page2 = new kendo.View(selector, null)

            previousPage = page1.render().addClass("page")
            nextPage = page2.render().addClass("page")

            # create a new kendo data source
            ds = new kendo.data.DataSource
                    
                # set the data equal to the array of effects from the effects
                # object
                data: effects.data
                
                # we want it in chunks of six
                pageSize: 6
                
                # when the data source changes, this event will fire
                change: ->

                    flipping = true

                    # pause. we are changing pages so stop drawing.
                    #   paused = true

                    # create an array of previews for the current page
                    previews = []

                    index = 0
                    for item in @.view()

                        # this is wrapped in a closure so that it doesn't step on itself during
                        # the async loop
                        do (item) ->

                            filter = document.createElement "canvas"
                            filter.width = canvas.width
                            filter.height =canvas.height

                            img = document.createElement "img"
                            img.width = canvas.width
                            img.height = canvas.height

                            data = { effect: item.id, name: item.name, col: index % 3, row: Math.floor index / 3 }
                            index++

                            filters = new kendo.View(nextPage, previewTemplate, data)
                            html = filters.render()
                            html.find(".canvas").append(filter).append(img).click ->

                                paused = true

                                $.publish "/full/show", [ item ]

                            previews.push { canvas: filter, filter: item.filter, name: item.name }

                    # move the current page out and the next page in
                    page1.container.find("canvas").hide()
                    page1.container.find("img").show()
                    shouldUpdateThumbnails = true
                    flippy = ->
                        page1.container.kendoAnimate
                            effects: animation.effects
                            face: if animation.reverse then nextPage else previousPage
                            back: if animation.reverse then previousPage else nextPage
                            duration: animation.duration
                            reverse: animation.reverse
                            complete: ->
                                page1.container.find("img").hide()
                                page1.container.find("canvas").show()

                                # the current page becomes the next page
                                justPaged = previousPage
                                
                                previousPage = nextPage
                                nextPage = justPaged

                                justPaged.empty()

                                flipping = false
                    setTimeout flippy, 100


            # read from the datasource
            ds.read()   

            $.subscribe "/preview/thumbnail/response/", (e) ->
                $("[data-filter-name='#{e.key}']", selector).find("img").attr("src", e.src)

            $.subscribe "/preview/pause", (pause) ->
                paused = pause
    

