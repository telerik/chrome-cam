define [
  'Kendo'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'text!mylibs/full/views/full.html'
], (kendo, utils, filewrapper, template) ->
    paused = true
    frame = 0
    full = {}
    effectId = ""

    paparazzi = {}

    capture = (callback, progress) ->
        captured = $.subscribe "/captured/image", (file) ->
            $.unsubscribe captured
            $.publish "/gallery/add", [file]

            callback()

        $.publish "/postman/deliver", [ progress, "/camera/capture" ]

    index =
        current: ->
            # return is compulsory here; otherwise CoffeeScript will build an array.
            return i for i in [0...APP.filters.length] when APP.filters.id is effectId
        max: ->
            APP.filters.length
        select: (i) ->
            pub.select APP.filters[i]
        preview: (i) ->
            pub.select APP.filters[i], true
        unpreview: ->
            pub.select APP.filters[index.saved]
        saved: 0

    subscribe = (pub) ->
        $.subscribe "/full/show", (item) ->
            pub.show(item)

        $.subscribe "/camera/snapshot", (url) ->
            full.el.snapshot.attr "src", url

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
            full.find(".wrapper", "wrapper")
            full.find(".snapshot", "snapshot")
            full.find(".paparazzi", "paparazzi")
            full.find(".filters-list", "filters")

    pub =

        init: (selector) ->

            full = new kendo.View(selector, template)
            full.render()

            # find and cache the necessary elements
            elements.cache full

            # subscribe to external events an map them to internal functions
            subscribe pub

        before: ->
            setTimeout (->
                $.publish "/postman/deliver", [{ paused: false }, "/camera/pause"]
            ), 500

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
            effectId = item.id
            unless temp
                full.el.filters.find("li").removeClass("selected").filter("[data-filter-id=#{item.id}]").addClass("selected")
            $.publish "/postman/deliver", [ effectId, "/effects/select" ]

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

            callback = ->
                callback = ->
                    callback = ->
                        $.publish "/bottom/update", [ "full" ]
                    setTimeout (-> capture callback, index: 2, count: 3) , 1000
                setTimeout (-> capture callback, index: 1, count: 3), 1000
            capture callback, index: 0, count: 3
