define([
	'mylibs/postman/postman'
	'mylibs/utils/utils'
	'mylibs/file/file'
	'mylibs/intents/intents'
	'mylibs/notify/notify'
	'mylibs/assets/assets'
	'libs/face/track'
], (postman, utils, file, intents, notify, assets, face) ->
	
	'use strict'

	iframe = iframe = document.getElementById("iframe")
	canvas = document.getElementById("canvas")	
	ctx = canvas.getContext("2d")
	track = {}
	paused = false

	# skip frames for face detection. grasping at straws.
	skip = false
	skipBit = 0
	skipMax = 10

	draw = -> 

		# utils.getAnimationFrame()(draw)
		update()

	update = ->

		# the camera is paused when it isn't being used to increase app performance
		if not paused

			if skipBit == 0
				track = face.track video

			ctx.drawImage(video, 0, 0, video.width, video.height)
			img = ctx.getImageData(0, 0, canvas.width, canvas.height)
			buffer = img.data.buffer

			$.publish "/postman/deliver", [ image: img.data.buffer, track: track, "/camera/update", [ buffer ]]

			if skipBit < 4
				skipBit++
			else
				skipBit = 0

		setTimeout update, 1000 / 30

	hollaback = (stream) ->

		e = window.URL || window.webkitURL
		video = document.getElementById("video")
		video.src = if e then e.createObjectURL(stream) else stream
		video.play()

		draw()

	errback = ->
		console.log("Couldn't Get The Video");

	pub = 
		init: ->

			# initialize utils
			utils.init()

			# subscribe to the pause event
			$.subscribe "/camera/pause", (message) ->
				paused = message.paused

			# start the camera
			navigator.webkitGetUserMedia { video: true }, hollaback, errback

			iframe.src = "app/index.html"

			# cue up the postman!
			postman.init iframe.contentWindow

			#initialize notifications
			notify.init()

			# intialize intents
			intents.init()

			# get the files
			file.init()

			# send embeded assets down to the app
			# assets.init()

			# initialize the face tracking
			face.init 0, 0, 0, 0
)