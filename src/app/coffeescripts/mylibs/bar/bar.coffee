define([
  'Kendo'
  'text!mylibs/bar/views/bar.html'
], (kendo, template) ->

	mode = "image"
	activeShape = "circle"
	captureShape = "circle"
	el = {}
	startTime = 0

	# create the box to square and back effect
	kendo.fx.circle =
		setup: (element, options) ->
			$.extend { borderRadius: 100 }, options.properties

	kendo.fx.square =
		setup: (element, options) ->
			$.extend { borderRadius: 0 }, options.properties
	

	# countdown
	countdown = (position, callback) ->

		el.$capture.hide()

		$(el.$counters[position]).kendoStop(true).kendoAnimate {
			effects: "zoomIn fadeIn",
			duration: 200,
			show: true,
			complete: ->

				# fade in the next dot!
				++position

				if position < 3
					setTimeout -> 
						countdown position, callback
					, 500

				else

					callback()

					# show the capture button
					el.$capture.show()

					# hide the counters
					el.$counters.hide()

		}


	updateCaptureDotShape = (shape) ->
		el.$dot.kendoStop().kendoAnimate
			effects: shape
			duration: 100

	pub = 

		init: (selector) ->
			# get a reference to the command bar container by it's selector
			$container = $(selector)

			# wrap the template as HTML with teh jQueries
			el.$content = $(template)

			# get a reference to the "capture" button
			el.$capture = el.$content.find ".capture"

			el.$dot = el.$capture.find("> div > div")

			# the countdown spans
			el.$counters = el.$content.find ".countdown > span"

			# we need to switch modes when clicking on the icons
			el.$content.find(".mode").on "click", "a", ->
				mode = $(this).data("mode")
				activeShape = $(this).data("shape")
				captureShape = $(this).data("capture-shape")
				updateCaptureDotShape activeShape

			# bind the "capture" button
			el.$content.on "click", ".capture", (e) ->
				updateCaptureDotShape captureShape

				if mode == "image"
					# start the countdown
					capture = -> $.publish "/capture/#{mode}"
					if e.ctrlKey or e.metaKey
						capture()
					else
						countdown 0, capture
				else

					# set the start time to right now
					startTime = Date.now()

					token = $.subscribe "/capture/#{mode}/completed", ->
						$.unsubscribe token
						el.$content.removeClass("recording")
						updateCaptureDotShape activeShape

					# publish the capture method
					$.publish "/capture/#{mode}"

					el.$content.addClass("recording")

			# link to show or hide the gallery
			el.$content.on "click", ".galleryLink", ->
				$.publish "/gallery/list"

			el.$content.on "click", ".back", ->
				$.publish "/gallery/hide"

			# append it to the container
			$container.append el.$content

			$.subscribe "/bar/preview/update", (message) ->
				$image = $("<img />", src: message.thumbnailURL, width: 72, height: 48)
				el.$content.find(".galleryLink").empty().append($image).removeClass("hidden")

			# subscribe to the show and hide events for the capture controls
			$.subscribe "/bar/capture/show", ->
				el.$capture.kendoStop(true).kendoAnimate({
					effects: "slideIn:up"
					show: true
					duration: 200
				})


			$.subscribe "/bar/capture/hide", ->
				el.$capture.kendoStop(true).kendoAnimate({
					effects: "slide:down"
					show: true
					duration: 200
				})

			# TODO: The bar probably shouldn't have two different display modes
			el.$content.addClass "previewMode"
			$.subscribe "/bar/gallerymode/show", ->
				el.$content.removeClass("previewMode").addClass("galleryMode")

			$.subscribe "/bar/gallerymode/hide", ->
				el.$content.removeClass("galleryMode").addClass("previewMode")

			# TODO: data-bind this, or at least reuse more code...
			$(".photo", el.$container).on "click", ->
				$(".mode a", el.$container).removeClass "active"
				$(this).addClass "active"
				recordMode = "image"
			$(".video", el.$container).on "click", ->
				$(".mode a", el.$container).removeClass "active"
				$(this).addClass "active"
				recordMode = "video/record"
)