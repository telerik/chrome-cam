# Filename: main.js

require.config {
	paths: 
		Kendo: 'libs/kendo/kendo'
		Glfx: 'libs/webgl/glfx'
}

require [



  # Load our app module and pass it to our definition function
  'app'
  'order!libs/jquery/plugins'
  'order!libs/whammy/whammy'

], (app) ->
	app.init()
