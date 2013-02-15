define [
    'Kendo'
    'mylibs/navigation/navigation'
    'text!mylibs/about/views/about.html'
], (kendo, navigation, template) ->

    previous = "#home"

    viewModel = kendo.observable({})

    click = (e) ->
        $.publish "/postman/deliver", [ { link: e.target.href }, "/link/open" ]

    pub =

        # unlike the viewModel events, these events are for the mobile view itself
        before: ->
            $.publish "/postman/deliver", [{ paused: true }, "/camera/pause"]

        init: (selector) ->

            # create the about view
            view = new kendo.View(selector, template)
            view.render(viewModel, true)

            view.find("a").on "click", click

            # subscribe to the about event from the context menu
            $.subscribe '/menu/click/chrome-cam-about-menu', ->
                $.publish "/postman/deliver", [ false, "/menu/enable" ]
                previous = window.APP.app.view().id
                navigation.navigate selector

        back: ->
            $.publish "/postman/deliver", [ true, "/menu/enable" ]
            navigation.navigate previous

        clear: ->
            $.publish "/confirm/show", [
                window.APP.localization.clear_gallery_dialog_title,
                window.APP.localization.clear_gallery_confirmation,
                ->
                    $.publish("/gallery/clear")
                    navigation.navigate "#home"
            ]


