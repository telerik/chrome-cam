define([
], () ->

    ###     Utils

    This file contains utility functions and normalizations. this used to contain more functions, but
    most have been moved into the extension

    ###

    pub = 

    	# add a method onto the pixel array 

    	# normalizes webkitRequestAnimationFrame
    	getAnimationFrame: ->
	        return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || (callback, element) ->
	            return window.setTimeout(callback, 1000 / 60)

	    createVideo: (frames) ->

	    	transcode = ->

	    		video = new Whammy.Video()
	    		for pair in (frames[i ... i + 2] for i in [0 .. frames.length - 2])
	    			video.add pair[0].imageData, pair[1].time - pair[0].time

		    	blob = video.compile()
		    	frames = []
		    	console.log window.URL.createObjectURL(blob)

	    	canvas = document.createElement("canvas")
	    	canvas.width = 720
	    	canvas.height = 480
	    	ctx = canvas.getContext("2d")

	    	framesDone = 0;

	    	for i in [0...frames.length]

	    		setTimeout do (i) ->
	    			imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
	    			videoData = new Uint8ClampedArray(frames[i].imageData)
	    			imageData.data.set(videoData)
	    			ctx.putImageData imageData, 0, 0
	    			frames[i] = imageData: canvas.toDataURL('image/webp', 1), time: frames[i].time
	    			++framesDone
	    			if framesDone == frames.length
	    				transcode()
)
