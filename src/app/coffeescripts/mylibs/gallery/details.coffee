define [
  'Kendo' 	
  'text!mylibs/gallery/views/details.html'
], (kendo, template) ->

    index = 0

    viewModel = kendo.observable {
        src: null
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

	# viewModel = kendo.observable {
	# 	close: ->
 #            $.publish "/gallery/details/hide"
 #        canGoToNext: ->
 #            @get("indexInGallery") > 0
 #        canGoToPrevious: ->
 #            @get("indexInGallery") < files.length - 1
 #        goToNext: ->
 #            @init files[@get("indexInGallery") - 1]
 #        goToPrevious: ->
 #            @init files[@get("indexInGallery") + 1]
 #        getIndexInGallery: ->
 #            return i for i in [0...files.length] when files[i].name == @get("filename")
	# }

    hide = =>
        @details.container.kendoStop(true).kendoAnimate
            effects: "zoomOut"
            hide: true

    show = (message) =>
        update(message)
        @details.container.kendoStop(true).kendoAnimate
            effects: "zoomIn"
            show: true 	
            complete: ->
                $.publish "/top/update", ["details"]

    update = (message) ->
        viewModel.set("src", message.item.file)
        viewModel.set("next.visible", message.index < message.length)
        viewModel.set("previous.visible", message.index > 0 and message.length > 1)
        index = message.index
        console.log message.index

    pub = 

        init: (selector) =>

            @details = new kendo.View(selector, template)
            @details.render(viewModel, true)

            # subscribe to events
            $.subscribe "/details/hide", ->
                hide()

            $.subscribe "/details/show", (message) ->
                show(message)

            $.subscribe "/details/update", (message) ->
                update(message)