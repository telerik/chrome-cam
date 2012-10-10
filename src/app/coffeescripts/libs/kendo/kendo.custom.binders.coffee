# custom bindings
kendo.data.binders.zoom = kendo.data.Binder.extend
    refresh: ->
        value = this.bindings["zoom"].get()
        visible = $(this.element).is(":visible")

        if value
            if not visible
                $(this.element).kendoStop(true).kendoAnimate
                    effects: "zoomIn fadeIn",
                    show: true
        if not value and visible
            $(this.element).kendoStop(true).kendoAnimate
                effects: "zoomOut fadeOut",
                show: true

kendo.data.binders.localeText = kendo.data.Binder.extend
    refresh: ->
        $(this.element).text APP.localization[this.bindings.localeText.path]

kendo.data.binders.localeHtml = kendo.data.Binder.extend
    refresh: ->
        $(this.element).html APP.localization[this.bindings.localeHtml.path]

kendo.data.binders.localeTitle = kendo.data.Binder.extend
    refresh: ->
        $(this.element).attr "title", APP.localization[this.bindings.localeTitle.path]
