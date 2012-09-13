define [
  'Kendo' 	
  'text!mylibs/gallery/views/details.html'
], (kendo, template) ->

    viewModel = kendo.observable {
        src: null
        type: "jpeg"
        isVideo: ->
            @get("type") == "webm"
        previous:
            visible: false
            click: (e) ->
                console.log "previous"
        next: 
            visible: false
            click: (e) ->
                console.log "next"
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

    hide = ->
        details.container.kendoStop(true).kendoAnimate
            effects: "zoomOut"
            hide: true

    show = (message) ->
        details.container.kendoStop(true).kendoAnimate
            effects: "zoomIn"
            show: true 	
            complete: ->
                viewModel.set("src", message.src)
                $.publish "/top/update", ["details"]

    pub = 

        init: (selector) =>

            @details = new kendo.View(selector, template)
            details.render(viewModel, true)

            # subscribe to events
            $.subscribe "/details/hide", ->
                hide()

            $.subscribe "/details/show", (message) ->
                show(message)