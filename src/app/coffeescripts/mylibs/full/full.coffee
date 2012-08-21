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

		# subscribe to the app level draw event
		$.subscribe "/camera/stream", ->

			if not paused

	            # get the 2d canvas context and draw the image
	            # this happens at the curent framerate
	            # ctx.drawImage(window.HTML5CAMERA.canvas, 0, 0, canvas.width, canvas.height)
	            
	            # increment the curent frame counter. this is used for animated effects
	            # like old movie and vhs. most effects simply ignore this
	            frame++

	 			# pass in the webgl canvas, the canvas that contains the 
	            # video drawn from the application canvas and the current frame.
	            preview.filter(webgl, window.HTML5CAMERA.canvas, frame)

	pub = 

		init: (selector) ->

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
			$wrapper = $("<div></div>")

			$container.append $wrapper

			# create a new webgl canvas
			webgl = fx.canvas()

			# add the double-click event listener which closes the preview
			$(webgl).dblclick ->
				
				$.publish("/previews/pause", [false])

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
					hide: "true"
				})

			# append the webgl canvas
			$wrapper.append(webgl)

			# subscribe to the show event
			$.subscribe "/full/show", (e) ->

				$.extend(preview, e)

				paused = false

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
				$wrapper.height $container.height() - 50

				# determine the width based on a 3:2 aspect ratio (.66 repeating)
				$wrapper.width (3 / 2) * $wrapper.height()

				$(webgl).width($wrapper.width())
				$(webgl).height("height", $wrapper.height())

				$container.kendoStop(true).kendoAnimate({
					effects: "zoomIn",
					show: "true"
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

			# subscribe to the capture image event
			$.subscribe "/capture/image", ->

				
				

			draw()
				
)