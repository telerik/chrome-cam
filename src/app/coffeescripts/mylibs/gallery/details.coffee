define [
  'Kendo' 	
  'text!mylibs/gallery/views/details.html'
], (kendo, template) ->

    index = 0

    visible = false

    viewModel = kendo.observable {
        video: 
            src: -> "styles/images/photoPlaceholder.png"
        img:
            src: -> "styles/images/photoPlaceholder.png"
        type: "jpeg"
        isVideo: ->
            @get("type") == "webm"
        next: 
            visible: false
            click: (e) ->
                $.publish "/gallery/at", [index + 1]
        previous:
            visible: false
            click: (e) ->
                $.publish "/gallery/at", [index - 1]

    }

    hide = =>
        $.publish "/top/update", ["gallery"]
        @details.container.kendoStop(true).kendoAnimate
            effects: "zoomOut"
            hide: true
            complete: ->
                $.unsubscribe "/gallery/delete"

    show = (message) =>
        update(message)
        @details.container.kendoStop(true).kendoAnimate
            effects: "zoomIn"
            show: true 	
            complete: ->
                $.publish "/top/update", ["details"]
                $.subscribe "/gallery/delete", ->
                    hide()

    update = (message) ->
        viewModel.set("type", message.item.type)
        if viewModel.get("type") == "webm"
            viewModel.set("video.src", message.item.file)
        else
            viewModel.set("img.src", message.item.file)
        viewModel.set("next.visible", message.index < message.length - 1)
        viewModel.set("previous.visible", message.index > 0 and message.length > 1)
        index = message.index
        console.log message.index

    pub = 

        init: (selector) =>

            @details = new kendo.View(selector, template)
            @details.render(viewModel, true)

            # subscribe to events
            $.subscribe "/details/hide", ->
                visible = false
                hide()

            $.subscribe "/details/show", (message) ->
                visible = true
                show(message)

            $.subscribe "/details/update", (message) =>
                update(message)

            $.subscribe "/keyboard/arrow", (direction) ->
                return unless visible
                if direction is "left" and viewModel.previous.visible
                    viewModel.previous.click()
                if direction is "right" and viewModel.next.visible
                    viewModel.next.click()
