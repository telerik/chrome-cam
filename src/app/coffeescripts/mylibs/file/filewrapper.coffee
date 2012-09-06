define [], (file) ->

	asyncFileRequest = (requestMessage, responseMessage, data) ->
		deferred = $.Deferred()

		token = $.subscribe responseMessage, (result) ->
			$.unsubscribe token
			deferred.resolve (result || {}).message

		$.publish "/postman/deliver", [ data, requestMessage, [] ]

		deferred.promise()
	
	pub =
		list: ->
			asyncFileRequest "/file/list", "/file/listResult", {}

		readAll: ->
			asyncFileRequest "/file/read", "/pictures/bulk", {}

		deleteFile: (filename) ->
			asyncFileRequest "/file/delete", "/file/deleted/#{filename}", name: filename

		save: (filename, blob) ->
			asyncFileRequest "/file/save", "/file/saved/#{filename}", name: filename, file: blob

		readFile: (filename) ->
			throw "not implemented"