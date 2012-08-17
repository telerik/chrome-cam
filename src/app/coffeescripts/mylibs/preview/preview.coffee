define([
  'libs/webgl/effects'
  'mylibs/utils/utils'
  'text!mylibs/preview/views/selectPreview.html'
], (effects, utils, template) ->
    
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

        if not paused

            # get the 2d canvas context and draw the image
            # this happens at the curent framerate
            ctx.drawImage(window.HTML5CAMERA.canvas, 0, 0, canvas.width, canvas.height)
            
            # for each of the preview objects, create a texture of the 
            # 2d canvas and then apply the webgl effect. these are live
            # previews
            for preview in previews

                # increment the curent frame counter. this is used for animated effects
                # like old movie and vhs. most effects simply ignore this
                frame++

                # if this is a face tracking effect, we need to pass in a regular canvas
                # instead of a webgl one
                if preview.kind == "face"

                    preview.filter(preview.canvas, canvas)

                # otherwise pass in the webgl canvas, the canvas that contains the 
                # video drawn from the application canvas and the current frame.
                else
           
                    preview.filter(preview.canvas, canvas, frame)

        # LOOP!
        utils.getAnimationFrame()(draw)
    
    # anything under here is public
    pub = 
        
        # makes the internal draw function publicly accessible
        draw: ->
            
            draw()
            
        
        init: (selector) ->
        
            # initialize effects
            effects.init()

            # create an internal canvas that contains a copy of the video. we can't
            # modify the original video feed so we'll modify a copy instead.
            canvas = document.createElement("canvas")
            canvas.width = 344
            canvas.height= 216

            ctx = canvas.getContext("2d")
            
            # the container for this DOM fragment is passed in by the module
            # which calls it's init. grab it from the DOM and cache it.
            $container = $("#{selector}")


            # we need to create a top and bottom row in our flexbox
            top = 
                el: $("<div class='half'></div>")

            bottom = 
                el: $("<div class='half'></div>")


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
                                $template = kendo.template(template)

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
                                $content.find("a").append(preview.canvas).click ->

                                    # pause the effects
                                    paused = true

                                    # transition the new screen in 
                                    $.publish("/full/show", [preview])


                                half.el.append($content)


                    create(top)
                    create(bottom)

                $container.append(top.el)
                $container.append(bottom.el)

            # read from the datasource
            ds.read()    
    
)
