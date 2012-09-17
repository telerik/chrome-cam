define([
  'Kendo'
  'Glfx'
  'mylibs/camera/camera'
  'mylibs/bar/bottom'
  'mylibs/bar/top'
  'mylibs/preview/preview'
  'mylibs/full/full'
  'mylibs/postman/postman'
  'mylibs/utils/utils'
  'mylibs/gallery/gallery'
  'mylibs/gallery/details'
  'mylibs/share/share'
  'mylibs/events/events'
  'mylibs/file/filewrapper'
  'libs/record/record'
], (kendo, glfx, camera, bottom, top, preview, full, postman, utils, gallery, details, share, events, filewrapper, record ) ->
	
	pub = 
		    
		init: ->

			window.APP = {}

			window.APP.full = full
			window.APP.filters = preview
			window.APP.gallery = gallery

			# bind document level events
			events.init()
			
			# fire up the postman!
			postman.init window.top
			
			$.subscribe('/camera/unsupported', ->
			    $('#pictures').append(intro)
			)

			# initialize the camera
			camera.init "countdown", ->

				# create the top and bottom bars
				window.APP.bottom = bottom.init(".bottom")
				window.APP.top = top.init(".top")

				# initialize the command bar
				# bar.init ".top", ".bottom"

				# initialize the previews
				preview.init "#filters"

				# initialize the full screen capture mode
				full.init "#capture"

				# initialize gallery details view
				details.init "#details"

				# initialize the thumbnail gallery
				gallery.init "#thumbnails"

				window.APP.share = share.init "#gallery"

				# start drawing some previews
				preview.draw()

				# we are done loading the app. have the postman deliver that msg.
				$.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

				window.APP.app = new kendo.mobile.Application document.body, { transition: "overlay:up", platform: "blackberry" }

)
