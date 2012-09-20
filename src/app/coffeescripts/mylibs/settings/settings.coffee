define [
    'Kendo'
    'text!mylibs/settings/views/settings.html' 
], (kendo, template) ->

    view = null
    viewModel = { }

    show = (selector) ->
        window.APP.app.navigate selector

    pub = 
        init: (selector) ->
            view = new kendo.View(selector, template)
            view.render(viewModel, true)

            $.subscribe '/menu/click/chrome-cam-settings-menu', ->
                show selector