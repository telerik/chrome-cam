define [], () ->
    'use strict'

    OFFSET = 10
    template = null
    destination = null
    slideDestination = null
    elements = []
    wrapper = null
    count = 0

    adjust = (element, offset, zindex) ->
        position = element.offset()

        position.top -= offset
        position.left += offset

        element.offset position
        element.css "z-index", zindex

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
                if progress.index == 0
                    slideDestination = $("<div />")
                    slideDestination.width wrapper.width()-1
                    slideDestination.height wrapper.height()-1
                    slideDestination.css position: "absolute"
                    slideDestination.offset wrapper.offset()

                    slideDestination.appendTo $("body")

                adjust container, OFFSET, container.css("z-index")-2
                # Adjust all of the images below it
                for element in elements
                    adjust element, OFFSET, element.css("z-index")-1

            $("<img />", src: file.file).appendTo container

            elements.push container

        run: (callback) ->
            last = elements.pop()
            console.log last

            deferreds = []

            for element in elements
                deferreds.push kendo.fx(element).transfer(slideDestination).duration(1000).play()
                deferreds.push kendo.fx(element).fade("out").duration(400).play()

            #deferreds = [kendo.fx(elements[0]).transfer(last).duration(2000).play()]
            #deferreds = ( for element in elements)
            $.when.apply($, deferreds).done ->
                kendo.fx(last).transfer(destination).duration(1000).play().done ->
                    last.remove()
                    slideDestination.remove()

                    for element in elements
                        element.remove()

                    elements = []
                    callback()
