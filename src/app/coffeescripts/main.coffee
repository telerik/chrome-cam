# Filename: main.js

require([

  # Load our app module and pass it to our definition function
  'app'
  'order!libs/jquery/plugins'
  'order!libs/whammy/whammy.min'
  'libs/webgl/glfx'

], (app) ->
	app.init()
)