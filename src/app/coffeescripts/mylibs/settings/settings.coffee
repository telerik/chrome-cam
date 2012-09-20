define [
    'Kendo'
    'text!mylibs/settings/views/settings.html' 
], (kendo, template) ->

    view = null
    oldView = "#home"

    viewModel = kendo.observable
        show: ->
            oldView = window.APP.app.view().id
            window.APP.app.navigate "#settings"
        hide: ->
            window.APP.app.navigate oldView

    pub = 
        init: (selector) ->
            view = new kendo.View(selector, template)
            view.render(viewModel, true)

            $.subscribe '/menu/click/chrome-cam-settings-menu', ->
                viewModel.show()