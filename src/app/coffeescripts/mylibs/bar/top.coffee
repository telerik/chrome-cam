define [
  'Kendo' 	
  'text!mylibs/bar/views/top.html'
], (kendo, template) ->

	# create a view model for the top bar
	# VIEW MODEL ISN'T WORKING. WHY NOT?
	viewModel = kendo.observable {
		current: null
		selected: false
		back:
			details: false
			text: "< Camera"
			click: (e) ->
				$.publish "/details/hide"
				states.gallery()
				e.preventDefault()
		destroy:
			click: (e) ->
				$.publish "/confirm/show", [
					window.APP.localization.deleteDialogTitle,
					window.APP.localization.deleteConfirmation,
					-> $.publish("/gallery/delete")
				]
		share:
			save: (e) ->
				file = @.get("current")
				$.publish "/postman/deliver", [ name: file.name, file: file.file, "/file/download" ]
	}

	# TODO: Refactor Once View Model Is Working
	states = 
		selected: ->
			viewModel.set("selected", true)
		deselected: ->
			viewModel.set("selected", false)
		details: =>
			viewModel.set("back.text", "< Gallery")
			viewModel.set("back.details", true)
			$.publish "/gallery/details", [true]
		gallery: =>
			viewModel.set("back.text", "< Camera")
			viewModel.set("back.details", false)
			$.publish "/gallery/details", [false]
		set: (state) ->
			states.current = state
			states[state]()

	pub =

		init: (container) =>
			
			# create the bottom bar for the gallery
			@view = new kendo.View(container, template)

			# render the bar and binds it to the view model
			@view.render(viewModel, true)

			# find and cache some DOM elements
			back = @view.find(".back.button")

			# wire up events
			$.subscribe "/top/update", (state) ->
				states.set state

			$.subscribe "/item/selected", (message) ->
				viewModel.set("current", message.item)

			$.subscribe "/keyboard/esc", ->
				if states.current == "details"
					states.set "gallery"
					back.trigger "click"

			return @view

			

	
		