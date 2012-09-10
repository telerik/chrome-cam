define [
  'Kendo' 	
], (kendo) ->

	pub = 

		init: (el) ->

			for own key, value of el

				do (value) ->
					if value.in
						value.show = -> 
							value.kendoStop(true).kendoAnimate { 
								effects: value.in.effects,
								show: true,
								duration: 200,
								complete: value.complete or null
							}
					if value.out
						value.hide = -> 
							value.kendoStop(true).kendoAnimate { 
								effects: value.out.effects, 
								hide: true, 
								duration: 200,
								complete: value.complete or null 
							}
			full: ->
				
				el.content.removeClass "recording"

				el.share.hide()
				el.delete.hide()
				el.back.hide()
				el.thumbnail.hide()

				el.mode.show()
				el.capture.show()
				el.filters.show()

			preview: () ->

				el.content.removeClass "recording"

				el.share.hide()
				el.delete.hide()
				el.back.hide()
				el.thumbnail.show()

				el.mode.hide()
				el.capture.hide()
				el.filters.hide()

			capture: () ->

				el.mode.hide()
				el.capture.hide()
				el.filters.hide()

			recording: () ->

				el.content.addClass "recording"
				el.capture.hide()
				el.mode.hide()
				el.filters.hide()

			gallery: () ->
				
				el.mode.hide()
				el.capture.hide()
				el.thumbnail.hide()
				el.filters.hide
				
				el.share.show()
				el.delete.show()
				el.back.show()

			previous: "preview"
			current: "preview"
			
			set: (sender) -> 
				@.previous = @.current
				@.current = sender
				@[sender]()
