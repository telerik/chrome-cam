define [
  'text!views/popover.html'
], (template) ->

    viewModel = {
        ok: ->
            $.publish "/gallery/delete"
            $("#popover").data("kendoMobilePopOver").close()
        cancel: ->
            $("#popover").data("kendoMobilePopOver").close()
    }

    pub =
        init: (selector) ->

            view = new kendo.View(selector, template)
            view.render(viewModel, true)

