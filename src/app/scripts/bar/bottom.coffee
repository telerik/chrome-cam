define [
    'utils/utils'
    'navigation/navigation'
    'text!views/bar/bottom.html'
    'text!views/bar/thumbnail.html'
], (utils, navigation, template, thumbnailTemplate) ->

    BROKEN_IMAGE = utils.placeholder.image()

    paused = false

    view = {}

    # create a view model for the top bar
    viewModel = kendo.observable
        processing:
            visible: false

        mode:
            visible: false
            active: "photo"

        capture:
            visible: true

        thumbnail:
            src: BROKEN_IMAGE
            visible: ->
                return @get("enabled") && @get("active")
            enabled: false
            active: true

        filters:
            visible: false
            open: false
            css: ->

    countdown = (position, callback) ->

        $("span", view.el.counters[position]).kendoStop(true).kendoAnimate
            effects: "zoomIn fadeIn",
            duration: 200,
            show: true,
            complete: ->
                # fade in the next dot!
                ++position

                if position < 3
                    setTimeout ->
                        countdown position, callback
                    , 500
                else
                    callback()

                    # hide the counters
                    view.el.counters.hide()
                    $("span", view.el.counters).hide()

    states =
        capture: ->
            viewModel.set "mode.visible", false
            viewModel.set "capture.visible", false
            viewModel.set "filters.visible", false
            viewModel.set "thumbnail.visible", false
        full: ->
            viewModel.set "mode.visible", true
            viewModel.set "capture.visible", true
            viewModel.set "filters.visible", true
            viewModel.set "thumbnail.visible", true
        set: (state) ->
            this[state]()

    pub =

        pause: (pausing) ->
            paused = pausing

        init: (container) ->
            # create the bottom bar for the gallery
            view = new kendo.View(container, template)

            # render the bar and binds it to the view model
            view.render(viewModel, true)

            # find the thumbnail anchor container
            view.find(".galleryLink", "galleryLink")

            # wire up events
            $.subscribe "/bottom/update", (state) ->
                states.set(state)

            $.subscribe "/bottom/thumbnail", (file) ->
                view.el.galleryLink.empty()

                if file
                    thumbnail = new kendo.View(view.el.galleryLink, thumbnailTemplate, file)
                    thumbnail.render()
                    viewModel.set("thumbnail.enabled", true)
                else
                    viewModel.set("thumbnail.enabled", false)

            $.subscribe "/keyboard/space", (e) ->
                return if paused
                pub.capture e if viewModel.get("capture.visible")

            # get a reference to the dots.
            # TODO: this sucks. fix it with custom
            # bindings instead of this crazy BS.
            view.find(".stop", "stop")
            view.find(".counter", "counters")
            view.find(".bar", "bar")
            view.find(".filters", "filters")
            view.find(".capture", "capture")

            return view

        capture: (e) ->
            mode = viewModel.get("mode.active")

            $.publish "/full/capture/begin", [ mode ]

            states.capture()

            # start the countdown
            capture = ->
                $.publish "/capture/#{mode}"

            $.publish "/countdown/#{mode}"
            if event.ctrlKey or event.metaKey
                capture()
            else
                view.el.counters.css "display": "block"
                countdown 0, capture

        filters: (e) ->
            viewModel.set "filters.open", not viewModel.filters.open
            view.el.filters.toggleClass "selected", viewModel.filters.open
            $.publish "/full/filters/show", [viewModel.filters.open]

        mode: (e) ->

            button = $(e.target).closest("button")

            viewModel.set "mode.active", button.data("mode")

            # loop through all of the buttons and remove the active class
            button.closest(".bar").find("button").removeClass "selected"

            # add the active class to this anchor
            button.addClass "selected"

        gallery: ->
            navigation.navigate "#gallery"

