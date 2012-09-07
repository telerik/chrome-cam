define [
  'Kendo' 	
], (kendo) ->

	pub = 

		init: (el) ->

			for own key, value of el

				do (value) ->
					if value.in
						value.show = -> value.kendoStop(true).kendoAnimate { effects: value.in.effects, show: true, duration: 200 }
					if value.out
						value.hide = -> value.kendoStop(true).kendoAnimate { effects: value.out.effects, hide: true, duration: 200 }

			full: ->
				
				el.content.removeClass "recording"

				el.share.hide()
				el.delete.hide()
				el.back.hide()
				el.thumbnail.hide()

				el.mode.show()
				el.capture.show()

			preview: () ->

				el.content.removeClass "recording"

				el.share.hide()
				el.delete.hide()
				el.back.hide()
				el.thumbnail.show()

				el.mode.hide()
				el.capture.hide()

			capture: () ->

				el.mode.hide()
				el.capture.hide()

			recording: () ->

				el.content.addClass "recording"
				el.capture.hide()
				el.mode.hide()

			gallery: () ->
				
				el.mode.hide()
				el.capture.hide()
				el.thumbnail.hide()
				
				el.share.show()
				el.delete.show()
				el.back.show()

			previous: "preview"
			current: "preview"
			
			set: (sender) -> 
				@.previous = @.current
				@.current = sender
				@[sender]()
