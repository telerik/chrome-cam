# Filename: main.js

require.config
    paths:
        Kendo: 'libs/kendo/kendo'

require [
    # Load our app module and pass it to our definition function
    'app'
    'order!libs/jquery/plugins'
], (app) ->
    app.init()
