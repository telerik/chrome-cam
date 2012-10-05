define [
  'Kendo'
  'text!mylibs/confirm/views/confirm.html' 	
], (kendo, template) ->
	
	view = {}
	@callback = null
	open = false

	pub = 

		yes: (e) =>
			view.data("kendoMobileModalView").close()
			open = false
			if @callback
				@callback()

		no: (e) ->
			open = false
			view.data("kendoMobileModalView").close()

		init: (selector) =>

			# view = new kendo.View(selector, template)
			# view.render(viewModel, true)
			view = $(selector)

			$.subscribe "/confirm/show", (title, message, callback) =>

				@callback = callback

				view.find(".title").html(title)
				view.find(".message").html(message)

				view.find(".yes").text window.APP.localization.yesButton
				view.find(".no").text window.APP.localization.noButton

				view.data("kendoMobileModalView").open()
				open = true

			esc = ->
				if open
					pub.no()
					return false

			$.subscribe "/keyboard/esc", esc, true

