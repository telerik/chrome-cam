define [
  'Kendo'
  'text!mylibs/bar/views/confirm.html' 	
], (kendo, template) ->

	viewModel = {
		ok: ->
			$.publish "/gallery/delete"
			$("#confirm").data("kendoMobilePopOver").close()
		cancel: ->
			$("#confirm").data("kendoMobilePopOver").close()
	}
	
	pub = 
		init: (selector) ->
				
			view = new kendo.View(selector, template)
			view.render(viewModel, true)
			
