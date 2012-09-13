define [
  'Kendo' 	
  'text!mylibs/bar/views/top.html'
], (kendo, template) ->

	# create a view model for the top bar
	# VIEW MODEL ISN'T WORKING. WHY NOT?
	viewModel = kendo.observable {
		back:
			details: false
			text: "< Camera"
			click: ->
				$.publish "/details/hide"
				states.gallery()
	}

	# TODO: Refactor Once View Model Is Working
	states = 
		details: =>
			viewModel.set("back.text", "< Gallery")
			viewModel.set("back.details", true)
		gallery: =>
			viewModel.set("back.text", "< Camera")
			viewModel.set("back.details", false)
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
			@view.find("#back", "back")

			# wire up events
			$.subscribe "/top/update", (state) ->
				states.set state

				# topBar.state:
				# 	preview: ->
				# 	capture: ->
				# 	full: ->	
				# 	set: ->

			return @view

			

	
		