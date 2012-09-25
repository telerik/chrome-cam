define([
  'Kendo'
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'mylibs/config/config'
  'text!mylibs/full/views/full.html'
  'text!mylibs/full/views/transfer.html'
], (kendo, effects, utils, filewrapper, config, template, transferImg) ->
	SECONDS_TO_RECORD = 6

	canvas = {}
	ctx = {}
	video = {}
	videoCtx = {}
	preview = {}
	paused = true
	frame = 0
	frames = []
	recording = false
	startTime = 0
	full = {}
	transfer = {}
	effect = {}

	scaleCanvas = {}

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
	            	# scale the video down to 360 x 240
	            	videoCtx.drawImage canvas, 0, 0
	            	frames.push imageData: videoCtx.getImageData(0, 0, video.width, video.height), time: time

	            	# update the time in the view
	            	secondsRecorded = (Date.now() - startTime) / 1000
	            	remaining = Math.max(0, SECONDS_TO_RECORD - secondsRecorded)
	            	full.el.timer.first().html kendo.toString(remaining, "0")

	flash = (callback, file) ->

		config.get "flash", (enabled) ->
			# TODO: use enabled value
			full.el.flash.show()

			transfer.content.kendoStop().kendoAnimate 
				effects: "transfer",  
				target: $("#destination"), 
				duration: 1000, 
				ease: "ease-in",
				complete: ->
					$.publish "/bottom/thumbnail", [file]
					transfer.destroy()
					transfer = {}

					callback()

			full.el.flash.hide()


	capture = (callback) ->

		image = canvas.toDataURL("image/jpeg", 1.0)
		name = new Date().getTime()

		data = { src: image, height: full.content.height(), width: full.content.width() }

		transfer = new kendo.View(full.content, transferImg, data)
		transfer.render()
		
		transfer.find("img").load ->

			# set the name of this image to the current time string
			
			file = { type: "jpg", name: "#{name}.jpg", file: image }

			filewrapper.save(file.name, image)
				# I may have it bouncing around too much, but I don't want the bar to
				# just respond to *all* file saves, or have this module know about
				# the bar's internals
			$.publish "/gallery/add", [file]

			flash(callback, file)

	pub = 

		init: (selector) ->

			full = new kendo.View(selector, template)

			# create a new canvas for drawing
			canvas = document.createElement "canvas"
			video = document.createElement "canvas"
			video.width = 360
			video.height = 240
			canvas.width = 720
			canvas.height = 480
			ctx = canvas.getContext "2d"
			videoCtx = video.getContext "2d"
			videoCtx.scale 0.5, 0.5

			full.render().prepend(canvas)

			# find and cache the flash element
			full.find(".flash", "flash")
			full.find(".timer", "timer")
			full.find(".transfer", "transfer")
			full.find(".transfer img", "source")

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

			# get the height of the container minus the footer
			full.content.height(full.container.height()) - 50
			full.el.transfer.height(full.content.height())

			# determine the width based on a 3:2 aspect ratio (.66 repeating)
			# $content.width (3 / 2) * $content.height()
			full.content.width (3 / 2) * full.content.height()
			full.el.transfer.width(full.content.width())

			$(canvas).height(full.content.height())

			full.container.kendoStop(true).kendoAnimate {
				effects: "zoomIn fadeIn"
				show: true
				complete: ->
					# show the record controls in the footer
					$.publish "/bottom/update", [ "full" ]
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
			# TODO: make it stop recording early instead?
			return if recording
			recording = true

			console.log "Recording..."

			frames = []
			
			startTime = Date.now()

			full.container.find(".timer").removeClass("hidden")

			save = ->

				utils.createVideo(frames).done (result) ->

					console.log("Recording Done!")

					frames = []

					full.container.find(".timer").addClass("hidden")
					
					image = canvas.toDataURL()

					file = { type: "webm", name: result.name, file: result.url }
					data = { src: image, height: full.content.height(), width: full.content.width() }
					
					transfer = new kendo.View(full.content, transferImg, data)
					transfer.render()

					transfer.find("img").load ->	
						
						transfer.content.kendoStop().kendoAnimate 
							effects: "transfer",  
							target: $("#destination"), 
							duration: 1000, 
							ease: "ease-in",
							complete: ->
								$.publish "/bottom/thumbnail", [file]
								$.publish "/gallery/add", [file]
								transfer.destroy()
								transfer = {}

					$.publish "/bottom/update", ["full"]

			done = ->
				recording = false
				$.publish "/bottom/update", ["processing"]

				setTimeout save, 0

			setTimeout done, SECONDS_TO_RECORD * 1000
)