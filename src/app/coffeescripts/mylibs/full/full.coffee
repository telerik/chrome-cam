define([
  'mylibs/utils/utils'
  'text!mylibs/full/views/full.html'
  'libs/webgl/glfx'
], (utils, fullTemplate) ->
	
	canvas = {}
	ctx = {}
	preview = {}
	webgl = {}
	preview = {}
	paused = true
	frame = 0
	frames = []
	record = false
	recordStart = 0
	VIDEO_MAX = 6

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
	            preview.filter(webgl, stream.canvas, frame, stream.track)

	            # check if we're recording. if so, pop this canvas to the frame buffer
	            if record

	            	# check the video length. we can only do 6 seconds
	            	length = (Date.now() - recordStart) / 1000
	
	            	# take the current webgl canvas an extract a webp image.
	            	# push that image into an array that we can stitch together
	            	# to make the webm video
		            frames.push webgl.toDataURL('image/webp', 1)

		            if length > VIDEO_MAX

		            	record = false

		            	webmBlob = Whammy.fromImageArray(frames, 1000 / 60)
		            	url = window.URL.createObjectURL(webmBlob)
		            	link = $("<a href='#{url}'>Download</a>")
		            	console.log link

	pub = 

		init: (selector) ->

			# attach to the /capture/image function
			$.subscribe "/capture/image", ->

				image = webgl.toDataURL()

				# set the name of this image to the current time string
				name = new Date().getTime() + ".jpg"

				# we'll respond after the image finishes saving
				token = $.subscribe "/file/saved/#{name}", ->
					# I may have it bouncing around too much, but I don't want the bar to
					# just respond to *all* file saves, or have this module know about
					# the bar's internals
					$.publish "/bar/preview/update", [ thumbnailURL: image ]
					$.unsubscribe token

				# save the image to the file system. this is up to the extension
				# to handle
				$.publish "/postman/deliver", [  name: name, image: image, "/file/save" ]

			$.subscribe "/capture/video", ->

  				frames = []
  				recordStart = Date.now()
  				record = true

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
			ctx = canvas.getContext "2d"

			# create a div to go inside the main content area
			$content = $(fullTemplate).appendTo($container)

			# get a reference to the flash
			$flash = $content.find ".flash"

			# create a new webgl canvas
			webgl = fx.canvas()

			# add the double-click event listener which closes the preview
			$(webgl).dblclick ->
				
				# hide the controls in the bar
				$.publish "/bar/capture/hide"

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
			$content.prepend(webgl)

			# subscribe to the show event
			$.subscribe "/full/show", (e) ->

				# show the record controls in the footer
				$.publish "/bar/capture/show"

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

				$(webgl).width($content.width())
				$(webgl).height("height", $content.height())

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
				
				$flash.show()	
				$flash.kendoStop(true).kendoAnimate({
					effects: "fadeOut",
					duration: 2000,
					hide: true
				})

			draw()
				
)