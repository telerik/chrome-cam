define [
  'Kendo'
  'text!mylibs/bar/views/bottom.html'
], (kendo, template) ->

	view = {}

	# create a view model for the top bar
	viewModel = kendo.observable {
	
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
						view.el.bar.removeClass("recording")
						view.el.stop.css "border-radius", 100
						states.full()

					# publish the capture method
					$.publish "/capture/#{mode}"

					view.el.stop.css "border-radius", 0

					view.el.bar.addClass("recording")


		thumbnail:
			src: "images/broke.png"
			display: null

		filters: 
			display: "none"

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
			viewModel.set("mode.display", "none")
			viewModel.set("capture.display", "none")
			viewModel.set("filters.display", "none")
		record: ->
			viewModel.set("mode.display", "none")
			viewModel.set("filters.display", "none")
		full: ->
			viewModel.set("thumbnail.display", "none")	
			viewModel.set("mode.display", null)
			viewModel.set("capture.display", null)
			viewModel.set("filters.display", null)
		set: (state) ->
			this[state]()


	pub =

		init: (container) ->
			
			# create the bottom bar for the gallery
			view = new kendo.View(container, template)

			# render the bar and binds it to the view model
			view.render(viewModel)

			# wire up events
			$.subscribe "/bottom/update", (state) ->
				states.set(state)

			# get a reference to the dots.
			# TODO: this sucks. fix it with custom
			# bindings instead of this crazy BS.
			view.find(".stop", "stop")
			view.find(".counter", "counters")
			view.find(".bar", "bar")
	
			return view
