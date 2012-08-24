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

			# the countdown spans
			$counters = $content.find ".countdown > span"

			# bind the "capture" button
			$content.on "click", ".capture", ->
				
				$capture.kendoStop(true).kendoAnimate({
					effects: "zoomOut fadeOut",
					duration: 100,
					hide: "true"
				})

				# countdown
				countdown = (position) ->
					$($counters[position]).kendoStop(true).kendoAnimate({
						effects: "zoomIn fadeIn",
						duration: 200,
						show: true,
						complete: ->
							
							# fade in the next dot!
							++position

							if position < 3
								setTimeout -> 
									countdown position
								, 500

							else
								
								console.log("clicky!")
								
								# publish the flash event
								$.publish "/full/flash"

								# publish the event to capture the image
								$.publish "/capture/image"

								# fade the capture button back in
								$capture.kendoStop(true).kendoAnimate({
									effects: "zoomIn fadeIn",
									duration: 100,
									show: true
								})

								# fade the counters out
								$counters.kendoStop(true).kendoAnimate({
									effects: "zoomOut fadeOut",
									hide: true,
									duration: 100
								})
					})

				countdown(0)

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