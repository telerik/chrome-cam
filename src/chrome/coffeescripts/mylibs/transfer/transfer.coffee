define [], () ->
    'use strict'

    OFFSET = 7
    template = null
    destination = null
    elements = []
    wrapper = null

    slideIn = (element, index) ->
        deferred = $.Deferred()

        end = (event) ->
            element.off "webkitTransitionEnd", end
            deferred.resolve()

        element.on "webkitTransitionEnd", end

        element.addClass "slide-in-#{index}"
        return deferred.promise()

    slideOut = (element) ->
        end = (event) ->
            element.off "webkitTransitionEnd", end

            offset = element.offset()
            offset.left += OFFSET
            offset.top -= OFFSET

            element.offset offset
            element.removeClass "slide-out"

        element.on "webkitTransitionEnd", end
        element.addClass "slide-out"

    pub =
        init: ->
            template = $("#transfer-animation-template div")
            destination = $("#destination")
            wrapper = $(".wrapper")

        setup: ->
            elements = []

        add: (file, progress) ->
            container = template.clone()

            container.offset wrapper.offset()
            container.width wrapper.width()
            container.height wrapper.height()
            container.appendTo $("body")

            if progress.count > 0 and progress.index < progress.count-1
                container.css "z-index": container.css("z-index")-2
                slideOut container

                # Adjust all of the images below it
                for element in elements
                    element.css "z-index": element.css("z-index")-1
                    slideOut element

            $("<img />", src: file.file).appendTo container

            elements.push container

        run: (callback) ->
            last = elements.pop()

            deferreds = []

            deferreds = (slideIn element, key for element, key in elements)
            $.when.apply($, deferreds).done ->
                kendo.fx(last).transfer(destination).duration(1000).play().done ->
                    last.remove()

                    #for element in elements
                    #    element.remove()

                    elements = []
                    callback()