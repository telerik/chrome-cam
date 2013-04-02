define [
    'bar/bottom'
    'bar/galleryBar'
    'popover/popover'
    'full/full'
    'postman/postman'
    'utils/utils'
    'gallery/gallery'
    'gallery/details'
    'events/events'
    'file/filewrapper'
    'about/about'
    'confirm/confirm'
    'navigation/navigation'
    'tabbing/tabbing'
    'printer/printer'
    "text!views/nocamera.html"
], (bottom, galleryBar, popover, full, postman, utils, gallery, details, events, filewrapper, about, confirm, navigation, tabbing, printer, nocamera) ->

    pub =
        init: ->
            APP = window.APP = {}

            APP.full = full
            APP.gallery = gallery
            APP.about = about
            APP.confirm = confirm
            APP.bottom = bottom
            APP.galleryBar = galleryBar
            APP.details = details

            APP.printer = printer

            # bind document level events
            events.init()

            # fire up the postman!
            postman.init window.top

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
                printers: $.Deferred()

            $.subscribe "/effects/response", (filters) ->
                APP.filters = filters
                promises.effects.resolve()

            $.subscribe "/localization/response", (dict) ->
                APP.localization = dict
                promises.localization.resolve()

            $.subscribe "/printer/list/response", (printers) ->
                printer.init printers
                promises.printers.resolve()

            $.when.apply($, (v.promise() for k, v of promises)).then ->
                # create the top and bottom bars
                bottom.init(".bottom")
                galleryBar.init ".galleryBar"

                APP.popover = popover.init("#gallery")

                navigation.init()

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

                # we are done loading the app. have the postman deliver that msg.
                $.publish "/postman/deliver", [ { message: ""}, "/app/ready" ]

                window.APP.app = new kendo.mobile.Application document.body, { platform: "android" }

                hideSplash = ->
                    $("#splash").kendoAnimate
                        effects: "fade:out"
                        duration: 1000,
                        hide: true
                setTimeout hideSplash, 100

                setTimeout ->
                    printer.prompt()
                , 1000

                $.subscribe "/keyboard/close", ->
                    $.publish "/postman/deliver", [ null, "/window/close" ]

            $.publish "/postman/deliver", [ null, "/localization/request" ]
            $.publish "/postman/deliver", [ null, "/effects/request" ]
            $.publish "/postman/deliver", [ null, "/printer/list" ]