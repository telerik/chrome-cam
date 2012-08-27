define([
 
], () ->
	
	pub = 
	
		init: ->

			# bind to the left and right arrow key presses
			$(document).keydown (e) ->
  
    			# if the right arrow key was pressed
    			if e.keyCode == 37 
  
       				# publish the left key event
       				$.publish "/events/key/arrow", ["left"]
  
  				# if the right arrow key was pressed
       			if e.keyCode == 39
  
       				# publish the right key event
       				$.publish "/events/key/arrow", ["right"]
  
)