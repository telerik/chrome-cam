define [], ->
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