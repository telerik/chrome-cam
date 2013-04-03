define [], ->
    view = null
    modal = ->
        view.data("kendoMobileModalView")
    pub =
        init: ->
            view = $("#emailShare")
            $.subscribe "/email/send", (image) ->
                pub.show image
        show: (image) ->
            $.publish "/gallery/keepAlive", [ true ]
            view.find("[name=recipient]").val ""
            view.find(".email-preview").attr "src", image.src
            modal().open()
        confirm: ->
            $.publish "/gallery/keepAlive", [ false ]
            modal().close()
        cancel: ->
            $.publish "/gallery/keepAlive", [ false ]
            modal().close()