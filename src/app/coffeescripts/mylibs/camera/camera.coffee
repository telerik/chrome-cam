define [
  'mylibs/utils/utils'
  'libs/face/track'
], (utils, face) ->

    ###     Camera

    The camera module takes care of getting the users media and drawing it to a canvas.
    It also handles the coutdown that is intitiated

    ###

    # object level vars

    canvas = {}
    ctx = {}
    paused = false

    # turns on the camera by causing it to listen for the incoming stream
    turnOn = (callback, testing) ->

        track = {}

        # subscribe to the '/camera/update' event. this is published in a draw
        # loop at the extension level at the current framerate
        
        $.subscribe "/camera/update", (message) ->

            # if the camera isn't paused
            if not paused

                # create a new image data object
                imgData = ctx.getImageData 0, 0, canvas.width, canvas.height
                
                # convert the incoming message to a typed array
                videoData = new Uint8ClampedArray(message.image)
                
                # set the iamge data equal to the typed array
                imgData.data.set(videoData)

                # draw the image data to the canvas
                ctx.putImageData(imgData, 0, 0)

                # publish the camera stream out to the rest of the app
                $.publish "/camera/stream", [{ canvas: canvas, track: message.track }]

        # execute the callback that happens when the camera successfully turns on
        callback()

    pub =
        init: (counter, callback) ->

            # create a blank canvas element and set it's size
            canvas = document.createElement("canvas")
            canvas.width = 360
            canvas.height = 270

            # get the canvas context for drawing and reading
            ctx = canvas.getContext("2d")

            # subscribe to the pause event
            $.subscribe "/camera/pause", (isPaused) ->
                paused = isPaused

            turnOn(callback)
