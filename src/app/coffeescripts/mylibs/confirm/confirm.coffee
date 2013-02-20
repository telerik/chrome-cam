define [
    'Kendo'
], (kendo) ->

    view = {}
    @callback = null
    open = false

    pub =
        yes: (e) =>
            view.data("kendoMobileModalView").close()

            $.publish "/tabbing/restore", [ $(document.body) ]
            $(document.body).focus()

            open = false
            if @callback
                @callback()

        no: (e) ->
            open = false
            view.data("kendoMobileModalView").close()

            $.publish "/tabbing/restore", [ $(document.body) ]
            $(document.body).focus(())

        init: (selector) =>

            # view = new kendo.View(selector, template)
            # view.render(viewModel, true)
            view = $(selector)

            $.subscribe "/confirm/show", (title, message, callback) =>

                @callback = callback

                view.find(".title").html(title)
                view.find(".message").html(message)

                view.find(".yes").text window.APP.localization.yesButton
                view.find(".no").text window.APP.localization.noButton

                view.data("kendoMobileModalView").open()

                # HACK: This should probably be done in a better way.
                $.publish "/tabbing/remove", [ $(document.body) ]
                $.publish "/tabbing/restore", [ view ]
                setTimeout (->
                    view.find(".yes").focus()
                ), 250

                open = true

            esc = ->
                if open
                    pub.no()
                    return false

            $.subscribe "/keyboard/esc", esc, true

