define [
  'Kendo'
  'text!mylibs/popover/views/popover.html' 	
], (kendo, template) ->

	viewModel = {
		ok: ->
			$.publish "/gallery/delete"
			$("#popover").data("kendoMobilePopOver").close()
		cancel: ->
			$("#popover").data("kendoMobilePopOver").close()
	}
	
	pub = 
		init: (selector) ->
				
			view = new kendo.View(selector, template)
			view.render(viewModel, true)
			
