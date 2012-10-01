define [
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'text!mylibs/preview/views/preview.html'
], (effects, utils, previewTemplate) ->
    
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

    columns = 2
    
    # define the animations. we slide different directions depending on if we are going forward or back.
    animation = 
        effects: "pageturn:horizontal"
        reverse: false
        duration: 800

    isFirstChange = true

    # the main draw loop which renders the live video effects      
    draw = ->

        $.subscribe "/camera/stream", (stream) ->

            if not paused

                # TODO: invert this
                for preview in previews
                    el = $(".preview[data-filter-name='#{preview.name}']")
                    continue unless el.is(".hover")

                    # increment the curent frame counter. this is used for animated effects
                    # like old movie and vhs. most effects simply ignore this
                    frame++
                    
                    # get the 2d canvas context and draw the image
                    # this happens at the curent framerate
                    ctx.drawImage stream.canvas, 0, 0, canvas.width, canvas.height

                    effects.advance canvas
                    preview.filter preview.canvas, canvas, frame, stream.track

                request = ->
                    $.publish "/postman/deliver", [null, "/camera/request"]
                setTimeout request, 1

    keyboard = (enabled) ->

        # if we have enabled keyboard navigation
        if enabled

            # subscribe to the left arrow key
            keyboard.token = $.subscribe "/keyboard/arrow", (e) ->

                if not flipping
                    page utils.oppositeDirectionOf(e)

        # otherwise
        else

            # unsubscribe from events
            $.unsubscribe keyboard.token

    page = (direction) ->
        # if the direction requested was left
        if direction == "left"

            animation.reverse = false

            # if the current page is less than the total 
            # number of pages
            if ds.page() < ds.totalPages()
                arrows.both.hide()

                # go to the next page
                ds.page ds.page() + 1

        # otherwise
        else

            animation.reverse = true

            # if this isn't page one
            if ds.page() > 1
                arrows.both.hide()

                # go to the previous page
                ds.page(ds.page() - 1)

    arrows =
        left: null
        right: null
        both: null
        init: (parent) ->
            arrows.left = parent.find(".previous")
            arrows.left.hide()
            arrows.right = parent.find(".next")
            arrows.both = $([arrows.left[0], arrows.right[0]])

            # in this case, "right" means "previous" and "left" means "next" because of the "natural" scrolling
            arrows.left.on "click", ->
                page "right"
            arrows.right.on "click", ->
                page "left"

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

            $.publish "/postman/deliver", [null, "/camera/request"]
        
            # initialize effects
            # TODO: this should be initialized somewhere else
            effects.init()

            # bind to keyboard events
            keyboard true

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

            arrows.init $(selector).parent()

            # jQuery 1.8 breaks is(":hover")
            $(selector).on "mouseenter mouseleave", ".preview", ->
                $(this).toggleClass('hover')

            # create a new kendo data source
            ds = new kendo.data.DataSource
                    
                # set the data equal to the array of effects from the effects
                # object
                data: effects.data
                
                # we want it in chunks of six
                pageSize: 4
                
                # when the data source changes, this event will fire
                change: ->

                    flipping = true

                    # pause. we are changing pages so stop drawing.
                    #   paused = true

                    # create an array of previews for the current page
                    previews = []

                    index = 0
                    tracks = false

                    for item in @.view()

                        # this is wrapped in a closure so that it doesn't step on itself during
                        # the async loop
                        do (item) ->

                            filter = document.createElement "canvas"
                            filter.width = canvas.width
                            filter.height =canvas.height

                            data = { effect: item.id, name: item.name, col: index % columns, row: Math.floor index / columns }
                            index++

                            filters = new kendo.View(nextPage, previewTemplate, data)
                            html = filters.render()
                            html.find(".canvas").append(filter)
                            html.click ->

                                $.publish "/preview/pause", [ true ]
                                $.publish "/full/show", [ item ]

                            previews.push { canvas: filter, filter: item.filter, name: item.name }

                            tracks = tracks or item.tracks

                    $.publish "/postman/deliver", [ tracks, "/tracking/enable" ]

                    flipCompleted = ->
                        # the current page becomes the next page
                        justPaged = previousPage
                        
                        previousPage = nextPage
                        nextPage = justPaged

                        justPaged.empty()

                        flipping = false

                        arrows.left.show() if ds.page() > 1
                        arrows.right.show() if ds.page() < ds.totalPages()

                        $.publish "/postman/deliver", [ false, "/camera/pause" ]

                    flippy = ->
                        page1.container.kendoAnimate
                            effects: animation.effects
                            face: if animation.reverse then nextPage else previousPage
                            back: if animation.reverse then previousPage else nextPage
                            duration: animation.duration
                            reverse: animation.reverse
                            complete: flipCompleted

                    if isFirstChange
                        setTimeout flipCompleted, 1
                        isFirstChange = false
                    else
                        $.publish "/postman/deliver", [ true, "/camera/pause" ]
                        setTimeout flippy, 20


            # read from the datasource
            ds.read()

            $.subscribe "/preview/pause", (pause) ->
                paused = pause
                keyboard (not pause)

