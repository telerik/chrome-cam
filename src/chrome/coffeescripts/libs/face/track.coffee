define([
  'libs/face/ccv'
  'libs/face/face'
], () ->
	
	backCanvas = document.createElement "canvas"
	backContext = backCanvas.getContext "2d"
	w = 300 / 4 * 0.8
	h = 270 / 4 * 0.8

	result = {}

	enabled = false

	pub = 

		init: (x, y, width, height) ->
			backCanvas.width = 120
			backCanvas.height = 80

			result =
				faces: []
				trackWidth: backCanvas.width

			$.subscribe "/tracking/enable", (set) ->
				console.log "Face tracking: #{set}"
				enabled = set

		track: (video) ->

			result.faces = []
			
			return result unless enabled

			backContext.drawImage video, 0, 0, backCanvas.width, backCanvas.height

			params =
				canvas: ccv.grayscale(ccv.pre(backCanvas))
				cascade: cascade
				interval: 2
				min_neighbors: 1
				accurate: 0
				async: true
				worker: 1

			(ccv.detect_objects(params)) (faces) ->
				if faces.length
					result.faces = []

					for face in faces
						result.faces.push
							x: face.x
							y: face.y
							width: face.width
							height: face.height

			return result

)