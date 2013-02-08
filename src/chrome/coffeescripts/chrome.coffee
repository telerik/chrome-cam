define [
    'mylibs/postman/postman'
    'mylibs/utils/utils'
    'mylibs/file/file'
    'mylibs/localization/localization'
    'mylibs/camera/camera'
], (postman, utils, file, localization, camera) ->
    'use strict'

    iframe = iframe = document.getElementById("iframe")

    wrapper = $(".wrapper")
    paparazzi = $(".paparazzi", wrapper)

    window.cleanup = ->
        camera.cleanup()

    # TODO: Move the context menu to its own file
    menu = ->
        chrome.contextMenus.onClicked.addListener (info, tab) ->
            $.publish "/postman/deliver", [{}, "/menu/click/#{info.menuItemId}"]

        $.subscribe "/menu/enable", (isEnabled) ->
            menus = [ "chrome-cam-about-menu" ]
            for menu in menus
                chrome.contextMenus.update menu, enabled: isEnabled

    pub =
        init: ->
            # initialize utils
            utils.init()

            iframe.src = "app/index.html"

            # cue up the postman!
            postman.init iframe.contentWindow

            camera.init()

            # get the localization dictionary from the app
            $.subscribe "/localization/request", ->
                $.publish "/postman/deliver", [ localization, "/localization/response" ]

            $.subscribe "/window/close", ->
                window.close()

            # get the files
            file.init()

            #effects.init()
            #effect.name = APP.localization[effect.id] for effect in effects.data

            # setup the context menu
            menu()

            # this ensures that keyboard shortcut works without manually focusing the iframe
            $(iframe).focus()
