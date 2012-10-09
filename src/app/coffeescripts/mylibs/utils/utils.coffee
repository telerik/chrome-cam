define [ 'mylibs/file/filewrapper' ] , (filewrapper) ->

    ###     Utils

    This file contains utility functions and normalizations. this used to contain more functions, but
    most have been moved into the extension

    ###

    # the image data of each frame is put into this buffer canvas so we can call
    # toDataURL
    bufferCanvas = document.createElement("canvas")
    bufferCanvas.width = 720 / 2
    bufferCanvas.height = 480 / 2
    bufferContext = bufferCanvas.getContext("2d")

    pub = 

        # normalizes webkitRequestAnimationFrame
        getAnimationFrame: ->
            return window.requestAnimationFrame || window.webkitRequestAnimationFrame

        createVideo: (frames) ->

            deferred = $.Deferred()

            video = new Whammy.Video()
            
            # step through frames in pairs of two
            # this is so that each frame can be added with the appropriate duration,
            # since we know how long of a gap there is between frames
            for pair in (frames[i .. i + 1] for i in [0 .. frames.length - 2])
                bufferContext.putImageData pair[0].imageData, 0, 0
                video.add bufferCanvas.toDataURL('image/webp', 0.8), pair[1].time - pair[0].time

            blob = video.compile()
            
            name = new Date().getTime() + ".webm"

            # save the recording
            filewrapper.save(name, blob)

            reader = new FileReader()
            reader.onload = (e) ->
                deferred.resolve { url: e.target.result, name: name }
            reader.readAsDataURL(blob)

            deferred.promise()

        placeholder:
            image: ->
                "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="

        oppositeDirectionOf: (dir) ->
            switch dir
                when "left" then "right"
                when "right" then "left"
                when "up" then "down"
                when "down" then "up"