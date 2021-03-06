define [], () ->

	canvas = document.createElement("canvas")
	ctx = canvas.getContext("2d")

	toDataURL = (image, format) ->

		canvas.width = image.width
		canvas.height = image.height

		ctx.drawImage image, 0, 0, image.width, image.height

		if (format)
			canvas.toDataURL(format) image
		else
			canvas.toDataURL image

	toBlob = (dataURL) ->

		if dataURL.split(',')[0].indexOf('base64') >= 0
			byteString = atob(dataURL.split(',')[1])
		else
			byteString = unescape(dataURL.split(',')[1])

		mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0]

		ab = new ArrayBuffer(byteString.length, 'binary')

		ia = new Uint8Array(ab)

		for i in [0...byteString.length]
			ia[i] = byteString.charCodeAt(i)

		new Blob([ia], { type: mimeString })

	pub =

		init: ->
			Image.prototype.toDataURL = (format) ->

				toDataURL(this, format)

			Image.prototype.toBlob = ->

				dataURL = toDataURL(this)

				toBlob(dataURL)

		toBlob: (dataURL) ->

			toBlob(dataURL)

		getAnimationFrame: ->
			window.requestAnimationFrame || window.webkitRequestAnimationFrame