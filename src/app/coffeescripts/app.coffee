define([
  'mylibs/camera/camera'
  'mylibs/bar/bar'
  'mylibs/preview/preview'
  'mylibs/full/full'
  'mylibs/postman/postman'
  'mylibs/utils/utils'
  'text!intro.html'
], (camera, bar, preview, full, postman, utils) ->
	
	pub = 
		    
		init: ->

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
				preview.init "#select"

				# initialize the full screen capture mode
				full.init "#full"

				# start drawing some previews
				preview.draw()

				# we are done loading the app. have the postman deliver that msg.
				$.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

)
