require.config
    paths:
        text: '../common/require/text'
        views: '../views'

require [
    'app'
    'binders/zoom'
    'binders/locale'
], (app) ->
    app.init()
