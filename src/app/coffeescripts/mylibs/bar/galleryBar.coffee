define [
    'Kendo'
    'mylibs/navigation/navigation'
    'mylibs/file/filewrapper'
    'text!mylibs/bar/views/galleryBar.html'
], (kendo, navigation, filewrapper, template) ->

    # create a view model for the top bar
    # VIEW MODEL ISN'T WORKING. WHY NOT?
    viewModel = kendo.observable
        current: null
        selected: false
        back:
            details: false
            text: "< Camera"

    # TODO: Refactor Once View Model Is Working
    states =
        selected: ->
            viewModel.set("selected", true)
        deselected: ->
            viewModel.set("selected", false)
        details: =>
            viewModel.set("back.text", "< Gallery")
            viewModel.set("back.details", true)
            $.publish "/gallery/details", [true]
        gallery: =>
            viewModel.set("back.text", "< Camera")
            viewModel.set("back.details", false)
            $.publish "/gallery/details", [false]
        set: (state) ->
            states.current = state
            states[state]()

    pub =

        init: (container) =>

            # create the bottom bar for the gallery
            view = new kendo.View(container, template)

            # render the bar and binds it to the view model
            view.render(viewModel, true)

            # find and cache some DOM elements
            back = view.find(".back.button")

            # wire up events
            $.subscribe "/galleryBar/update", (state) ->
                states.set state

            $.subscribe "/item/selected", (message) ->
                viewModel.set("current", message.item)

            $.subscribe "/keyboard/esc", ->
                if states.current == "details"
                    states.set "gallery"
                    back.trigger "click"

        back: (e) ->

            $.publish "/details/hide"
            states.gallery()
            e.preventDefault()

        destroy: (e) ->
            view = if viewModel.get("back.details") then "details" else "gallery"

            $.publish "/#{view}/keyboard", [ false ]

            $.publish "/confirm/show", [
                window.APP.localization.delete_dialog_title,
                window.APP.localization.delete_confirmation,
                (destroy) ->
                    $.publish "/#{view}/keyboard", [ true ]
                    if destroy
                        $.publish "/gallery/delete"
            ]

        save: (e) ->
            filewrapper.download viewModel.get("current")

        home: (e) ->
            navigation.navigate "#home"
