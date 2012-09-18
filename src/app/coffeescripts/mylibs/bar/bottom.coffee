define [
  'Kendo'
  'text!mylibs/bar/views/bottom.html'
], (kendo, template) ->

	BROKEN_IMAGE = "images/photoPlaceholder.png"
	
	view = {}

	# create a view model for the top bar
	viewModel = kendo.observable {
	
		processing: 
			display: "none"

		mode:

			display: "none"
			active: "photo"
			click: (e) ->
				
				a = $(e.target)

				this.set("mode.active", a.data("mode"))

				# loop through all of the buttons and remove the active class
				a.parent().parent().find("a").removeClass "active"

				# add the active class to this anchor
				a.addClass "active"

		capture:

			display: "none"
			click: (e) ->

				mode = this.get("mode.active")

				if mode == "photo" or mode == "paparazzi"

					states.capture()

					# start the countdown
					capture = -> $.publish "/capture/#{mode}"
					if e.ctrlKey
						capture()
					else
						countdown 0, capture
				else

					states.record()
					
					# set the start time to right now
					startTime = Date.now()

					token = $.subscribe "/recording/done", ->
						$.unsubscribe token
						states.full()

					# publish the capture method
					$.publish "/capture/#{mode}"

					view.el.stop.css "border-radius", 0

					view.el.bar.addClass("recording")


		thumbnail:
			src: BROKEN_IMAGE
			visible: true
			displayMode: ->
				if viewModel.get("thumbnail.src") == BROKEN_IMAGE then "none" else viewModel.get("thumbnail.display")

		filters: 
			display: "none"
			click: ->
				$.publish "/full/hide"

	}

	countdown = (position, callback) ->

		$(view.el.counters[position]).kendoStop(true).kendoAnimate {
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
					view.el.counters.hide()

		}

	states = 

		preview: ->
			viewModel.set("mode.display", "none")
			viewModel.set("capture.display", "none")
			viewModel.set("filters.display", "none")
			viewModel.set("thumbnail.display", null)
		capture: ->
			viewModel.set("thumbnail.display", "none")
			viewModel.set("mode.display", "none")
			viewModel.set("capture.display", "none")
			viewModel.set("filters.display", "none")
		record: ->
			viewModel.set("thumbnail.display", "none")
			viewModel.set("mode.display", "none")
			viewModel.set("filters.display", "none")
		full: ->
			viewModel.set("processing.display", "none")
			viewModel.set("thumbnail.display", null)	
			viewModel.set("mode.display", null)
			viewModel.set("capture.display", null)
			viewModel.set("filters.display", null)
		processing: ->
			viewModel.set("processing.display", null)
			viewModel.set("capture.display", "none")
			view.el.bar.removeClass("recording")
			view.el.stop.css "border-radius", 100
		set: (state) ->
			this[state]()


	pub =

		init: (container) ->
			
			# create the bottom bar for the gallery
			view = new kendo.View(container, template)

			# render the bar and binds it to the view model
			view.render(viewModel, true)

			# wire up events
			$.subscribe "/bottom/update", (state) ->
				states.set(state)

			$.subscribe "/bottom/thumbnail", (image) ->
				viewModel.set("thumbnail.src", image)

			# get a reference to the dots.
			# TODO: this sucks. fix it with custom
			# bindings instead of this crazy BS.
			view.find(".stop", "stop")
			view.find(".counter", "counters")
			view.find(".bar", "bar")
	
			return view
