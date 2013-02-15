define [
    'libs/glfx/glfx'
    'libs/face/ccv'
    'libs/face/face'
], () ->

    faces = []

    eyeFactor = .09

    timeStripsBuffer = []
    ghostBuffer = []

    webgl = fx.canvas()

    texture = null

    draw = (canvas, element, effect) ->
        ctx = canvas.getContext "2d"

        webgl.draw texture
        # canvas.draw(texture)

        effect webgl, element

        webgl.update()

        ctx.drawImage webgl, 0, 0, webgl.width, webgl.height

    simple = (canvas, element, x, y, width, height) ->

        ctx = canvas.getContext "2d"
        ctx.drawImage element, x, y, width, height

    pub =

        clearBuffer: ->

            timeStripsBuffer = []
            ghostBuffer = []

        init: ->

        advance: (element) ->
            if texture?
                texture.loadContentsOf element
            else
                texture = webgl.texture(element)

        data: [
            {
                id: "normal"
                name: "Normal"
                filter: (canvas, element) ->
                    effect = (canvas) ->
                        canvas
                    draw(canvas, element, effect)
            }

            {
                id: "andy"
                name: "Andy"
                filter: (canvas, element, frame) ->
                    effect = (canvas, element) ->
                        canvas.quadRotate 0, 0, 0, 0
                        canvas.popArt()
                    draw(canvas, element, effect)
            }

            {
                id: "blockhead"
                name: "Blockhead"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.blockhead canvas.width / 2,  canvas.height / 2, 200, 300, 1
                    draw(canvas, element, effect)
            }

            {
                id: "bulge"
                name: "Bulge"
                filter: (canvas, element) ->
                    effect = (canvas) ->
                        canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, .65
                    draw(canvas, element, effect)
            }

            {
                id: "colorHalfTone"
                name: "Color half tone"
                kind: "webgl"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.colorHalftone canvas.width / 2,  canvas.height / 2, .30, 3
                    draw(canvas, element, effect)
            }

            {
                id: "chubbyBunny"
                name: "Chubby bunny"
                tracks: true
                filter: (canvas, element, frame, stream) ->

                    if stream.faces.length != 0
                        faces = stream.faces

                    effect = (canvas, element) ->

                        # the stream object holds a face object which contains
                        # face tracking data about this paticular canvas. the face
                        # tracking data comes in at 120 x 80 so we need to crank it up
                        # to the appropriate size
                        factor = element.width / stream.trackWidth

                        # add the effect to each face we find
                        for face in faces

                            width = face.width * factor
                            height = face.height * factor
                            x = face.x * factor
                            y = face.y * factor

                            eyeWidth = eyeFactor * element.width * 0.6

                            canvas.bulgePinch (x + width / 2) - eyeWidth, (y + height / 3) + eyeWidth*1.3, eyeWidth * 2, .65
                            canvas.bulgePinch (x + width / 2) + eyeWidth, (y + height / 3) + eyeWidth*1.3, eyeWidth * 2, .65
                            canvas.bulgePinch (x + width / 2) - eyeWidth*2, (y + height / 3) + eyeWidth*1.9, eyeWidth * 2.25, .5
                            canvas.bulgePinch (x + width / 2) + eyeWidth*2, (y + height / 3) + eyeWidth*1.9, eyeWidth * 2.25, .5

                    draw(canvas, element, effect)
            }

            {
                id: "dent"
                name: "Dent"
                kind: "webgl"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.bulgePinch canvas.width / 2 , canvas.height / 2, canvas.width / 4, -.4
                    draw(canvas, element, effect)
            }

            {
                id: "flush"
                name: "Flush"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.mirrorTube canvas.width / 2, canvas.height / 2, canvas.height / 4
                    draw(canvas, element, effect)
            }

            {
                id: "frogman"
                name: "Frogman"
                tracks: true
                filter: (canvas, element, frame, track) ->

                    if track.faces.length != 0
                        faces = track.faces

                    effect = (canvas, element) ->

                        # the stream object holds a face object which contains
                        # face tracking data about this paticular canvas. the face
                        # tracking data comes in at 120 x 80 so we need to crank it up
                        # to the appropriate size
                        factor = element.width / track.trackWidth

                        # add the effect to each face we find
                        for face in faces

                            width = face.width * factor
                            height = face.height * factor
                            x = face.x * factor
                            y = face.y * factor

                            eyeWidth = eyeFactor * element.width

                            canvas.bulgePinch (x + width / 2) - eyeWidth, y + height / 3, eyeWidth * 2, .65
                            canvas.bulgePinch (x + width / 2) + eyeWidth, y + height / 3, eyeWidth * 2, .65

                    draw(canvas, element, effect)
            }

            {
                id: "ghost"
                name: "Ghost"
                filter: (canvas, element, frame) ->

                    effect = (canvas, element) ->

                        createBuffers = (length) ->
                            while ghostBuffer.length < length
                                ghostBuffer.push canvas.texture(element)

                        createBuffers(32)
                        ghostBuffer[frame++ % ghostBuffer.length].loadContentsOf(element)
                        #canvas.matrixWarp([1, 0, 0, 1], false, true)
                        canvas.blend ghostBuffer[frame % ghostBuffer.length], .5
                        #canvas.matrixWarp([-1, 0, 0, 1], false, true)

                    draw(canvas, element, effect)
            }

            {
                id: "giraffe"
                name: "Giraffe"
                tracks: true
                filter: (canvas, element, frame, stream) ->

                    if stream.faces.length != 0
                        faces = stream.faces

                    effect = (canvas, element) ->

                        # the stream object holds a face object which contains
                        # face tracking data about this paticular canvas. the face
                        # tracking data comes in at 120 x 80 so we need to crank it up
                        # to the appropriate size
                        factor = element.width / stream.trackWidth

                        # add the effect to each face we find
                        for face in faces

                            width = face.width * factor
                            height = face.height * factor
                            x = face.x * factor
                            y = face.y * factor

                        canvas.blockhead x, y + height + 25, 1, canvas.height / 2, 1

                    draw(canvas, element, effect)
            }

            {
                id: "inverted"
                name: "Inverted"
                kind: "webgl"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.invert()
                    draw(canvas, element, effect)
            }

            {
                id: "kaleidoscope"
                name: "Kaleidoscope"
                kind: "webgl"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.kaleidoscope canvas.width / 2,  canvas.height / 2, 120, 0
                    draw(canvas, element, effect)
            }

            {
                id: "mirrorLeft"
                name: "Mirror left"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.mirror 0
                    draw(canvas, element, effect)
            }

            {
                id: "oldFilm"
                name: "Old film"
                filter: (canvas, element, frame) ->
                    effect = (canvas, element) ->
                        canvas.oldFilm frame
                    draw(canvas, element, effect)
            }

            {
                id: "photocopy"
                name: "Photocopy"
                kind: "webgl"
                filter: (canvas, element, frame) ->
                    effect = (canvas, element) ->
                        canvas.photocopy .35, frame
                    draw(canvas, element, effect)
            }

            {
                id: "pinch"
                name: "Pinch"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, -.65
                    draw(canvas, element, effect)
            }

            {
                id: "pixelate"
                name: "Pixelate"
                tracks: true
                filter: (canvas, element, frame, stream) ->
                    effect = (canvas, element) ->
                        canvas.pixelate 2, 2, 6
                        canvas.flatColors()
                    draw(canvas, element, effect)
            }

            {
                id: "quad"
                name: "Quad"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.quadRotate 0, 0, 0, 0
                    draw(canvas, element, effect)
            }

            {
                id: "reflection"
                name: "Reflection"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.mirror Math.PI * 1.5
                    draw(canvas, element, effect)
            }

            {
                id: "sepia"
                name: "Sepia"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.sepia 120
                    draw(canvas, element, effect)
            }

            {
                id: "swirl"
                name: "Swirl"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.swirl canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, 3
                    draw(canvas, element, effect)
            }

            {
                id: "zoomBlur"
                name: "Zoom blur"
                filter: (canvas, element) ->
                    effect = (canvas, element) ->
                        canvas.zoomBlur canvas.width / 2,  canvas.height / 2, 2, canvas.height / 5
                    draw(canvas, element, effect)
            }
        ]