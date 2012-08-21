define([
  'libs/face/ccv'
  'libs/face/face'
], () ->
	
	backCanvas = document.createElement "canvas"
	backContext = backCanvas.getContext "2d"
	w = 300 / 4 * 0.8
	h = 270 / 4 * 0.8
	cache = {}

	pub = 

		init: (x, y, width, height) ->
			
			backCanvas.width = 120
			backCanvas.height = 80

			cache.comp = [{
				x: x
				y: y
				width: backCanvas.width
				height: backCanvas.height
			}]

		track: (canvas, skip) ->

			faces = []

			# we skip every so many frames to try and speed things up
			if not skip

				backContext.drawImage canvas, 0, 0, backCanvas.width, backCanvas.height

				comp = ccv.detect_objects cache.ccv = cache.ccv || {
					canvas: ccv.grayscale(backCanvas)
					cascade: cascade,
					interval: 5,
					min_neighbors: 1
				}

				if comp.length

					console.log("FACE!")
					cache.comp = comp

				for i in cache.comp

					faces.push {
						x: i.x
						y: i.y
						width: i.width
						height: i.height
					}

			$.publish "/camera/stream", [{ 
				canvas: canvas, 
				faces: faces, 
				trackWidth: backCanvas.width, 
				trackHeight: backCanvas.height 
			}]

)