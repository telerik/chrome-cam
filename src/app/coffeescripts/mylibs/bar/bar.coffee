define([
  'text!mylibs/bar/views/bar.html'
], (template) ->
	
	pub = 

		init: (selector) ->
	
			# get a reference to the command bar container by it's selector
			$container = $(selector)

			# wrap the template as HTML with teh jQueries
			$content = $(template)

			# bind the "capture" button
			$content.click ->
				# publish the event to capture the image
				$.publish "/capture/image"

			$content.find(".show-gallery").click ->
				$.publish "/gallery/list"

			# append it to the container
			$container.append $content
)