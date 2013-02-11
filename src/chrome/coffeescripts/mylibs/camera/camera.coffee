define [
    'libs/face/track'
    'mylibs/effects/effects'
    'mylibs/transfer/transfer'
], (face, effects, transfer) ->
    'use strict'

    canvas = document.getElementById("canvas")
    ctx = canvas.getContext("2d")
    track = { faces: [] }
    video = null
    paused = false

    wrapper = $(".wrapper")
    paparazzi = $(".paparazzi", wrapper)

    frame = 0

    supported = true

    effect = effects.data[0]

    draw = ->
        update() unless paused
        window.requestAnimationFrame draw

    update = ->
        # the camera is paused when it isn't being used to increase app performance
        ctx.drawImage video, canvas.width, 0, -canvas.width, canvas.height

        if effect.tracks and frame % 4 == 0
           track = face.track canvas

        # increment the curent frame counter. this is used for animated effects
        # like old movie and vhs. most effects simply ignore this
        frame++

        # pass in the webgl canvas, the canvas that contains the
        # video drawn from the application canvas and the current frame.
        effects.advance canvas
        effect.filter canvas, canvas, frame, track

    paparazziUpdate = (progress) ->
        if progress.count > 1
            if progress.index == 0
                paparazzi.removeClass "hidden"
            # HACK: this should be refactored if time permits
            if progress.index == progress.count - 1
                setTimeout (->
                    wrapper.removeClass "paparazzi-1"
                    paparazzi.addClass "hidden"
                ), 250

            wrapper.removeClass "paparazzi-" + (1 + progress.count - progress.index)
            wrapper.addClass "paparazzi-" + (progress.count - progress.index)

    capture = (progress) ->
        flash()

        paparazziUpdate progress

        image = canvas.toDataURL("image/jpeg", 1.0)
        name = new Date().getTime()

        #flashCallback = ->
        #    transfer.add file, progress

        #    callback = ->
        #        $.publish "/postman/deliver", [ file, "/bottom/thumbnail" ]

        #    if progress.index == progress.count - 1
        #        setTimeout (->
        #            transfer.run callback
        #        ), 200

        #setTimeout flashCallback, 1

        # set the name of this image to the current time string
        file = { type: "jpg", name: "#{name}.jpg", file: image }

        animate file, progress

        $.publish "/file/save", [file]
        saveFinished = $.subscribe "/file/saved/#{file.name}", ->
            $.unsubscribe saveFinished
            $.publish "/postman/deliver", [ file, "/captured/image" ]

    flash = ->
        div = $("#flash")
        fx = kendo.fx(div)
        anim = fx.fadeIn().play().done(-> fx.fadeOut().play().done())

    animate = (file, progress) ->

        callback = ->
            $.publish "/postman/deliver", [ file, "/bottom/thumbnail" ]

        if progress.index == 0
            transfer.setup()

        transfer.add file, progress

        if progress.index == progress.count-1
            setTimeout (->
                transfer.run callback
            ), 200

    hollaback = (stream) ->
        window.stream = stream
        video = document.getElementById("video")
        video.src = window.URL.createObjectURL(stream)
        video.play()

        window.requestAnimationFrame draw

    errback = ->
        update = ->
            wrapper.hide()
            paused = true
            $.publish "/postman/deliver", [ {}, "/camera/unsupported" ]

    pause = (message) ->
        return unless paused != message.paused

        paused = message.paused
        wrapper.toggle not paused

    pub =
        cleanup: ->
            video.pause()
            video.src = ""
            stream.stop()

        init: ->
            transfer.init()

            # start the camera
            navigator.webkitGetUserMedia { video: true }, hollaback, errback

            $.subscribe "/camera/capture", capture

            # subscribe to the pause event
            $.subscribe "/camera/pause", pause

            # subscribe to the explicit update
            $.subscribe "/camera/update", ->
                update()
                $.publish "/postman/deliver", [ null, "/camera/updated" ]

            # TODO: Move this into effects
            $.subscribe "/effects/request", ->
                filters = ( id: e.id, name: e.name for e in effects.data )
                $.publish "/postman/deliver", [ filters, "/effects/response" ]

            $.subscribe "/camera/effect", (id) ->
                effect = e for e in effects.data when e.id is id

            $.subscribe "/camera/snapshot/request", ->
                image = canvas.toDataURL("image/jpeg", 1.0)

                $.publish "/postman/deliver", [ image, "/camera/snapshot/response" ]

            # initialize the face tracking
            face.init 0, 0, 0, 0