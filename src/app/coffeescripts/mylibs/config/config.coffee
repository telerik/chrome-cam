# this needs a better name to distinguish it from settings
define [], ->
	pub =
		get: (key, fn) ->
			token = $.subscribe "/config/value/#{key}", (value) ->
				$.unsubscribe token
				fn value
			$.publish "/postman/deliver", [ key, "/config/get"]

		set: (key, value) ->
			$.publish "/postman/deliver", [ key: key, value: value, "/config/set" ]
