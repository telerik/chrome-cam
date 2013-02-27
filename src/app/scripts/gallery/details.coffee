define [
  'utils/utils'
  'file/filewrapper'
  'text!views/gallery/details.html'
], (utils, filewrapper, template) ->

    index = 0

    visible = false
    details = {}
    tokens = {}
    token = null
    updating = false

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

    page = (direction) ->
        return unless visible or not updating

        if direction is "left" and viewModel.previous.visible
            updating = true
            pub.previous()
        if direction is "right" and viewModel.next.visible
            updating = true
            pub.next()
        return false

    hide = ->
        $.publish "/galleryBar/update", ["gallery"]
        $.publish "/gallery/keyboard", [ true ]
        $.publish "/details/hiding"

        keys.unbind()

        $.unsubscribe tokens.delete
        tokens.delete = null

        kendo.fx(details.container).zoom("out").play()

    show = (message) ->
        update(message)

        keys.bind()

        tokens.delete = $.subscribe "/gallery/delete", ->
            hide()

        kendo.fx(details.container).zoom("in").play().done ->
            $.publish "/details/shown"
            $.publish "/galleryBar/update", ["details"]

    update = (message) ->
        filewrapper.readFile(message.item).done (data) =>
            viewModel.set("type", message.item.type)
            viewModel.set("img.src", data.file)
            viewModel.set("next.visible", message.index < message.length - 1)
            viewModel.set("previous.visible", message.index > 0 and message.length > 1)
            index = message.index
            updating = false

    keys =
        bound: false,
        bind: ->
            return if @bound

            tokens.arrow = $.subscribe "/keyboard/arrow", page, true
            tokens.esc = $.subscribe "/keyboard/esc", hide

            @bound = true

        unbind: ->
            return unless @bound

            $.unsubscribe tokens.arrow
            $.unsubscribe tokens.esc

            @bound = false

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

            $.subscribe "/details/keyboard", (bind) ->
                if bind
                    keys.bind()
                else
                    keys.unbind()

        next: (e) ->
            $.publish "/gallery/at", [index + 1]

        previous: (e) ->
            $.publish "/gallery/at", [index - 1]
