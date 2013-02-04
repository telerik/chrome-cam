define [
  'Kendo'
  'mylibs/utils/utils'
  'text!mylibs/bar/views/bottom.html'
  'text!mylibs/bar/views/thumbnail.html'
], (kendo, utils, template, thumbnailTemplate) ->

	BROKEN_IMAGE = utils.placeholder.image()

	view = {}

	# create a view model for the top bar
	viewModel = kendo.observable
		processing:
			visible: false

		mode:
			visible: false
			active: "photo"

		capture:
			visible: true

		thumbnail:
			src: BROKEN_IMAGE
			visible: ->
				return @get("enabled") && @get("active")
			enabled: false
			active: true

		filters:
			visible: false
			open: false
			css: ->

	countdown = (position, callback) ->

		$(view.el.counters[position]).kendoStop(true).kendoAnimate
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

	states =

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
				pub.capture e if viewModel.get("capture.visible")

			# get a reference to the dots.
			# TODO: this sucks. fix it with custom
			# bindings instead of this crazy BS.
			view.find(".stop", "stop")
			view.find(".counter", "counters")
			view.find(".bar", "bar")
			view.find(".filters", "filters")
			view.find(".capture", "capture")

			return view

		capture: (e) ->
			$.publish "/full/capture/begin"

			mode = viewModel.get("mode.active")

			states.capture()

			# start the countdown
			capture = ->
				$.publish "/capture/#{mode}"
				$.publish "/full/capture/end"

			$.publish "/countdown/#{mode}"
			if event.ctrlKey or event.metaKey
				capture()
			else
				countdown 0, capture

		filters: (e) ->
			viewModel.set "filters.open", not viewModel.filters.open
			view.el.filters.toggleClass "selected", viewModel.filters.open
			$.publish "/full/filters/show", [viewModel.filters.open]

		mode: (e) ->

			a = $(e.target).closest("a")

			viewModel.set "mode.active", a.data("mode")

			# loop through all of the buttons and remove the active class
			a.closest(".bar").find("a").removeClass "selected"

			# add the active class to this anchor
			a.addClass "selected"

		gallery: ->
			APP.app.navigate("#gallery")

