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
    el = {}
    webgl = fx.canvas()
    frame = 0
    ds = {}
    el = {}
    
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

    keyboard = (enabled) ->

        # if we have enabled keyboard navigation
        if enabled

            # subscribe to the left arrow key
            $.subscribe "/events/key/arrow", (e) ->

                page e

        # otherwise
        else

            # unsubscribe from events
            $.unsubcribe "/events/key/arrow"

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
            
            # the container for this DOM fragment is passed in by the module
            # which calls it's init. grab it from the DOM and cache it.
            # attach a kendo mobile swipe event to the container. this is what
            # will page through the effects
            el.container = $(selector).kendoTouch {
                enableSwipe: true,
                swipe: (e) ->

                    # page in the direction of the swipe
                    page e.direction
            }

            # in order to page through previews, we need to create two pages. the current
            # page and the next page.
            el.page1 = $(pageTemplate).appendTo(el.container)
            el.page2 = $(pageTemplate).appendTo(el.container)

            previousPage = el.page1
            nextPage = el.page2

            # create a new kendo data source
            ds = new kendo.data.DataSource
                    
                # set the data equal to the array of effects from the effects
                # object
                data: effects.data
                
                # we want it in chunks of six
                pageSize: 6
                
                # when the data source changes, this event will fire
                change: ->

                    # pause. we are changing pages so stop drawing.
                    #   paused = true

                    # create an array of previews for the current page
                    previews = []

                    # w'e need these 6 items broken up into a top and bottom
                    # set of images for the flexbox
                    top = this.view().slice(0,3)
                    bottom = this.view().slice(3,6)

                    create = (data) ->

                        half = $(halfTemplate)

                        for item in data

                            # this is wrapped in a closure so that it doesn't step on itself during
                            # the async loop
                            do ->

                                # get the template for the current preview
                                template = kendo.template(previewTemplate)

                                # create a preview object which extends the current item in the dataset
                                # preview = {}
                                # $.extend(preview, item)

                                # preview.canvas = document.createElement "canvas"
                                # preview.canvas.width = canvas.width
                                # preview.canvas.height = canvas.height      

                                # run the DOM template through a kendo ui template
                                preview = template { effect: item.id, name: item.name }
                                
                                thing = document.createElement "canvas"
                                thing.width = canvas.width
                                thing.height =canvas.height

                                
                                
                                half.append $(preview).find("a").append(thing).end()

                                previews.push { canvas: thing, filter: item.filter }

                                # wrap the template output   in jQuery
                                # content = $(content)

                                # push the current effect onto the array
                                # previews.push(preview)

                                # add the videos to the page
                                # content.find("a").append(preview.canvas)
                                #                   .click ->

                                #     # pause the effects
                                #     # paused = true

                                #     # transition the new screen in 
                                #     $.publish("/full/show", [preview])

                                # half.append(content)

                        return half

                    # we want to append our two halves on to the next page
                    nextPage.append create(top)
                    nextPage.append create(bottom)

                    # pause the camera. that will additionally pause
                    # these previews so there is no need to pause this
                    # as well. 

                    # move the current page out and the next page in
                    el.container.kendoAnimate {
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
                    }

                    # move the next page in
                    # nextPage.kendoStop(true).kendoAnimate({
                    #     effects: animation.in(),
                    #     duration: 200,
                    #     show: true,
                    #     complete: ->
                    #         # unpause the camera
                    #         $.publish "/camera/pause", false
                    # })


            # read from the datasource
            ds.read()    
    

