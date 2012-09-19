define [
    'Kendo'
    'text!mylibs/settings/views/settings.html' 
], (kendo, template) ->

    view = null
    viewModel = { }

    show = ->
        view.container.kendoStop(true).kendoAnimate
            effects: "zoomIn"
            show: true

    pub = 
        init: (selector) ->
            view = new kendo.View(selector, template)
            view.render(viewModel, true)

            $.subscribe "/settings/show", show
