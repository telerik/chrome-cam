define([
  'mylibs/utils/utils'
  'libs/webgl/glfx'
], (utils) ->
	
	canvas = {}
	ctx = {}
	preview = {}
	webgl = {}
	preview = {}
	paused = true
	frame = 0

	# the main draw loop which renders the live video effects      
	draw = ->

        if not paused

            # get the 2d canvas context and draw the image
            # this happens at the curent framerate
            ctx.drawImage(window.HTML5CAMERA.canvas, 0, 0, canvas.width, canvas.height)
            
            # increment the curent frame counter. this is used for animated effects
            # like old movie and vhs. most effects simply ignore this
            frame++

 			# pass in the webgl canvas, the canvas that contains the 
            # video drawn from the application canvas and the current frame.
            preview.filter(webgl, canvas, frame)

        # LOOP!
        utils.getAnimationFrame()(draw)

	pub = 

		init: (selector) ->

			# get a reference to the container of this element with the selector
			$container = $(selector)

			# create a new canvas for drawing
			canvas = document.createElement "canvas"
			ctx = canvas.getContext "2d"

			# set the width and height of the canvas to the container dimensions
			canvas.width = $container.width()
			canvas.height = $container.height()

			# create a new webgl canvas
			webgl = fx.canvas()

			# subscribe to the show event
			$.subscribe "/full/show", (e) ->

				$container.kendoStop().kendoAnimate { effects: "zoomIn fadeIn", show: true, duration: 1000, complete: ->
					paused = false
				}

			# subscribe to the hide event
			$.subscribe "full/hide", ->

				$container.kendoStop(true).kendoAnimate { effects: "zoomOut fadeOut", hide: true, duration: 500, complete: ->
					paused = true
				}

			draw()
				
)