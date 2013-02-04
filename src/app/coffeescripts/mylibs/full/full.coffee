define [
  'Kendo'
  'mylibs/effects/effects'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'text!mylibs/full/views/full.html'
  'text!mylibs/full/views/transfer.html'
], (kendo, effects, utils, filewrapper, template, transferImg) ->
    paused = true
    frame = 0
    full = {}
    transfer = {}
    effect = {}

    paparazzi = {}

    # the main draw loop which renders the live video effects
    draw = ->
        # subscribe to the app level draw event
        $.subscribe "/camera/stream", (stream) ->

            return if paused

            # increment the curent frame counter. this is used for animated effects
            # like old movie and vhs. most effects simply ignore this
            frame++

            # pass in the webgl canvas, the canvas that contains the
            # video drawn from the application canvas and the current frame.
            effects.advance stream.canvas
            effect canvas, stream.canvas, frame, stream.track

    capture = (callback) ->

        captured = $.subscribe "/captured/image", (file) ->
            $.unsubscribe captured
            $.publish "/gallery/add", [file]
            callback()

        $.publish "/postman/deliver", [ [], "/camera/capture" ]

    index =
        current: ->
            # return is compulsory here; otherwise CoffeeScript will build an array.
            return i for i in [0...effects.data.length] when effects.data[i].filter is effect
        max: ->
            effects.data.length
        select: (i) ->
            pub.select effects.data[i]
        preview: (i) ->
            pub.select effects.data[i], true
        unpreview: ->
            pub.select effects.data[index.saved]
        saved: 0

    subscribe = (pub) ->
        $.subscribe "/full/show", (item) ->
            pub.show(item)

        $.subscribe "/capture/photo", ->
            pub.photo()

        $.subscribe "/capture/paparazzi", ->
            pub.paparazzi()

        $.subscribe "/countdown/paparazzi", ->
             full.el.paparazzi.removeClass "hidden"

        $.subscribe "/full/filters/show", (show) ->
            duration = 200
            if show
                full.el.filters.kendoStop().kendoAnimate
                    effects: "slideIn:right fade:in"
                    show: true
                    hide: false
                    duration: duration
            else
                full.el.filters.kendoStop().kendoAnimate
                    effects: "slide:left fade:out"
                    hide: true
                    show: false
                    duration: duration

        $.subscribe "/full/capture/begin", ->
            full.el.wrapper.addClass "capturing"

        $.subscribe "/full/capture/end", ->
            full.el.wrapper.removeClass "capturing"

        $.subscribe "/keyboard/arrow", (dir) ->
            return if paused

            if dir is "up" and index.current() > 0
                index.select index.current() - 1
            if dir is "down" and index.current() + 1 < index.max()
                index.select index.current() + 1

    elements =
        cache: (full) ->
            full.find(".timer", "timer")
            full.find(".transfer", "transfer")
            full.find(".transfer img", "source")
            full.find(".wrapper", "wrapper")
            full.find(".paparazzi", "paparazzi")
            full.find(".filters-list", "filters")

    pub =

        init: (selector) ->

            full = new kendo.View(selector, template)

            # find and cache the necessary elements
            elements.cache full

            # subscribe to external events an map them to internal functions
            subscribe pub

        show: (item) ->

            return unless paused

            pub.select item

            paused = false

            full.container.kendoStop(true).kendoAnimate
                effects: "zoomIn fadeIn"
                show: true
                complete: ->
                    # show the record controls in the footer
                    $.publish "/bottom/update", [ "full" ]

        select: (item, temp) ->
            effect = item.filter
            unless temp
                full.el.filters.find("li").removeClass("selected").filter("[data-filter-id=#{item.id}]").addClass("selected")
            $.publish "/postman/deliver", [ item.tracks, "/tracking/enable" ]

        filter:
            click: (e) ->
                i = $(e.target).data("filter-index")
                index.saved = i
                index.select i
                # remove the selected class from any other filters
                # $(e.target).parent().children().removeClass("selected")
                # set this filter as selected
                # $(e.target).addClass("selected")
            mouseover: (e) ->
                index.preview $(e.target).data("filter-index")
            mouseout: (e) ->
                index.unpreview()
        photo: ->
            callback = ->
                $.publish "/bottom/update", [ "full" ]

            capture callback, index: 1, count: 1

        paparazzi: ->

            # build a gross callback tree and fling poo
            left = 4
            advance = ->
                full.el.wrapper.removeClass "paparazzi-#{left}"
                left -= 1
                full.el.wrapper.addClass "paparazzi-#{left}"

            callback = ->

                callback = ->

                    callback = ->
                        $.publish "/bottom/update", [ "full" ]
                        full.el.wrapper.removeClass "paparazzi-1"
                        full.el.paparazzi.addClass "hidden"

                    advance()
                    capture callback, index: 3, count: 3

                advance()
                capture callback, index: 2, count: 3

            advance()
            capture callback, index: 1, count: 3
