define [
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

	viewModel = kendo.observable {

		mode:
			click: (e) ->
				
				div = $(e.target)

				# we need to switch modes when clicking on the icons
				mode = div.data("mode")
				activeShape = div.data("shape")
				captureShape = div.data("capture-shape")
				updateCaptureDotShape activeShape

		capture:
			click: (e) ->

				updateCaptureDotShape captureShape

				if mode == "image"
					# start the countdown
					capture = -> $.publish "/capture/#{mode}"
					if e.ctrlKey
						capture()
					else
						countdown 0, capture
				else

					# set the start time to right now
					startTime = Date.now()

					token = $.subscribe "/capture/#{mode}/completed", ->
						$.unsubscribe token
						el.content.removeClass("recording")
						updateCaptureDotShape activeShape

					# publish the capture method
					$.publish "/capture/#{mode}"

					el.content.addClass("recording")

		filters:
			click: (e) ->

	}
	

	# countdown
	countdown = (position, callback) ->

		el.capture.hide()

		$(el.counters[position]).kendoStop(true).kendoAnimate {
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
					el.capture.show()

					# hide the counters
					el.counters.hide()

		}


	updateCaptureDotShape = (shape) ->
		el.dot.kendoStop().kendoAnimate
			effects: shape
			duration: 100

	pub = 

		init: (selector) ->

			# get a reference to the command bar container by it's selector
			el.container = $(selector)

			# wrap the template as HTML with teh jQueries
			el.content = $(template)

			# get a reference to the "capture" button
			el.capture = el.content.find ".capture"

			el.dot = el.capture.find("> div > div")

			el.mode = el.content.find ".mode"

			# the countdown spans
			el.counters = el.content.find ".countdown > span"

			# link to show or hide the gallery
			el.content.on "click", ".galleryLink", =>
				$.publish "/gallery/list"

			el.content.on "click", ".back", =>
				$.publish "/gallery/hide"

			# append it to the container
			el.container.append el.content

			# bind the container to the view model
			kendo.bind el.container, viewModel

			$.subscribe "/bar/preview/update", (message) ->
				image = $("<img />", src: message.thumbnailURL, width: 72, height: 48)
				el.content.find(".galleryLink").empty().append(image).removeClass("hidden")

			# subscribe to the show and hide events for the capture controls
			$.subscribe "/bar/capture/show", ->
				el.capture.kendoStop(true).kendoAnimate { effects: "slideIn:up", show: true, duration: 200 }
				el.mode.kendoStop(true).kendoAnimate { effects: "slideIn:right", show: true, duration: 200 }


			$.subscribe "/bar/capture/hide", ->
				el.capture.kendoStop(true).kendoAnimate { effects: "slide:down", show: true, duration: 200 }
				el.mode.kendoStop(true).kendoAnimate { effects: "slide:left", hide: true, duration: 200 }

			# TODO: The bar probably shouldn't have two different display modes
			el.content.addClass "previewMode"
			$.subscribe "/bar/gallerymode/show", ->
				el.content.removeClass("previewMode").addClass("galleryMode")

			$.subscribe "/bar/gallerymode/hide", ->
				el.content.removeClass("galleryMode").addClass("previewMode")

			# TODO: data-bind this, or at least reuse more code...
			$(".photo", el.container).on "click", ->
				$(".mode a", el.container).removeClass "active"
				$(this).addClass "active"
				recordMode = "image"
			$(".video", el.container).on "click", ->
				$(".mode a", el.container).removeClass "active"
				$(this).addClass "active"
				recordMode = "video/record"

		
