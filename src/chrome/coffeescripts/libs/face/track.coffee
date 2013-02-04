define [
    'libs/face/ccv'
    'libs/face/face'
], () ->

    backCanvas = document.createElement "canvas"
    backContext = backCanvas.getContext "2d"

    ready = true

    pub =
        init: () ->
            backCanvas.width = 320
            backCanvas.height = 240

        track: (video, callback) ->
            return unless ready

            ready = false

            backContext.drawImage video, 0, 0, backCanvas.width, backCanvas.height

            options =
                canvas: ccv.grayscale(ccv.pre(backCanvas))
                cascade: cascade
                interval: 5
                min_neighbors: 1
                async: true
                worker: 1

            cb = ccv.detect_objects(options)
            cb (comp) ->
                track =
                    faces: comp
                    trackWidth: backCanvas.width

                callback track
                ready = true