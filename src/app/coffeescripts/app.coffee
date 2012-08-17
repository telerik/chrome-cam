define([
  'mylibs/camera/camera'
  'mylibs/preview/preview'
  'mylibs/full/full'
  'mylibs/postman/postman'
  'mylibs/utils/utils'
  'text!intro.html'
], (camera, preview, full, postman, utils) ->
	
	pub = 
		    
		init: ->

			# fire up the postman!
			postman.init()
			
			$.subscribe('/camera/unsupported', ->
			    $('#pictures').append(intro)
			)

			# initialize the camera
			camera.init "countdown", ->

				preview.init "#select"

				full.init "#full"

				preview.draw()

				# we are done loading the app. have the postman deliver that msg.
				$.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

)
