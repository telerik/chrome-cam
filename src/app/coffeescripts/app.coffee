define [
    'Kendo'
    'mylibs/bar/bottom'
    'mylibs/bar/top'
    'mylibs/popover/popover'
    'mylibs/full/full'
    'mylibs/postman/postman'
    'mylibs/utils/utils'
    'mylibs/gallery/gallery'
    'mylibs/gallery/details'
    'mylibs/events/events'
    'mylibs/file/filewrapper'
    'mylibs/about/about'
    'mylibs/confirm/confirm'
    'mylibs/assets/assets'
    'mylibs/navigation/navigation'
    'mylibs/tabbing/tabbing'
    "text!mylibs/nocamera/views/nocamera.html"
], (kendo, bottom, top, popover, full, postman, utils, gallery, details, events, filewrapper, about, confirm, assets, navigation, tabbing, nocamera) ->

    pub =
        init: ->
            APP = window.APP = {}

            APP.full = full
            APP.gallery = gallery
            APP.about = about
            APP.confirm = confirm
            APP.bottom = bottom
            APP.top = top
            APP.details = details

            # bind document level events
            events.init()

            # fire up the postman!
            postman.init window.top

            # initialize the asset pipeline
            assets.init()

            $.subscribe '/camera/unsupported', ->
                new kendo.View("#no-camera", nocamera).render(kendo.observable({}), true)
                navigation.navigate "#no-camera"

            $.publish "/postman/deliver", [ true, "/menu/enable" ]

            # subscribe to the pause event
            #$.subscribe "/camera/pause", (isPaused) ->
            #    paused = isPaused

            promises =
                effects: $.Deferred()
                localization: $.Deferred()

            $.subscribe "/effects/response", (filters) ->
                APP.filters = filters
                promises.effects.resolve()

            $.subscribe "/localization/response", (dict) ->
                APP.localization = dict
                promises.localization.resolve()

            $.when(promises.effects.promise(), promises.localization.promise()).then ->
                # create the top and bottom bars
                bottom.init(".bottom")
                top.init(".top")
                APP.popover = popover.init("#gallery")

                # initialize the full screen capture mode
                full.init "#capture"

                # initialize gallery details view
                details.init "#details"

                # initialize the thumbnail gallery
                gallery.init "#list"

                # initialize the about view
                about.init "#about"

                # initialize the confirm window
                confirm.init "#confirm"

                # start up full view
                full.show APP.filters[0]

                tabbing.init()
                tabbing.setLevel 0

                # we are done loading the app. have the postman deliver that msg.
                $.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

                window.APP.app = new kendo.mobile.Application document.body, { platform: "android" }

                hideSplash = ->
                    $("#splash").kendoAnimate
                        effects: "fade:out"
                        duration: 1000,
                        hide: true
                setTimeout hideSplash, 100

                $.subscribe "/keyboard/close", ->
                    $.publish "/postman/deliver", [ null, "/window/close" ]

            $.publish "/postman/deliver", [ null, "/localization/request" ]
            $.publish "/postman/deliver", [ null, "/effects/request" ]
