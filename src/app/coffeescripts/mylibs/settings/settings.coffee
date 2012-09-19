define [
	'Kendo'
	'text!mylibs/settings/views/settings.html' 
], (kendo, template) ->

	viewModel = { }

	pub = 
		init: (selector) ->
			view = new kendo.View(selector, template)
			view.render(viewModel, true)
