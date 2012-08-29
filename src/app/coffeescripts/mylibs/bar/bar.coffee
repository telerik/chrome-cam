define([
  'text!mylibs/bar/views/bar.html'
], (template) ->

	mode = "image"
	el = {}

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
				el.$dot.kendoStop().kendoAnimate { effects: $(this).data("shape") }

			# bind the "capture" button
			el.$content.on "click", ".capture", ->
				if mode == "image"
					# start the countdown
					countdown 0, -> $.publish "/capture/#{mode}"
				else
					# publish the capture method
					$.publish "/capture/#{mode}"

			# link to show or hide the gallery
			el.$content.find(".galleryLink").toggle (-> $.publish "/gallery/list"), (-> $.publish "/gallery/hide")

			# append it to the container
			$container.append el.$content

			$.subscribe "/bar/preview/update", (message) ->
				console.log message
				$image = $("<img />", src: message.thumbnailURL, width: 72, height: 48)
				el.$content.find(".galleryLink").empty().append($image)

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