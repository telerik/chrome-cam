define [
  'Kendo'
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'text!mylibs/full/views/full.html'
  'text!mylibs/full/views/transfer.html'
], (kendo, effects, utils, filewrapper, template, transferImg) ->
    
    canvas = {}
    ctx = {}
    video = {}
    videoCtx = {}
    paused = true
    frame = 0
    full = {}
    transfer = {}
    effect = {}

    paparazzi = {}

    # the main draw loop which renders the live video effects      
    draw = ->
        # subscribe to the app level draw event
        $.subscribe "/camera/stream", (stream) ->

            return if paused

            # increment the curent frame counter. this is used for animated effects
            # like old movie and vhs. most effects simply ignore this
            frame++

            # pass in the webgl canvas, the canvas that contains the 
            # video drawn from the application canvas and the current frame.
            effects.advance stream.canvas
            effect canvas, stream.canvas, frame, stream.track

            request = ->
                $.publish "/postman/deliver", [null, "/camera/request"]
            setTimeout request, 1

    flash = (callback, file) ->

        #  TODO: use enabled value
        full.el.flash.show()

        transfer.content.kendoStop().kendoAnimate 
            effects: "transfer",  
            target: $("#destination"), 
            duration: 1000, 
            ease: "ease-in",
            complete: ->
                $.publish "/bottom/thumbnail", [file]
                transfer.destroy()
                transfer = {}

                callback()

        full.el.flash.hide()

    capture = (callback) ->

        image = canvas.toDataURL("image/jpeg", 1.0)
        name = new Date().getTime()

        data = { src: image, height: full.content.height(), width: full.content.width() }

        transfer = new kendo.View(full.container, transferImg, data)
        transfer.render()

        # transfer image is fixed position so we have to give it a left offset
        transfer.content.offset({ left: full.el.wrapper.offset().left })
        
        transfer.find("img").load ->

            # set the name of this image to the current time string
            file = { type: "jpg", name: "#{name}.jpg", file: image }

            filewrapper.save(file.name, image)

            $.publish "/gallery/add", [file]

            flash(callback, file)

    index =
        current: ->
            # return is compulsory here; otherwise CoffeeScript will build an array.
            return i for i in [0...effects.data.length] when effects.data[i].filter is effect
        max: ->
            effects.data.length
        select: (i) ->
            pub.select effects.data[i]
        preview: (i) ->
            pub.select effects.data[i], true
        unpreview: ->
            pub.select effects.data[index.saved]
        saved: 0

    subscribe = (pub) ->
        $.subscribe "/full/show", (item) ->
            pub.show(item)

        $.subscribe "/capture/photo", ->
            pub.photo()
        
        $.subscribe "/capture/paparazzi", ->
            pub.paparazzi()

        $.subscribe "/countdown/paparazzi", ->
             full.el.paparazzi.removeClass "hidden"

        $.subscribe "/capture/video", ->
            pub.video()

        $.subscribe "/full/filters/show", (show) ->
            duration = 200
            if show
                full.el.filters.kendoStop().kendoAnimate
                    effects: "slideIn:right fade:in"
                    show: true
                    hide: false
                    duration: duration
            else
                full.el.filters.kendoStop().kendoAnimate
                    effects: "slide:left fade:out"
                    hide: true
                    show: false
                    duration: duration

        $.subscribe "/full/capture/begin", ->
            full.el.wrapper.addClass "capturing"

        $.subscribe "/full/capture/end", ->
            full.el.wrapper.removeClass "capturing"

        $.subscribe "/keyboard/arrow", (dir) ->
            return if paused

            if dir is "up" and index.current() > 0
                index.select index.current() - 1
            if dir is "down" and index.current() + 1 < index.max()
                index.select index.current() + 1

    elements =
        cache: (full) ->
            full.find(".flash", "flash")
            full.find(".timer", "timer")
            full.find(".transfer", "transfer")
            full.find(".transfer img", "source")
            full.find(".wrapper", "wrapper")
            full.find(".paparazzi", "paparazzi")
            full.find(".filters-list", "filters")

    canvases = 
        setup: ->
            # create a new canvas for drawing
            canvas = document.createElement "canvas"
            video = document.createElement "canvas"
            video.width = 720
            video.height = 540
            canvas.width = 360
            canvas.height = 270
            $(canvas).attr("style", "width: #{video.width}px; height: #{video.height}px;")
            ctx = canvas.getContext "2d"
            ctx.scale -1, 1
            ctx.translate -canvas.width, 0
            videoCtx = video.getContext "2d"
            videoCtx.scale 0.5, 0.5

    pub = 

        init: (selector) ->

            # start the camera ping/pong
            $.publish "/postman/deliver", [ null, "/camera/request" ]

            full = new kendo.View(selector, template)

            # set up canvases for receiving the video feed and applying effects
            canvases.setup()

            full.render().prepend(canvas)

            # find and cache the necessary elements
            elements.cache full

            # subscribe to external events an map them to internal functions
            subscribe pub

            draw()

        show: (item) ->

            return unless paused

            pub.select item

            paused = false

            full.container.kendoStop(true).kendoAnimate
                effects: "zoomIn fadeIn"
                show: true
                complete: ->
                    # show the record controls in the footer
                    $.publish "/bottom/update", [ "full" ]

        select: (item, temp) ->
            effect = item.filter
            unless temp
                full.el.filters.find("li").removeClass("selected").filter("[data-filter-id=#{item.id}]").addClass("selected")
            $.publish "/postman/deliver", [ item.tracks, "/tracking/enable" ]

        filter:
            click: (e) ->
                i = $(e.target).data("filter-index")
                index.saved = i
                index.select i
                # remove the selected class from any other filters
                # $(e.target).parent().children().removeClass("selected")
                # set this filter as selected
                # $(e.target).addClass("selected")
            mouseover: (e) ->
                index.preview $(e.target).data("filter-index")
            mouseout: (e) ->
                index.unpreview()
        photo: ->

            callback = ->
                $.publish "/bottom/update", [ "full" ]
                
            capture callback, index: 1, count: 1

        paparazzi: ->

            # build a gross callback tree and fling poo
            left = 4
            advance = ->
                full.el.wrapper.removeClass "paparazzi-#{left}"
                left -= 1
                full.el.wrapper.addClass "paparazzi-#{left}"

            callback = ->
                
                callback = ->

                    callback = ->
                        $.publish "/bottom/update", [ "full" ]
                        full.el.wrapper.removeClass "paparazzi-1"
                        full.el.paparazzi.addClass "hidden"
                    
                    advance()
                    capture callback, index: 3, count: 3

                advance()
                capture callback, index: 2, count: 3

            advance()
            capture callback, index: 1, count: 3
