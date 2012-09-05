define([
  'Kendo'
  'Glfx'
  'mylibs/camera/camera'
  'mylibs/bar/bar'
  'mylibs/preview/preview'
  'mylibs/full/full'
  'mylibs/postman/postman'
  'mylibs/utils/utils'
  'mylibs/gallery/gallery'
  'mylibs/events/events'
  'libs/record/record'
  'text!intro.html'
], (kendo, glfx, camera, bar, preview, full, postman, utils, gallery, events, record, intro) ->
	
	pub = 
		    
		init: ->

			# bind document level events
			events.init()
			
			# fire up the postman!
			postman.init window.top
			
			$.subscribe('/camera/unsupported', ->
			    $('#pictures').append(intro)
			)

			# initialize the camera
			camera.init "countdown", ->

				# initialize the command bar
				bar.init "#footer"

				# initialize the previews
				preview.init ".flip"

				# initialize the full screen capture mode
				full.init "#full"

				# initialize the thumbnail gallery
				gallery.init "#gallery"

				# start drawing some previews
				preview.draw()

				# we are done loading the app. have the postman deliver that msg.
				$.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

)
