define [
  'Kendo'
  'text!mylibs/bar/views/bar.html'
], (kendo, template) ->

	el = {}
	startTime = 0
	mode = "photo"
	
	# the state object manages the many "states" that
	# the bar can have. this is done by simply calling
	# state.set() and passing in the string name. the bar
	# then knows which UI state to show
	state = 
		full: () ->
			el.mode.show()
			el.capture.show()
		preview: () ->
			el.mode.hide()
			el.capture.hide()
		capture: () ->
			el.mode.hide()
		gallery: () ->
			
		current: "preview"
		set: (sender) -> 
			this.current = sender
			this[sender]()

	viewModel = kendo.observable {

		mode:
		
			click: (e) ->

				a = $(e.target)

				mode = a.data "mode"

				# loop through all of the buttons and remove the active class
				el.mode.find("a").removeClass "active"

				# add the active class to this anchor
				a.addClass "active"

		capture:
			
			click: (e) ->

				# hide the mode buttons
				state.set "capture"

				if mode == "photo"
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
						el.dot.css "border-radius", "100"

					# publish the capture method
					$.publish "/capture/#{mode}"

					el.dot.css "border-radius", "0"

					el.content.addClass "recording"

		filters:
			click: (e) ->

		gallery:
			click: (e) ->
				# make sure the mode and capture buttons are hidden
				el.mode.hide()
				el.capture.hide()
				# publish the gallery list event
				$.publish "/gallery/list"

		camera:
			click: (e) ->
				# are we still in capture mode?
				el.mode.show()
				if view == "full" then el.capture.show()
				$.publish "/gallery/hide"

		thumbnail: 
			src: null
			display: "none"

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

					# hide the counters
					el.counters.hide()

		}

	pub = 

		init: (selector) ->

			# get a reference to the command bar container by it's selector
			el.container = $(selector)

			# wrap the template as HTML with teh jQueries
			el.content = $(template)

			# get a reference to the "capture" button
			el.capture = el.content.find ".capture"
			el.capture.show = ->
				this.kendoStop(true).kendoAnimate { effects: "slideIn:up", show: true, duration: 200 }
			el.capture.hide = ->
				this.kendoStop(true).kendoAnimate { effects: "slide:down", show: true, duration: 200 }

			el.dot = el.capture.find("> div > div")

			el.mode = el.content.find ".mode"
			el.mode.show = ->
				this.kendoStop(true).kendoAnimate { effects: "slideIn:right", show: true, duration: 200 }
			el.mode.hide = ->
				this.kendoStop(true).kendoAnimate { effects: "slide:left", hide: true, duration: 200 }

			# the countdown spans
			el.counters = el.content.find ".countdown > span"

			# append it to the container
			el.container.append el.content

			# bind the container to the view model
			kendo.bind el.container, viewModel

			# ******* Subscribe To Events **************
			# ******************************************

			$.subscribe "/bar/preview/update", (message) ->
				viewModel.set "thumbnail.src", message.thumbnailURL
				viewModel.set "thumbnail.display", "inline"

			$.subscribe "/bar/update", (sender) ->
				state.set sender

			# TODO: The bar probably shouldn't have two different display modes
			el.content.addClass "previewMode"
			$.subscribe "/bar/gallerymode/show", ->
				el.content.removeClass("previewMode").addClass("galleryMode")

			$.subscribe "/bar/gallerymode/hide", ->
				el.content.removeClass("galleryMode").addClass("previewMode")

		
