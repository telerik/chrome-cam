define [
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

	# TODO: Move the settings to it's own file
	config =
		get: (key, fn) ->
			chrome.storage.local.get key, (storage) ->
				$.publish "/postman/deliver", [ storage[key], "/config/value/#{key}" ]
		set: (key, value) ->
			obj = {}
			obj[key] = value
			chrome.storage.local.set obj
		init: ->
			$.subscribe "/config/get", (key) ->
				config.get key
			$.subscribe "/config/set", (e) ->
				config.set e.key, e.value
			$.subscribe "/config/all", ->
				$.publish "/postman/deliver", [ config.values, "/config/values" ]

	# TODO: Move the context menu to it's own file
	menu = ->
		chrome.contextMenus.onClicked.addListener (info, tab) ->
			$.publish "/postman/deliver", [{}, "/menu/click/#{info.menuItemId}"]

		$.subscribe "/menu/enable", (isEnabled) ->
			menus = [
				"chrome-cam-about-menu"
				"chrome-cam-settings-menu"
			]
			for menu in menus
				chrome.contextMenus.update menu, enabled: isEnabled

	# TODO: Move the camera to it's own file
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

			$.subscribe "/camera/request", ->
				update()

			# start the camera
			navigator.webkitGetUserMedia { video: true }, hollaback, errback

			iframe.src = "app/index.html"

			# cue up the postman!
			postman.init iframe.contentWindow

			# TODO: move to own file
			thumbnailWorker = new Worker("chrome/javascripts/mylibs/workers/bitmapWorker.js")
			thumbnailWorker.onmessage = (e) ->
				$.publish "/postman/deliver", [e.data, "/preview/thumbnail/response/"]
				
			$.subscribe "/preview/thumbnail/request", (e) ->
				thumbnailWorker.postMessage
					width: e.data.width
					height: e.data.height
					data: e.data.data
					key: e.data.key

			$.subscribe "/tab/open", (url) ->
				chrome.tabs.create url: url

			#initialize notifications
			notify.init()

			# intialize intents
			intents.init()

			# get the files
			file.init()

			# initialize the asset pipeline
			assets.init()

			config.init()

			# initialize the face tracking
			face.init 0, 0, 0, 0

			# setup the context menu
			menu()
