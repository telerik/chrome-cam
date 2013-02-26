require.config
    shim:
        glfx:
            exports: 'fx'
        CCV:
            exports: 'ccv'
        Face:
            deps: ['CCV']

    paths:
        glfx: '../libs/glfx/glfx.min'
        CCV: '../libs/face/ccv'
        Face: '../libs/face/face'

require [
    'chrome'
], (app) ->
    app.init()