define([
  'Kendo'
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'text!mylibs/full/views/full.html'
], (kendo, effects, utils, filewrapper, template) ->
	
	canvas = {}
	ctx = {}
	preview = {}
	paused = true
	frame = 0
	frames = []
	recording = false
	startTime = 0
	full = {}
	effect = {}

	# the main draw loop which renders the live video effects      
	draw = ->

		# subscribe to the app level draw event
		$.subscribe "/camera/stream", (stream) ->

			if not paused

	            # increment the curent frame counter. this is used for animated effects
	            # like old movie and vhs. most effects simply ignore this
	            frame++

	 			# pass in the webgl canvas, the canvas that contains the 
	            # video drawn from the application canvas and the current frame.
	            effect(canvas, stream.canvas, frame, stream.track)

	            # if we are recording, dump this canvas to a pixel array
	            if recording

	            	time = Date.now()

	            	# push the current frame onto the buffer
	            	frames.push imageData: ctx.getImageData(0, 0, 720, 480), time: Date.now()

	            	# update the time in the view
	            	el.container.find(".timer").first().html kendo.toString((Date.now() - startTime) / 1000, "0")

	flash = (callback) ->

		full.el.flash.show()	
		full.el.flash.kendoStop(true).kendoAnimate({
			effects: "fadeOut",
			duration: 1500,
			hide: true,
			complete: ->
				callback()
		})

	capture = (callback) ->

		image = canvas.toDataURL()

		# set the name of this image to the current time string
		name = new Date().getTime() + ".jpg"

		filewrapper.save(name, image).done ->
			# I may have it bouncing around too much, but I don't want the bar to
			# just respond to *all* file saves, or have this module know about
			# the bar's internals
			$.publish "/bar/preview/update", [ thumbnailURL: image ]
			$.publish "/gallery/add", [ type: 'jpg', name: name ]

		flash(callback)

	pub = 

		init: (selector) ->

			full = new kendo.View(selector, template)

			# create a new canvas for drawing
			canvas = document.createElement "canvas"
			canvas.width = 720
			canvas.height = 480
			ctx = canvas.getContext "2d"

			full.render().prepend(canvas)

			# find and cache the flash element
			full.find(".flash", "flash")

			# subscribe to external events an map them to internal
			# functions
			$.subscribe "/full/show", (item) ->
				pub.show(item)

			$.subscribe "/full/hide", ->		
				pub.hide()
				
			$.subscribe "/capture/photo", ->
				pub.photo()
			
			$.subscribe "/capture/paparazzi", ->
				pub.paparazzi()
				
			$.subscribe "/capture/video", ->
				pub.video()

			draw()

		show: (item) ->

			effect = item.filter

			paused = false

			# show the record controls in the footer
			$.publish "/bottom/update", [ "full" ]

			# get the height of the container minus the footer
			full.content.height(full.container.height()) - 50

			# determine the width based on a 3:2 aspect ratio (.66 repeating)
			# $content.width (3 / 2) * $content.height()
			full.content.width (3 / 2) * full.content.height()

			$(canvas).height(full.content.height())

			full.container.kendoStop(true).kendoAnimate {
				effects: "zoomIn fadeIn"
				show: true
			}

		hide: ->

			paused = true

			$.publish "/bottom/update", ["preview"]

			full.container.kendoStop(true).kendoAnimate {
				effects: "zoomOut fadeOut"
				hide: true,
				complete: ->
					$.publish "/preview/pause", [false]
			}

		photo: ->

			callback = ->
				$.publish "/bottom/update", [ "full" ]
				
			capture(callback)

		paparazzi: ->

			# build a gross callback tree and fling poo
			callback = ->
				
				callback = ->

					callback = ->
						$.publish "/bottom/update", [ "full" ]
					
					capture(callback)

				capture(callback)

			capture(callback)

		video: ->

			console.log "Recording..."

			frames = []
			
			startTime = Date.now()

			full.container.find(".timer").removeClass("hidden")

			setTimeout (-> 
				
				utils.createVideo frames
				console.log("Recording Done!")
				recording = false

				full.container.find(".timer").addClass("hidden")
				
				$.publish "/recording/done", [ "full" ]

			), 6000

			recording = true

				
)