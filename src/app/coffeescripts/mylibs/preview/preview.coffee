define([
  'libs/webgl/effects'
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
    $container = {}
    webgl = fx.canvas()
    frame = 0
    direction = "left"

    # define the animations. we slide different directions depending on if we are going forward or back.
    pageAnimation = () ->

        pageOut: "slide:#{direction} fadeOut"
        pageIn: "slideIn:#{direction} fadeIn"
        
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
               
                    preview.filter(preview.canvas, canvas, frame, stream.track)

    # anything under here is public
    pub = 
        
        # makes the internal draw function publicly accessible
        draw: ->
            
            draw()
            
        
        init: (selector) ->
        
            # initialize effects
            # TODO: this should be initialized somewhere else
            effects.init()

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
            canvas.height= 240
            
            # the container for this DOM fragment is passed in by the module
            # which calls it's init. grab it from the DOM and cache it.
            $container = $(selector)

            # attach a kendo mobile swipe event to the container. this is what
            # will page through the effects
            $container.kendoMobileSwipe ->

                # pause the camera. that will additionally pause
                # these previews so there is no need to pause this
                # as well.
                $.publish "/camera/pause", [ true ] 

                # if the current page is less than the total 
                # number of pages
                if ds.page() < ds.totalPages()
                    # go to the next page
                    ds.page ds.page() + 1
                # otherwise
                else
                    # go back to the first page
                    ds.page 1

            , surface: $container

            # we need to create top and bottom rows in our flexbox. these are
            # objects which will hold the top and bottom elements now and an
            # array of the data that belongs in the elements later
            top = { el: $(halfTemplate) }
            bottom = { el: $(halfTemplate) }

            # in order to page through previews, we need to create two pages. the current
            # page and the next page.
            $currentPage = $(pageTemplate).appendTo($container)
            $nextPage = $(pageTemplate).appendTo($container)
            
            # set the current page
            currentPage = $currentPage
            nextPage = $nextPage

            # store the current page reference
            currentPage = $nextPage

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

                    # we need these 6 items broken up into a top and bottom
                    # set of images for the flexbox
                    top.data = this.view().slice(0,3)
                    bottom.data = this.view().slice(3,6)

                    create = (half) ->

                        half.el.empty()

                        for item in half.data

                            # this is wrapped in a closure so that it doesn't step on itself during
                            # the async loop
                            do ->

                                # get the template for the current preview
                                $template = kendo.template(previewTemplate)

                                # create a preview object which extends the current item in the dataset
                                preview = {}
                                $.extend(preview, item)

                                preview.canvas = fx.canvas()         

                                # run the DOM template through a kendo ui template
                                content = $template({ name: preview.name })

                                # wrap the template output in jQuery
                                $content = $(content)

                                # push the current effect onto the array
                                previews.push(preview)

                                # add the videos to the page
                                $content.find("a").append(preview.canvas)
                                                  .click ->

                                    # pause the effects
                                    paused = true

                                    # transition the new screen in 
                                    $.publish("/full/show", [preview])

                                half.el.append($content)


                    create(top)
                    create(bottom)

                    # we want to append our two halves on to the next page
                    nextPage.append(top.el)
                    nextPage.append(bottom.el)

                    # now move the current page out and the next page in
                    # currentPage.kendoStop(true).kendoAnimate({
                    #     effects: "slide:left"
                    #     duration: 200,
                    #     hide: true,
                    #     complete: ->
                    #         # the current page becomes the next page
                    #         justPaged = nextPage
                            
                    #         currentPage = nextPage
                    #         nextPage = currentPage

                    # })

                    # # move the next page in
                    # nextPage.kendoStop(true).kendoAnimate({
                    #     effects: "slideIn:right",
                    #     duration: 200,
                    #     show: true
                    # })


            # read from the datasource
            ds.read()    
    
)
