define [
    'utils/utils'
    'file/filewrapper'
    'navigation/navigation'
    'text!views/full.html'
    'text!views/filterlist.html'
], (utils, filewrapper, navigation, template, filterlist) ->
    paused = true
    frame = 0
    full = {}
    effectId = "normal"

    paparazzi = {}
    tokens = {}

    capture = (callback, progress) ->
        captured = $.subscribe "/captured/image", (file) ->
            $.unsubscribe captured
            $.publish "/gallery/add", [file]

            callback()

        $.publish "/postman/deliver", [ progress, "/camera/capture" ]

    index =
        current: ->
            # return is compulsory here; otherwise CoffeeScript will build an array.
            return i for i in [0...APP.filters.items.length] when APP.filters.items[i].id is effectId
        max: ->
            APP.filters.items.length
        select: (i) ->
            pub.select APP.filters.items[i]
        preview: (i) ->
            pub.select APP.filters.items[i], true
        unpreview: ->
            pub.select APP.filters.items[index.saved]
        saved: 0

    arrow = (dir) ->
        return if paused

        if dir is "up" and index.current() > 0
            index.select index.current() - 1
        if dir is "down" and index.current() + 1 < index.max()
            index.select index.current() + 1

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
                tokens.keyboard = $.subscribe "/keyboard/arrow", arrow

                full.el.filters.kendoStop().kendoAnimate
                    effects: "slideIn:right fade:in"
                    show: true
                    hide: false
                    duration: duration
            else
                $.unsubscribe tokens.keyboard
                tokens.keyboard = null

                full.el.filters.kendoStop().kendoAnimate
                    effects: "slide:left fade:out"
                    hide: true
                    show: false
                    duration: duration

        $.subscribe "/full/capture/begin", (mode) ->
            $.publish "/postman/deliver", [ mode, "/camera/capture/prepare" ]
            full.el.wrapper.addClass "capturing"

        $.subscribe "/full/capture/end", ->
            full.el.wrapper.removeClass "capturing"

    elements =
        cache: (full) ->
            full.find(".timer", "timer")
            full.find(".wrapper", "wrapper")
            full.find(".snapshot", "snapshot")
            full.find(".paparazzi", "paparazzi")
            full.find(".filters-list", "filters")

    navigating =
        to: ->
            deferred = $.Deferred()

            paused = false
            APP.bottom.pause false

            updated = $.subscribe "/camera/updated", ->
                $.unsubscribe updated

                token = $.subscribe "/camera/snapshot/response", (url) ->
                    $.unsubscribe token
                    full.el.snapshot.attr "src", url
                    deferred.resolve()

                $.publish "/postman/deliver", [ null, "/camera/snapshot/request" ]

            $.publish "/postman/deliver", [ null, "/camera/update" ]

            return deferred.promise()

        from: ->
            deferred = $.Deferred()

            paused = true
            APP.bottom.pause true

            token = $.subscribe "/camera/snapshot/response", (url) ->
                $.unsubscribe token
                full.el.snapshot.attr "src", url
                deferred.resolve()

            $.publish "/postman/deliver", [ null, "/camera/snapshot/request" ]

            return deferred.promise()

    pub =
        init: (selector) ->

            full = new kendo.View(selector, template)
            full.render()

            navigation.navigating.to "#home", navigating.to
            navigation.navigating.from "#home", navigating.from

            # find and cache the necessary elements
            elements.cache full

            filters = kendo.template(filterlist)
            full.el.filters.html(filters({}))

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
            $.publish "/postman/deliver", [ effectId, "/camera/effect" ]

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
            page: (e) ->
                i = $(e.target).data('filter-page')
                $("#filter-scrollview").data("kendoMobileScrollView").scrollTo i
        photo: ->
            callback = ->
                $.publish "/bottom/update", [ "full" ]
                $.publish "/full/capture/end"

            capture callback, index: 0, count: 1

        paparazzi: ->

            callback = ->
                callback = ->
                    callback = ->
                        $.publish "/bottom/update", [ "full" ]
                        $.publish "/full/capture/end"
                    setTimeout (-> capture callback, index: 2, count: 3) , 1000
                setTimeout (-> capture callback, index: 1, count: 3), 1000
            capture callback, index: 0, count: 3
