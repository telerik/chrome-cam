define [
    'CCV'
    'Face'
], (ccv) ->

    backCanvas = document.createElement "canvas"
    backContext = backCanvas.getContext "2d"
    cache = {}

    pub =

        init: (x, y, width, height) ->

            backCanvas.width = 120 * 1.2
            backCanvas.height = 90 * 1.2

            cache.comp = [{
                x: x
                y: y
                width: backCanvas.width
                height: backCanvas.height
            }]

        track: (video) ->

            track =
                faces: []
                trackWidth: backCanvas.width

            backContext.drawImage video, 0, 0, backCanvas.width, backCanvas.height

            comp = ccv.detect_objects cache.ccv = cache.ccv || {
                canvas: ccv.grayscale(backCanvas)
                cascade: cascade,
                interval: 5,
                min_neighbors: 1
            }

            if comp.length

                cache.comp = comp

            for i in cache.comp
                track.faces.push {
                    x: i.x
                    y: i.y
                    width: i.width
                    height: i.height
                }

            return track