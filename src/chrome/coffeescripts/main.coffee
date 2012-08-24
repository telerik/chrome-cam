# Filename: main.js

require([

  # Load our app module and pass it to our definition function
  'order!libs/jquery/jquery'
  'order!libs/whammy/whammy.min'
  'app'

], ($, whammy, app) ->
	app.init()
)