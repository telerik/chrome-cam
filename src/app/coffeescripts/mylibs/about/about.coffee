define [
  'Kendo' 	
  'text!mylibs/about/views/about.html'
], (kendo, template) ->
	
	previous = "#home"

	viewModel = kendo.observable

		back: ->
			$.publish "/postman/deliver", [ true, "/menu/enable" ]
			window.APP.app.navigate previous

		goto: (e) ->
			$.publish "/postman/deliver", [$(e.currentTarget).attr("href"), "/tab/open"]

		gallery:
			clear: ->
				console.log window.APP.localization.clearGalleryDialogTitle
				$.publish "/confirm/show", [
					window.APP.localization.clearGalleryDialogTitle,
					window.APP.localization.clearGalleryConfirmation,
					-> $.publish("/gallery/clear")
				]

	pub = 

		# unlike the viewModel events, these events are for the mobile view itself
		before: ->
			$.publish "/postman/deliver", [{ paused: true }, "/camera/pause"]

		hide: ->
			$.publish "/postman/deliver", [{ paused: false }, "/camera/pause"]
			$.publish "/postman/deliver", [ null, "/camera/request" ]

		init: (selector) ->

			# create the about view
			view = new kendo.View(selector, template)
			view.render(viewModel, true)

			# subscribe to the about event from the context menu
			$.subscribe '/menu/click/chrome-cam-about-menu', ->
				$.publish "/postman/deliver", [ false, "/menu/enable" ]
				previous = window.APP.app.view().id
				window.APP.app.navigate selector

