define([
  'text!mylibs/bar/views/bar.html'
], (template) ->
	
	pub = 

		init: (selector) ->
	
			# get a reference to the command bar container by it's selector
			$container = $(selector)

			# wrap the template as HTML with teh jQueries
			$content = $(template)

			# get a reference to the "capture" button
			$capture = $content.find ".capture"

			# bind the "capture" button
			$content.on "click", ".capture", ->
				console.log("clicky!")
				# publish the event to capture the image
				$.publish "/capture/image"

			$content.find(".show-gallery").toggle (-> $.publish "/gallery/list"), (-> $.publish "/gallery/hide")

			# append it to the container
			$container.append $content

			# subscribe to the show and hide events for the capture controls
			$.subscribe "/bar/capture/show", ->
				$capture.kendoStop(true).kendoAnimate({
					effects: "slideIn:up"
					show: true
					duration: 200
				})


			$.subscribe "/bar/capture/hide", ->
				$capture.kendoStop(true).kendoAnimate({
					effects: "slide:down"
					show: true
					duration: 200
				})
)