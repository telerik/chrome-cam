define [
  'Kendo'
  'mylibs/bar/state'
  'text!mylibs/bar/views/bar.html'
], (kendo, state, template) ->

	el = {}
	startTime = 0
	mode = "photo"

	# the state object manages the many "states" that
	# the bar can have. this is done by simply calling
	# state.set() and passing in the string name. the bar
	# then knows which UI state to show
		

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

				if mode == "photo"

					state.set "capture"

					# start the countdown
					capture = -> $.publish "/capture/#{mode}"
					if e.ctrlKey
						capture()
					else
						countdown 0, capture
				else

					state.set "recording"

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
				state.set "gallery"
				# publish the gallery list event
				$.publish "/gallery/list"

		camera:
			click: (e) ->
				# are we still in capture mode?
				state.set state.previous
				$.publish "/gallery/hide"

		thumbnail: 
			src: null
			display: "none"

	}



	# countdown
	countdown = (position, callback) ->

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

			# TODO: this should be done with custom bindings

			# get a reference to the "capture" button
			el.capture = el.content.find ".capture"
			el.capture.in = { effects: "slideIn:up" }
			el.capture.out = { effects: "slide:down" }

			el.dot = el.capture.find("> div > div")

			el.mode = el.content.find ".mode"
			el.mode.in = { effects: "slideIn:right" }
			el.mode.out = { effects: "slide:left" }

			el.share = el.content.find ".share"
			el.delete = el.content.find ".delete"
			el.back = el.content.find ".back"
			el.thumbnail = el.content.find ".galleryLink"

			# the countdown spans
			el.counters = el.content.find ".countdown > span"

			# append it to the container
			el.container.append el.content

			# initialize the state manager
			state = state.init el

			# bind the container to the view model
			kendo.bind el.container, viewModel

			# ******* Subscribe To Events **************
			# ******************************************

			$.subscribe "/bar/preview/update", (message) ->
				viewModel.set "thumbnail.src", message.thumbnailURL
				el.thumbnail.show()

			$.subscribe "/bar/update", (sender) ->
				state.set sender

		
