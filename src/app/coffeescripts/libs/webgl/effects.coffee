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
                    kind: "webgl"
                    filter: (canvas, element) ->
                        effect = ->
                            canvas                            
                        draw(canvas, element, effect)

                }

                {
                    name: "Bulge"
                    kind: "webgl"
                    filter: (canvas, element) ->
                        effect = -> 
                            canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, .65 
                        draw(canvas, element, effect)
                }

                {
                    name: "Frogman"
                    kind: "webgl"
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
                    kind: "webgl"
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
                    kind: "webgl"
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

                {
                    name: "Pinch"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, -.65
                        draw(canvas, element, effect)
                }

                {
                    name: "Dent"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, -.2
                        draw(canvas, element, effect)
                }

                {
                    name: "Swirl"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.swirl canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, 3
                        draw(canvas, element, effect)
                }

                {
                    name: "Zoom Blur"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.zoomBlur canvas.width / 2,  canvas.height / 2, 2, canvas.height / 5
                        draw(canvas, element, effect)
                }

                {
                    name: "Blockhead"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.blockhead canvas.width / 2,  canvas.height / 2, 200, 300, 1
                        draw(canvas, element, effect)
                }

                {
                    name: "Mirror Left"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.mirror 0
                        draw(canvas, element, effect)
                }

                {
                    name: "Mirror Pinch (Evil)"
                    kind: "webgl"
                    filter: (canvas, element) ->
                        effect = -> 
                            canvas.bulgePinch canvas.width / 2,  canvas.height / 2, (canvas.width / 2) / 2, -.65 
                            canvas.mirror 0            
                        draw(canvas, element, effect)
                }

                {
                    name: "Mirror Top"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.mirror Math.PI * .5
                        draw(canvas, element, effect)
                }

                {
                    name: "Mirror Bottom"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.mirror Math.PI * 1.5
                        draw(canvas, element, effect)
                }                

                {
                    name: "Mirror Tube"
                    kind: "webgl"
                    filter: (canvas, element) ->
                        effect = ->
                            canvas.mirrorTube canvas.width / 2, canvas.height / 2, canvas.height / 4
                        draw(canvas, element, effect)
                }

                {
                    name: "Quad"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.quadRotate 0, 0, 0, 0
                        draw(canvas, element, effect)
                }

                {               
                    name: "Quad Color"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.quadColor [ 1, .2, .1 ], [ 0, .8, 0 ], [ .25, .5, 1 ], [ .8, .8, .8 ]
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
                    name: "I Dont' Know"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.quadRotate 0, 1, 3, 2
                            canvas.quadRotate 2, 3, 1, 0
                            #canvas.quadColor [ 1, .2, .1 ], [ 0, .8, 0 ], [ .25, .5, 1 ], [ .8, .8, .8 ]
                        draw(canvas, element, effect) 
                }

                {
                    name: "Sketch Book"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                           canvas.edgeWork(2)
                           canvas.sepia()

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
                    name: "Pixelate"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.pixelate canvas.width / 2,  canvas.height / 2, 10
                        draw(canvas, element, effect)
                }    

                {
                    name: "Hope Poster"
                    kind: "webgl"
                    filter: (canvas, element) -> 
                        effect = ->
                            canvas.hopePoster()
                        draw(canvas, element, effect)
                }

                {
                    name: "Photocopy"
                    kind: "webgl"
                    filter: (canvas, element, frame) -> 
                        effect = ->
                            canvas.photocopy .5, frame
                        draw(canvas, element, effect)
                }

                {
                    name: "Old Film"
                    kind: "webgl"
                    filter: (canvas, element, frame) -> 
                        effect = ->
                            canvas.oldFilm frame
                        draw(canvas, element, effect)
                }

                {
                    name: "VHS"
                    kind: "webgl"
                    filter: (canvas, element, frame) -> 
                        effect = ->
                            canvas.vhs frame
                        draw(canvas, element, effect)
                }

                {
                    name: "Time Strips"
                    kind: "webgl"
                    filter: (canvas, element, frame) ->

                        effect = ->

                            createBuffers = (length) ->
                                while timeStripsBuffer.length < length
                                    timeStripsBuffer.push canvas.texture(element)

                            createBuffers(32)
                            timeStripsBuffer[frame++ % timeStripsBuffer.length].loadContentsOf(element)
                            canvas.timeStrips(timeStripsBuffer, frame)
                            canvas.matrixWarp([-1, 0, 0, 1], false, true)

                        draw(canvas, element, effect)

                }

                {
                    name: "Your Ghost"
                    kind: "webgl"
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
                    name: "Chromed"
                    kind: "webgl"
                    filter: (canvas, element, frame) -> 
                        effect = ->
                            canvas.chromeLogo canvas.width / 2, canvas.height / 2, frame, canvas.height / 2.5
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
                
        ]
            
)