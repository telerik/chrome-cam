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
            recipient = view.find("[name=recipient]")
            recipient.removeClass "error"

            if /^\s*$/.test(recipient.val())
                recipient.addClass "error"
                return

            args =
                image: state.image.src
                email: recipient.val()

            $.publish "/postman/deliver", [ args, "/email/post" ]

            $.publish "/gallery/keepAlive", [ false ]
            modal().close()
        cancel: ->
            $.publish "/gallery/keepAlive", [ false ]
            modal().close()