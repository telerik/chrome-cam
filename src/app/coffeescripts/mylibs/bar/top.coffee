define [
  'Kendo' 	
  'text!mylibs/bar/views/top.html'
], (kendo, template) ->

	# create a view model for the top bar
	viewModel = kendo.observable {			

	}

	pub =

		init: (container) ->
			
			# create the bottom bar for the gallery
			bar = new kendo.View(container, template)

			# render the bar and binds it to the view model
			bar.render(viewModel)

			# wire up events
			$.subscribe "/top/update", (state) ->
				state.set topBar, state

				# topBar.state:
				# 	preview: ->
				# 	capture: ->
				# 	full: ->	
				# 	set: ->

			return bar

			

	
		