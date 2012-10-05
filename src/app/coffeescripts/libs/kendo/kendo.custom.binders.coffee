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

kendo.data.binders.localeText = kendo.data.Binder.extend
    refresh: ->
        $(this.element).text APP.localization[this.bindings.localeText.path]

kendo.data.binders.localeHtml = kendo.data.Binder.extend
    refresh: ->
        $(this.element).html APP.localization[this.bindings.localeHtml.path]

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