define [
  'Kendo'
  'Glfx'
  'mylibs/camera/camera'
  'mylibs/bar/bottom'
  'mylibs/bar/top'
  'mylibs/popover/popover'
  'mylibs/full/full'
  'mylibs/postman/postman'
  'mylibs/utils/utils'
  'mylibs/gallery/gallery'
  'mylibs/gallery/details'
  'mylibs/events/events'
  'mylibs/file/filewrapper'
  'mylibs/about/about'
  'mylibs/confirm/confirm'
  'mylibs/assets/assets'
  'mylibs/effects/effects'
  'libs/record/record'
], (kendo, glfx, camera, bottom, top, popover, full, postman, utils, gallery, details, events, filewrapper, about, confirm, assets, effects, record ) ->
	
	pub = 
		    
		init: ->

			APP = window.APP = {}

			APP.full = full
			APP.filters = effects.data
			APP.gallery = gallery
			APP.about = about
			APP.confirm = confirm

			# bind document level events
			events.init()
			
			# fire up the postman!
			postman.init window.top
			
			# initialize the asset pipeline
			assets.init()
			
			$.subscribe('/camera/unsupported', ->
			    $('#pictures').append(intro)
			)

			$.publish "/postman/deliver", [ true, "/menu/enable" ]

			$.subscribe "/localization/response", (dict) ->

				console.log dict

				ready = ->
					# create the top and bottom bars
					APP.bottom = bottom.init(".bottom")
					APP.top = top.init(".top")
					APP.popover = popover.init("#gallery")

					# initialize the full screen capture mode
					full.init "#capture"

					# initialize gallery details view
					details.init "#details"

					# initialize the thumbnail gallery
					gallery.init "#thumbnails"

					# initialize the about view
					about.init "#about"

					# initialize the confirm window
					confirm.init "#confirm"

					# start up camera
					effects.init()
					full.show effects.data[0]

					# we are done loading the app. have the postman deliver that msg.
					$.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

					window.APP.app = new kendo.mobile.Application document.body, { platform: "android" }

				# initialize the camera
				camera.init "countdown", ready

			$.publish "/postman/deliver", [ null, "/localization/request" ]
