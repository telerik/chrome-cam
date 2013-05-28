define [
    'face/track'
    'effects/effects'
    'transfer/transfer'
    'localization/localization'
], (face, effects, transfer, localization) ->
    'use strict'

    canvas = document.getElementById("canvas")
    ctx = canvas.getContext("2d")
    track = { faces: [] }
    video = null
    paused = false

    wrapper = $(".wrapper")
    paparazzi = $(".paparazzi", wrapper)

    frame = 0
    frequency = 8
    faceTrackingEnabled = true
    unsupported = false

    supported = true

    appReady = $.Deferred()

    effect = effects.data[0]

    draw = ->
        update() unless paused
        window.requestAnimationFrame draw

    update = ->
        # the camera is paused when it isn't being used to increase app performance
        ctx.drawImage video, 0, 0, canvas.width, canvas.height

        if faceTrackingEnabled and effect.tracks and frame % frequency == 0
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
                    wrapper.removeClass "paparazzi-3"
                    paparazzi.addClass "hidden"
                ), 250
            else
                wrapper.addClass "paparazzi-" + (progress.index + 2)

            wrapper.removeClass "paparazzi-" + (progress.index + 1)

    capture = (progress) ->
        callback = ->
            paparazziUpdate progress

        flash(callback)

        image = webgl.toDataURL("image/jpeg", 1.0)
        name = new Date().getTime()

        # set the name of this image to the current time string
        file = { type: "jpg", name: "#{name}.jpg", file: image }

        animate file, progress

        $.publish "/file/save", [file]
        saveFinished = $.subscribe "/file/saved/#{file.name}", ->
            $.unsubscribe saveFinished
            $.publish "/postman/deliver", [ file, "/captured/image" ]

    flash = (callback) ->
        div = $("#flash")
        fx = kendo.fx(div)
        anim = fx.fadeIn().play().done(-> fx.fadeOut().play().done(callback))

    animate = (file, progress) ->

        callback = ->
            $.publish "/postman/deliver", [ file, "/bottom/thumbnail" ]
            faceTrackingEnabled = true

        if progress.index == 0
            transfer.setup()

        transfer.add file, progress

        if progress.index == progress.count-1
            faceTrackingEnabled = false
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

        unsupported = true
        $.when(appReady).then ->
            update()

    pause = (message) ->
        return unless paused != message.paused and not unsupported

        paused = message.paused
        wrapper.toggle not paused
        effects.clearBuffer() if paused

    prepare = (mode) ->
        if mode == "paparazzi"
            paparazzi.removeClass "hidden"
            wrapper.addClass "paparazzi-1"

    pub =
        cleanup: ->
            video.pause()
            video.src = ""
            stream.stop()

        init: ->
            appReady.promise()

            $.subscribe "/app/ready", -> appReady.resolve()

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

            $.subscribe "/camera/capture/prepare", prepare

            # initialize the face tracking
            face.init 0, 0, 0, 0

            # HACK: This should be done some where else.
            effects.init()
            effect.name = localization[effect.id] for effect in effects.data