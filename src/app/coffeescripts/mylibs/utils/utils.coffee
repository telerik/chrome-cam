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
            return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || (callback, element) ->
                return window.setTimeout(callback, 1000 / 60)

        createVideo: (frames) ->

            transcode = ->
                video = new Whammy.Video()
                
                # step through frames in pairs of two
                # this is so that each frame can be added with the appropriate duration,
                # since we know how long of a gap there is between frames
                for pair in (frames[i .. i + 1] for i in [0 .. frames.length - 2])
                    # at this point, imageData is really a data URL
                    video.add pair[0].imageData, pair[1].time - pair[0].time

                blob = video.compile()
                
                name = new Date().getTime() + ".webm"

                blobUrl = window.URL.createObjectURL(blob)

                console.log blobUrl

                # save the recording
                filewrapper.save(name, blob)

                # hide the time
                $.publish "/bar/time/hide"

            for i in [0...frames.length]
                bufferContext.putImageData frames[i].imageData, 0, 0
                frames[i] = imageData: bufferCanvas.toDataURL('image/webp', 0.8), time: frames[i].time

            transcode()