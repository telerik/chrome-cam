do ->

    self.addEventListener "message", (e)->
        frames = e.data

    # createVideo = ->

        # transcode = ->

        importScripts("../libs/record/whammy.min.js")

        video = new Whammy.Video()
        for pair in (frames[i ... i + 2] for i in [0 .. frames.length - 2])
            video.add pair[0].imageData, pair[1].time - pair[0].time

        blob = video.compile()
        frames = []
        
        name = new Date().getTime() + ".webm"

        worker.postMessage("done!")

        # canvas = document.createElement("canvas")
        # canvas.width = 720
        # canvas.height = 480
        # ctx = canvas.getContext("2d")

        # framesDone = 0;

        # for i in [0...frames.length]

        #     do (i) ->
                
        #         imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
        #         videoData = new Uint8ClampedArray(frames[i].imageData.data)
        #         imageData.data.set(videoData)
        #         ctx.putImageData imageData, 0, 0
        #         frames[i] = imageData: canvas.toDataURL('image/webp', 1), time: frames[i].time
        #         ++framesDone
        #         if framesDone == frames.length
        #             transcode()