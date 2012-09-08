define([
  'Kendo'
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'text!mylibs/full/views/full.html'
], (kendo, effects, utils, filewrapper, fullTemplate) ->
	
	canvas = {}
	ctx = {}
	preview = {}
	webgl = {}
	preview = {}
	paused = true
	frame = 0
	frames = []
	recording = false
	$flash = {}
	startTime = 0
	$container = {}

	# the main draw loop which renders the live video effects      
	draw = ->

		# subscribe to the app level draw event
		$.subscribe "/camera/stream", (stream) ->

			if not paused

	            # get the 2d canvas context and draw the image
	            # this happens at the curent framerate
	            # ctx.drawImage(window.HTML5CAMERA.canvas, 0, 0, canvas.width, canvas.height)
	            
	            # increment the curent frame counter. this is used for animated effects
	            # like old movie and vhs. most effects simply ignore this
	            frame++

	 			# pass in the webgl canvas, the canvas that contains the 
	            # video drawn from the application canvas and the current frame.
	            preview.filter(canvas, stream.canvas, frame, stream.track)

	            # if we are recording, dump this canvas to a pixel array
	            if recording

	            	time = Date.now()

	            	# push the current frame onto the buffer
	            	frames.push imageData: canvas.getPixelArray(), time: Date.now()

	            	# update the time in the view
	            	$.publish "/full/timer/update"

	flash = ->

		$flash.show()	
		$flash.kendoStop(true).kendoAnimate({
			effects: "fadeOut",
			duration: 1500,
			hide: true
		})

	pub = 

		init: (selector) ->

			# attach to the /capture/image function
			$.subscribe "/capture/photo", ->

				flash()

				image = canvas.toDataURL()

				# set the name of this image to the current time string
				name = new Date().getTime() + ".jpg"

				filewrapper.save(name, image).done ->
					# I may have it bouncing around too much, but I don't want the bar to
					# just respond to *all* file saves, or have this module know about
					# the bar's internals
					$.publish "/bar/preview/update", [ thumbnailURL: image ]
					$.publish "/bar/update", [ "full" ]

			$.subscribe "/capture/video", ->

				console.log "Recording..."

				frames = []

				recording = true
				
				startTime = Date.now()

				$container.find(".timer").removeClass("hidden")

				setTimeout (-> 
					
					utils.createVideo frames
					console.log("Recording Done!")
					recording = false

					$container.find(".timer").addClass("hidden")
					
					$.publish "/bar/update", [ "full" ]

				), 6000

			# setup the shrink function - this most likely belongs in a widget file
			kendo.fx.grow =
				setup: (element, options) ->
					$.extend({
						top: options.top
						left: options.left
						width: options.width
						height: options.height
				    }, options.properties)

			# get a reference to the container of this element with the selector
			$container = $(selector)

			# create a new canvas for drawing
			canvas = document.createElement "canvas"
			canvas.width = 720
			canvas.height = 480
			ctx = canvas.getContext "2d"

			# create a div to go inside the main content area
			$content = $(fullTemplate).appendTo($container)

			# get a reference to the flash
			$flash = $content.find ".flash"

			# create a new webgl canvas
			#  \webgl = fx.canvas()

			# add the double-click event listener which closes the preview
			$(canvas).dblclick ->
				
				# hide the controls in the bar
				$.publish "/bar/update", [ "preview" ]

				# pause the camera
				$.publish "/camera/pause", [ true ]

				# $container.kendoStop().kendoAnimate({
				# 	effects: "grow"
				# 	top: preview.canvas.offsetTop
				# 	left: preview.canvas.offsetLeft
				# 	width: preview.canvas.width
				# 	height: preview.canvas.height
				# 	complete: ->
				#  		$container.hide()
				#  })

				# $(webgl).kendoStop().kendoAnimate({
				# 	effects: "grow"
				# 	top: preview.canvas.offsetTop
				# 	left: preview.canvas.offsetLeft
				# 	width: preview.canvas.width
				# 	height: preview.canvas.height
				# })

				$container.kendoStop(true).kendoAnimate({
					effects: "zoomOut",
					hide: "true", 
					complete: ->

						# pause the full screen
						paused = true

						# unpause the camera
						$.publish "/camera/pause", [ false ]

						# unpause the previews
						$.publish "/previews/pause", [ false ]
				})

			# append the webgl canvas
			$content.prepend(canvas)

			# subscribe to the show event
			$.subscribe "/full/show", (e) ->

				# show the record controls in the footer
				$.publish "/bar/update", [ "full" ]

				$.extend(preview, e)

				# pause the camera
				$.publish "/camera/pause", [ true ]

				# y = preview.canvas.offsetTop
				# x = preview.canvas.offsetLeft

				# move the container to the x and y coordinates of the sending preview
				# $container.css "top", y
				# $container.css "left", x

				# get the height based on the aspect ratio of 4:3
				# fullWidth = $(document).width()
				# fullHeight = $(document).height()

				# $container.width(preview.canvas.width)
				# $container.height(preview.canvas.height)

				# get the height of the container minus the footer
				$content.height $container.height() - 50

				# determine the width based on a 3:2 aspect ratio (.66 repeating)
				$content.width (3 / 2) * $content.height()

				$(canvas).width($content.width())
				$(canvas).height("height", $content.height())

				$container.kendoStop(true).kendoAnimate({
					effects: "zoomIn",
					show: "true",
					complete: ->

						# unpause the camera
						$.publish "/camera/pause", [ false ]
				
						# unpause the full screen
						paused = false
				})

				# $container.kendoStop().kendoAnimate({
				# 	effects: "grow"	
				# 	top: 0
				# 	left: 0
				# 	width: fullWidth
				# 	height: fullHeight
				# })

				# $(webgl).kendoStop().kendoAnimate({
				# 	effects: "grow"	
				# 	width: 983
				# 	height: 655
				# 	top: 0
				# 	left: 0
				# })
	
				# $container.kendoStop().kendoAnimate { effects: "zoomIn fadeIn", show: true, duration: 200 }

			# subscribe to the flash event
			$.subscribe "/full/flash", ->
				
				flash()

			$.subscribe "/full/timer/update", ->
				$container.find(".timer").first().html kendo.toString((Date.now() - startTime) / 1000, "00.00")
			draw()
				
)