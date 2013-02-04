define [
    'mylibs/postman/postman'
    'mylibs/utils/utils'
    'mylibs/file/file'
    'mylibs/localization/localization'
    'libs/face/track'
    'mylibs/effects/effects'
], (postman, utils, file, localization, face, effects) ->
    'use strict'

    iframe = iframe = document.getElementById("iframe")
    canvas = document.getElementById("canvas")
    ctx = canvas.getContext("2d")
    track = {}
    paused = false

    frame = 0

    # skip frames for face detection. grasping at straws.
    skip = false
    skipBit = 0
    skipMax = 10

    supported = true

    effect = effects.data[0]

    # TODO: Move the context menu to its own file
    menu = ->
        chrome.contextMenus.onClicked.addListener (info, tab) ->
            $.publish "/postman/deliver", [{}, "/menu/click/#{info.menuItemId}"]

        $.subscribe "/menu/enable", (isEnabled) ->
            menus = [ "chrome-cam-about-menu" ]
            for menu in menus
                chrome.contextMenus.update menu, enabled: isEnabled

    # TODO: Move the camera to its own file
    draw = ->
        update()
        window.requestAnimationFrame draw

    update = ->
        # the camera is paused when it isn't being used to increase app performance
        return if paused

        #if skipBit == 0
        #   track = face.track video

        ctx.drawImage video, 0, 0, video.width, video.height

        # increment the curent frame counter. this is used for animated effects
        # like old movie and vhs. most effects simply ignore this
        frame++

        # pass in the webgl canvas, the canvas that contains the
        # video drawn from the application canvas and the current frame.
        fakeTrackingInfo =
            faces: []
        effects.advance canvas
        effect.filter canvas, canvas, frame, fakeTrackingInfo

        #if skipBit < 4
        #   skipBit++
        #else
        #   skipBit = 0

    capture = ->
        image = canvas.toDataURL("image/jpeg", 1.0)
        name = new Date().getTime()

        # set the name of this image to the current time string
        file = { type: "jpg", name: "#{name}.jpg", file: image }

        $.publish "/file/save", [file]
        saveFinished = $.subscribe "/file/saved/#{file.name}", ->
            $.unsubscribe saveFinished
            $.publish "/postman/deliver", [ [file], "/captured/image" ]

    hollaback = (stream) ->
        video = document.getElementById("video")
        video.src = window.URL.createObjectURL(stream)
        video.play()

        window.requestAnimationFrame draw

    errback = ->
        update = ->
            paused = true
            $.publish "/postman/deliver", [ {}, "/camera/unsupported" ]

    pub =
        init: ->
            # initialize utils
            utils.init()

            # subscribe to the pause event
            $.subscribe "/camera/pause", (message) ->
                paused = message.paused

            iframe.src = "app/index.html"

            # cue up the postman!
            postman.init iframe.contentWindow

            # start the camera
            navigator.webkitGetUserMedia { video: true }, hollaback, errback

            # get the localization dictionary from the app
            $.subscribe "/localization/request", ->
                $.publish "/postman/deliver", [ localization, "/localization/response" ]

            $.subscribe "/effects/request", ->
                filters = ( id: e.id, name: e.name, tracks: !!e.tracks for e in effects.data )
                $.publish "/postman/deliver", [ filters, "/effects/response" ]

            $.subscribe "/effects/select", (id) ->
                effect = e for e in effects.data when e.id is id

            $.subscribe "/window/close", ->
                window.close()

            $.subscribe "/camera/capture", capture

            $.subscribe "/camera/pause", (message) ->
                if message.paused
                    $(canvas).hide()
                else
                    $(canvas).show()

            # get the files
            file.init()

            #effects.init()
            #effect.name = APP.localization[effect.id] for effect in effects.data

            # initialize the face tracking
            face.init 0, 0, 0, 0

            # setup the context menu
            menu()

            # this ensures that keyboard shortcut works without manually focusing the iframe
            $(iframe).focus()
