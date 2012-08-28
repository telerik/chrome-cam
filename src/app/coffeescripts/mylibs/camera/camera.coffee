define([
  'mylibs/preview/preview'
  'mylibs/utils/utils'
  'libs/face/track'
], (preview, utils, face) ->

    ###     Camera

    The camera module takes care of getting the users media and drawing it to a canvas.
    It also handles the coutdown that is intitiated

    ###

    # object level vars

    $counter = {}
    canvas = {}
    ctx = {}
    beep = document.createElement("audio")
    paused = false
    window.testing = false

    turnOn = (callback, testing) ->       

        track = {}

        # subscribe to the '/camera/update' event. this is published in a draw
        # loop at the extension level at the current framerate
        
        $.subscribe "/camera/update", (message) ->

            if not paused

                skip = false

                if window.testing
                    message.track = face.track canvas

                # create a new image data object
                imgData = ctx.getImageData 0, 0, canvas.width, canvas.height
                
                # convert the incoming message to a typed array
                videoData = new Uint8ClampedArray(message.image)
                
                # set the iamge data equal to the typed array
                imgData.data.set(videoData)

                # draw the image data to the canvas
                ctx.putImageData(imgData, 0, 0)

                $.publish "/camera/stream", [{ 
                    canvas: canvas, 
                    track: message.track
                }]

                skip = not skip

        # execute the callback that happens when the camera successfully turns on
        callback()

    countdown = ( num, callback ) ->
        
        # play the beep
        beep.play()

        # get the counters element 
        counters = $counter.find("span")
        
        # determine the current count position
        index = counters.length - num
        
        # countdown to 1 before executing the callback. fadeout numbers along the way.
        $(counters[index]).css("opacity", "1").animate( { opacity: .1 }, 1000, -> 
            if num > 1
                num--
                countdown( num, callback )
            else
                callback()
        )

    pub =
    	
    	init: (counter, callback) ->

            # initialize the face tracking module
            face.init 0, 0, 0, 0

            # set a reference to the countdown DOM object
            $counter = $("##{counter}")

            # buffer up the beep sound effect
            beep.src = "sounds/beep.mp3"
            beep.buffer = "auto"

            # create a blank canvas element and set it's size
            canvas = document.createElement("canvas")
            canvas.width = 720
            canvas.height = 480

            # create a blank video element
            video = document.createElement("video")
            video.width = 720
            video.height = 480

            # get the canvas context for drawing and reading
            ctx = canvas.getContext("2d")
    		
            # subscribe to the pause event
            $.subscribe "/camera/pause", (isPaused) ->
                paused = isPaused

            if window.testing

                draw = -> 
                    utils.getAnimationFrame()(draw)
                    update()

                update = ->

                    ctx.drawImage(video, 0, 0, video.width, video.height)
                    img = ctx.getImageData(0, 0, canvas.width, canvas.height)
                    buffer = img.data.buffe

                    $.publish "/camera/update", [{ image: img.data.buffer }]

                navigator.webkitGetUserMedia({ video: true }, (stream) ->

                    e = window.URL || window.webkitURL
                    video.src = if e then e.createObjectURL(stream) else stream
                    video.play()

                    draw()
                            
                , ->
                    console.error("Camera Failed")
                )

            turnOn(callback)
    		
            
            # listen for the '/camera/countdown message and respond to the event'
            $.subscribe("/camera/countdown", ( num, hollaback ) ->
                countdown(num, hollaback)
            )

)
