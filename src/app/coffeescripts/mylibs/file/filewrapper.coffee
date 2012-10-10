define [], (file) ->

	asyncFileRequest = (requestMessage, responseMessage, data) ->
		deferred = $.Deferred()

		token = $.subscribe responseMessage, (result) ->
			$.unsubscribe token
			deferred.resolve (result || {}).message

		$.publish "/postman/deliver", [ data, requestMessage, [] ]

		deferred.promise()
	
	pub = window.filewrapper = 
		readAll: ->
			asyncFileRequest "/file/read", "/pictures/bulk", {}

		deleteFile: (filename) ->
			asyncFileRequest "/file/delete", "/file/deleted/#{filename}", name: filename

		clear: ->
			asyncFileRequest "/file/clear", "/file/cleared", {}

		save: (filename, blob) ->
			asyncFileRequest "/file/save", "/file/saved/#{filename}", name: filename, file: blob