define [], () ->
    'use strict'

    template = null
    destination = null
    transferrer = null
    wrapper = null

    pub =
        init: ->
            template = $("#transfer-animation-template div")
            destination = $("#destination")
            wrapper = $(".wrapper")

        setup: ->
            debugger
            transferrer = template.clone();

            transferrer.offset wrapper.offset()
            transferrer.width wrapper.width()
            transferrer.height wrapper.height()

            transferrer.appendTo $("body")

        add: (file) ->
            return unless transferrer != null

            $("<img />", src: file.file).appendTo transferrer

        run: (callback) ->
            return unless transferrer != null

            transferrer.kendoStop().kendoAnimate
                effects: "transfer",
                target: destination,
                duration: 1000,
                ease: "ease-in",
                complete: ->
                    transferrer.remove()
                    transferrer = null

                    callback()