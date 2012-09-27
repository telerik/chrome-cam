define [
  'Kendo'
  'text!mylibs/bar/views/bottom.html'
  'text!mylibs/bar/views/thumbnail.html'
], (kendo, template, thumbnailTemplate) ->

	BROKEN_IMAGE = "styles/images/photoPlaceholder.png"
	
	view = {}

	# create a view model for the top bar
	viewModel = kendo.observable {
	
		processing: 
			visible: false

		mode:

			visible: false
			active: "photo"
			click: (e) ->
				a = $(e.target).closest("a")

				@.set("mode.active", a.data("mode"))

				# loop through all of the buttons and remove the active class
				a.closest(".bar").find("a").removeClass "selected"

				# add the active class to this anchor
				a.addClass "selected"

		capture:

			visible: false
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
			visible: ->
				return @.get("enabled") && @.get("active")
			enabled: false
			active: true

		filters: 
			visible: false
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
			viewModel.set("mode.visible", false)
			viewModel.set("capture.visible", false)
			viewModel.set("filters.visible", false)
			viewModel.set("thumbnail.active", true)
		capture: ->
			viewModel.set("thumbnail.active", true)
			viewModel.set("mode.visible", false)
			viewModel.set("capture.visible", false)
			viewModel.set("filters.visible", false)
		record: ->
			viewModel.set("thumbnail.active", false)
			viewModel.set("mode.visible", false)
			viewModel.set("filters.visible", false)
		full: ->
			viewModel.set("processing.visible", false)
			viewModel.set("thumbnail.active", true)	
			viewModel.set("mode.visible", true)
			viewModel.set("capture.visible", true)
			viewModel.set("filters.visible", true)
		processing: ->
			viewModel.set("processing.visible", true)
			viewModel.set("capture.visible", false)
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

			# find the thumbnail anchor container
			view.find(".galleryLink", "galleryLink")

			# wire up events
			$.subscribe "/bottom/update", (state) ->
				states.set(state)

			$.subscribe "/bottom/thumbnail", (file) ->
				view.el.galleryLink.empty()
				
				if file
					thumbnail = new kendo.View(view.el.galleryLink, thumbnailTemplate, file)
					thumbnail.render()
					
					viewModel.set("thumbnail.enabled", true)
				else
					viewModel.set("thumbnail.enabled", false)

			$.subscribe "/keyboard/space", (e) ->
				viewModel.capture.click.call viewModel, e

			# get a reference to the dots.
			# TODO: this sucks. fix it with custom
			# bindings instead of this crazy BS.
			view.find(".stop", "stop")
			view.find(".counter", "counters")
			view.find(".bar", "bar")
	
			return view
