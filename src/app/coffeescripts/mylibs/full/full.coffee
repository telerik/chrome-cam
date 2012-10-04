define [
  'Kendo'
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'mylibs/config/config'
  'text!mylibs/full/views/full.html'
  'text!mylibs/full/views/transfer.html'
], (kendo, effects, utils, filewrapper, config, template, transferImg) ->
    
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

        config.get "flash", (enabled) ->
            # TODO: use enabled value
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

        transfer = new kendo.View(full.content, transferImg, data)
        transfer.render()
        
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
            effect = effects.data[i].filter
            $.publish "/postman/deliver", [ effects.data[i].tracks, "/tracking/enable" ]

    subscribe = (pub) ->
        # subscribe to external events an map them to internal functions

        $.subscribe "/full/show", (item) ->
            pub.show(item)

        $.subscribe "/full/hide", ->
            pub.hide()
            
        $.subscribe "/capture/photo", ->
            pub.photo()
        
        $.subscribe "/capture/paparazzi", ->
            pub.paparazzi()

        $.subscribe "/countdown/paparazzi", ->
             full.el.paparazzi.removeClass "hidden"

        $.subscribe "/capture/video", ->
            pub.video()

        $.subscribe "/keyboard/esc", ->
            $.publish "/full/hide" unless paused

        $.subscribe "/keyboard/arrow", (dir) ->
            return if paused

            if dir is "left" and index.current() > 0
                index.select index.current() - 1
            if dir is "right" and index.current() + 1 < index.max()
                index.select index.current() + 1

    pub = 

        init: (selector) ->

            $.publish "/postman/deliver", [null, "/camera/request"]

            full = new kendo.View(selector, template)

            # create a new canvas for drawing
            canvas = document.createElement "canvas"
            video = document.createElement "canvas"
            video.width = 720
            video.height = 480
            canvas.width = 360
            canvas.height = 240
            $(canvas).attr("style", "width: 720px; height: 480px;")
            ctx = canvas.getContext "2d"
            videoCtx = video.getContext "2d"
            videoCtx.scale 0.5, 0.5

            full.render().prepend(canvas)

            # find and cache the flash element
            full.find(".flash", "flash")
            full.find(".timer", "timer")
            full.find(".transfer", "transfer")
            full.find(".transfer img", "source")
            full.find(".wrapper", "wrapper")
            full.find(".paparazzi", "paparazzi")
            full.find(".filters", "filters")

            subscribe pub

            draw()

        show: (item) ->

            return unless paused

            effect = item.filter

            paused = false

            full.el.transfer.height(full.content.height())
            full.el.transfer.width(full.content.width())

            full.container.kendoStop(true).kendoAnimate
                effects: "zoomIn fadeIn"
                show: true
                complete: ->
                    # show the record controls in the footer
                    $.publish "/bottom/update", [ "full" ]

        hide: ->

            paused = true

            $.publish "/bottom/update", ["preview"]

            full.container.kendoStop(true).kendoAnimate
                effects: "zoomOut fadeOut"
                hide: true,
                complete: ->
                    $.publish "/preview/pause", [false]
                    $.publish "/postman/deliver", [null, "/camera/request"]

        photo: ->

            callback = ->
                $.publish "/bottom/update", [ "full" ]
                
            capture(callback)

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
                    capture(callback)

                advance()
                capture(callback)

            advance()
            capture(callback)