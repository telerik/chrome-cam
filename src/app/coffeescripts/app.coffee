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
  'mylibs/effects/effects',
	"text!mylibs/nocamera/views/nocamera.html"
], (kendo, glfx, camera, bottom, top, popover, full, postman, utils, gallery, details, events, filewrapper, about, confirm, assets, effects, nocamera) ->

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

			$.subscribe '/camera/unsupported', ->
				new kendo.View("#no-camera", nocamera).render(kendo.observable({}), true)
				APP.app.navigate "#no-camera"

			$.publish "/postman/deliver", [ true, "/menu/enable" ]

			$.subscribe "/localization/response", (dict) ->

				APP.localization = dict

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
					effect.name = APP.localization[effect.id] for effect in effects.data
					full.show effects.data[0]

					# we are done loading the app. have the postman deliver that msg.
					$.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

					window.APP.app = new kendo.mobile.Application document.body, { platform: "android" }

					hideSplash = ->
						$("#splash").kendoAnimate
							effects: "fade:out"
							duration: 1000,
							hide: true
					setTimeout hideSplash, 100

					$.subscribe "/keyboard/close", ->
						$.publish "/postman/deliver", [ null, "/window/close" ]

				# initialize the camera
				camera.init "countdown", ready

			$.publish "/postman/deliver", [ null, "/localization/request" ]
