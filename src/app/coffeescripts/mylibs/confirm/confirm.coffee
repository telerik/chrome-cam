define [
  'Kendo'
  'text!mylibs/confirm/views/confirm.html' 	
], (kendo, template) ->
	
	view = {}
	@callback = null

	pub = 

		yes: (e) =>
			view.data("kendoMobileModalView").close()
			if @callback
				@callback()

		no: (e) ->
			view.data("kendoMobileModalView").close()
	
		init: (selector) =>

			# view = new kendo.View(selector, template)
			# view.render(viewModel, true)
			view = $(selector)

			$.subscribe "/confirm/show", (title, message, callback) =>

				@callback = callback

				view.find(".title").html(title)
				view.find(".message").html(message)

				view.data("kendoMobileModalView").open()

