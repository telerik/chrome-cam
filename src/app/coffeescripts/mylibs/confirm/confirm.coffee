define [
  'Kendo'
  'text!mylibs/confirm/views/confirm.html' 	
], (kendo, template) ->
	
	view = {}

	viewModel = kendo.observable {

		callback: ""
		
		ok: (e) ->
			view.container.data("kendoMobileModalView").close()
			$.publish @.get("callback")

		cancel: (e) ->
			view.container.data("kendoMobileModalView").close()

	}

	pub = 
	
		init: (selector) ->

			view = new kendo.View(selector, template)
			view.render(viewModel, true)
			view.find(".message", "message")

			$.subscribe "/confirm/show", (message, callback) ->

				viewModel.set("callback", callback)

				view.el.message.html(message)

				view.container.data("kendoMobileModalView").open()

