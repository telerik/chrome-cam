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
            view.find("[name=recipient]").val ""
            view.find(".email-preview").attr "src", image.src
            modal().open()
        confirm: ->
            modal().close()
        cancel: ->
            modal().close()