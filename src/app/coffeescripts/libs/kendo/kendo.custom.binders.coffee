# custom bindings
kendo.data.binders.zoom = kendo.data.Binder.extend
    refresh: ->
        value = this.bindings["zoom"].get()
        visible = $(this.element).is(":visible")

        console.log(value)
        console.log(visible)

        if value
            if not visible
                $(this.element).kendoStop(true).kendoAnimate
                	effects: "zoomIn fadeIn",
                	show: true
        if not value and visible
            $(this.element).kendoStop(true).kendoAnimate
            	effects: "zoomOut fadeOut",
            	show: true

# # custom bindings
# kendo.data.binders.slideUpDown = kendo.data.Binder.extend
#     refresh: ->
#         value = this.bindings["slideUpDown"].get();

#         if value
#             $(this.element).kendoStop(true).kendoAnimate
#                 effects: "slideIn:up",
#                 show: true
#         else
#             $(this.element).kendoStop(true).kendoAnimate
#                 effects: "slide:down",
#                 show: true