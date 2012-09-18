define [ 'mylibs/file/filewrapper' ] , (filewrapper) ->

    ###     Utils

    This file contains utility functions and normalizations. this used to contain more functions, but
    most have been moved into the extension

    ###

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
                for pair in (frames[i ... i + 2] for i in [0 .. frames.length - 2])
                    video.add pair[0].imageData, pair[1].time - pair[0].time

                blob = video.compile()
                frames = []
                
                name = new Date().getTime() + ".webm"

                blobUrl = window.URL.createObjectURL(blob)

                console.log blobUrl

                # save the recording
                filewrapper.save(name, blob)

                # hide the time
                $.publish "/bar/time/hide"

            framesDone = 0;

            for i in [0...frames.length]

                do (i) ->
                    
                    #imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
                    #videoData = new Uint8ClampedArray(frames[i].imageData.data)
                    #imageData.data.set(videoData)
                    bufferContext.putImageData frames[i].imageData, 0, 0

                    frames[i] = imageData: bufferCanvas.toDataURL('image/webp', 0.8), time: frames[i].time
                    ++framesDone
                    if framesDone == frames.length
                        transcode()