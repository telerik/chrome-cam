define([
  'libs/face/ccv'
  'libs/face/face'
], (assets) ->

    faces = []

    eyeFactor = .05

    timeStripsBuffer = []
    ghostBuffer = []

    draw = (canvas, element, effect) ->

        texture = canvas.texture(element)
        canvas.draw(texture)

        effect(element)

        canvas.update()
        texture.destroy()

    pub = 

        clearBuffer: ->

            timeStripsBuffer = []
            ghostBuffer = []

        init: ->

        data: [

                {

                    name: "Normal"
                    filter: (canvas, element) ->
                        effect = ->
                            canvas                            
                        draw(canvas, element, effect)

                }

                {
                    name: "Bulge"
                    filter: (canvas, element) ->
                        effect = -> 
                            canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, .65 
                        draw(canvas, element, effect)
                }

                {
                    name: "Pinch"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, -.65
                        draw(canvas, element, effect)
                }

                {
                    name: "Swirl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.swirl canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, 3
                        draw(canvas, element, effect)
                }

                {
                    name: "Dent"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.bulgePinch canvas.width / 2 , canvas.height / 2, canvas.width / 4, -.4
                        draw(canvas, element, effect)
                }

                {
                    name: "Zoom Blur"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.zoomBlur canvas.width / 2,  canvas.height / 2, 2, canvas.height / 5
                        draw(canvas, element, effect)
                }

                {
                    name: "Blockhead"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.blockhead canvas.width / 2,  canvas.height / 2, 200, 300, 1
                        draw(canvas, element, effect)
                }

                {
                    name: "Mirror Left"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.mirror 0
                        draw(canvas, element, effect)
                }

                {
                    name: "Mirror Bottom"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.mirror Math.PI * 1.5
                        draw(canvas, element, effect)
                }                

                {
                    name: "Mirror Tube"
                    filter: (canvas, element) ->
                        effect = ->
                            canvas.mirrorTube canvas.width / 2, canvas.height / 2, canvas.height / 4
                        draw(canvas, element, effect)
                }

                {
                    name: "Quad"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.quadRotate 0, 0, 0, 0
                        draw(canvas, element, effect)
                }

                {
                    name: "Sepia"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.sepia 120
                        draw(canvas, element, effect)
                }

                {
                    name: "VHS"
                    filter: (canvas, element, frame) -> 
                        effect = ->
                            canvas.vhs frame
                        draw(canvas, element, effect)
                }

                {
                    name: "Old Film"
                    filter: (canvas, element, frame) -> 
                        effect = ->
                            canvas.oldFilm frame
                        draw(canvas, element, effect)
                }

                {
                    name: "Hope"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.hopePoster()
                        draw(canvas, element, effect)
                }

                {
                    name: "Ghost"
                    filter: (canvas, element, frame) ->

                        effect = ->

                            createBuffers = (length) ->
                                while ghostBuffer.length < length
                                    ghostBuffer.push canvas.texture(element)

                            createBuffers(32)
                            ghostBuffer[frame++ % ghostBuffer.length].loadContentsOf(element)
                            canvas.matrixWarp([1, 0, 0, 1], false, true)
                            canvas.blend ghostBuffer[frame % ghostBuffer.length], .5
                            canvas.matrixWarp([-1, 0, 0, 1], false, true)

                        draw(canvas, element, effect)

                }

                {
                    name: "Kaleidoscope"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.kaleidoscope canvas.width / 2,  canvas.height / 2, 200, 0
                        draw(canvas, element, effect)
                }

                {
                    name: "Inverted"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.invert()
                        draw(canvas, element, effect)
                }

                {
                    name: "Comix"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.quadRotate 0, 0, 0, 0
                            canvas.denoise 50
                            canvas.ink .5
                        draw(canvas, element, effect)
                }


                {
                    name: "Color Half Tone"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.colorHalftone canvas.width / 2,  canvas.height / 2, .30, 3
                        draw(canvas, element, effect)
                }

                {
                    name: "Frogman"
                    filter: (canvas, element, frame, track) ->

                        if track.faces.length != 0
                            faces = track.faces

                        effect = (element) ->

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
                    name: "Chubby Bunny"
                    filter: (canvas, element, frame, stream) ->

                        if stream.faces.length != 0
                            faces = stream.faces

                        effect = (element) ->

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

                                eyeWidth = eyeFactor * element.width

                                canvas.bulgePinch (x + width / 2) - eyeWidth, (y + height / 3) + eyeWidth, eyeWidth * 2, .65 
                                canvas.bulgePinch (x + width / 2) + eyeWidth, (y + height / 3) + eyeWidth, eyeWidth * 2, .65 

                        draw(canvas, element, effect)
                }

                {
                    name: "Giraffe"
                    filter: (canvas, element, frame, stream) ->

                        if stream.faces.length != 0
                            faces = stream.faces

                        effect = (element) ->

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

                
                
        ]
            
)