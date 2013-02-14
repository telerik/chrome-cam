define [
  'Kendo'
  'mylibs/utils/utils'
  'mylibs/file/filewrapper'
  'text!mylibs/gallery/views/details.html'
], (kendo, utils, filewrapper, template) ->

    index = 0

    visible = false
    details = {}

    viewModel = kendo.observable
        video:
            src: -> utils.placeholder.image()
        img:
            src: -> utils.placeholder.image()
        type: "jpeg"
        isVideo: ->
            @get("type") == "webm"
        next:
            visible: false
        previous:
            visible: false

    hide = ->
        $.publish "/top/update", ["gallery"]
        $.publish "/gallery/keyboard"
        details.container.kendoStop(true).kendoAnimate
            effects: "zoomOut"
            hide: true
            complete: ->
                $.unsubscribe "/gallery/delete"

    show = (message) ->
        update(message)
        details.container.kendoStop(true).kendoAnimate
            effects: "zoomIn"
            show: true
            complete: ->
                $.publish "/top/update", ["details"]
                $.subscribe "/gallery/delete", ->
                    hide()

    update = (message) ->
        filewrapper.readFile(message.item).done (data) =>
            viewModel.set("type", message.item.type)
            viewModel.set("img.src", data.file)
            viewModel.set("next.visible", message.index < message.length - 1)
            viewModel.set("previous.visible", message.index > 0 and message.length > 1)
            index = message.index

    pub =

        init: (selector) ->

            that = @

            details = new kendo.View(selector, template)
            details.render(viewModel, true)

            # subscribe to events
            $.subscribe "/details/hide", ->
                visible = false
                hide()

            $.subscribe "/details/show", (message) ->
                visible = true
                show(message)

            $.subscribe "/details/update", (message) =>
                update(message)

            page = (direction) ->
                return unless visible

                if direction is "left" and viewModel.previous.visible
                    that.previous()
                if direction is "right" and viewModel.next.visible
                    that.next()
                return false

            $.subscribe "/keyboard/arrow", page, true
            $.subscribe "/keyboard/esc", hide

        next: (e) ->
            $.publish "/gallery/at", [index + 1]

        previous: (e) ->
            $.publish "/gallery/at", [index - 1]
