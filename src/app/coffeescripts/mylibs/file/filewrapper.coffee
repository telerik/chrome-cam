define [], (file) ->
	
	pub =
		list: ->
			deferred = $.Deferred()

			token = $.subscribe "/file/listResult", (result) ->
				$.unsubscribe token
				deferred.resolve result.message

			# this doesn't seem to be working?
			$.publish "/postman/deliver", [ {}, "/file/list", [] ]

			deferred.promise()

		readAll: ->
			deferred = $.Deferred()

			token = $.subscribe "/pictures/bulk", (result) ->
				$.unsubscribe token
				deferred.resolve result.message

			# this doesn't seem to be working?
			$.publish "/postman/deliver", [ {}, "/file/read", [] ]

			deferred.promise()

		deleteFile: (filename) ->
			deferred = $.Deferred()

			token = $.subscribe "/file/deleted/#{filename}", ->
				$.unsubscribe token
				deferred.resolve()

			$.publish "/postman/deliver", [  name: filename, "/file/delete", [] ]

			deferred.promise()

		save: (filename, blob) ->
			deferred = $.Deferred()

			token = $.subscribe "/file/saved/#{filename}", ->
				$.unsubscribe token
				deferred.resolve()

			$.publish "/postman/deliver", [  name: filename, file: blob, "/file/save" ]

			deferred.promise()

		readFile: (filename) ->
			throw "not implemented"