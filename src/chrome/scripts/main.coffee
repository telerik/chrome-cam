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
    el = new Everlive('7TAb2POEnVjwQuch')

    login = Everlive.$.Users.login('cwagner', 'BrownsSuck2013!')
    login.then (data) ->
        console.log JSON.stringify(data)
    , (error) ->
        console.log JSON.stringify(error)

    app.init()