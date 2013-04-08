define [], ->
    view = null
    state = {}
    modal = ->
        view.data("kendoMobileModalView")
    pub =
        init: ->
            view = $("#emailShare")
            $.subscribe "/email/send", (image) ->
                pub.show image
        show: (image) ->
            state.image = image
            $.publish "/gallery/keepAlive", [ true ]
            view.find("[name=recipient]").val ""
            view.find(".email-preview").attr "src", image.src
            modal().open()
        confirm: ->
            args =
                image: state.image.src
                email: view.find("[name=recipient]").val()

            $.publish "/postman/deliver", [ args, "/email/post" ]

            $.publish "/gallery/keepAlive", [ false ]
            modal().close()
        cancel: ->
            $.publish "/gallery/keepAlive", [ false ]
            modal().close()