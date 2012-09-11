define [
  'Kendo' 	
  'text!mylibs/share/views/share.html'
], (kendo, template) ->

	viewModel = kendo.observable {
		selected: null
		download: ->
			selected = this.get("selected")
			$.publish "/postman/deliver", [ name: selected.name, file: selected.file, "/file/download" ]
	}

	pub = 

		init: (selector) ->

			share = new kendo.View(selector, template)
			share.render(viewModel)

			# subscribe to external events
			$.subscribe ("/item/selected"), (item) =>
				viewModel.set("selected", item)

			return share
			
