define [ 'utils/utils' ], (utils) ->
    keydown = (e) ->
        return unless e.which is utils.keys.space or e.which is utils.keys.enter

        target = $(e.target)
        if target.data("role") == "button"
            target.data("kendoMobileButton").trigger "click", { target: e.target }
        else if target.data("role") == "clickable"
            target.data("kendoMobileClickable").trigger "click", { target: e.target }

    removeTabs = (parent) ->
        $("[tabindex]", parent).each ->
            tabbable = $(this)
            tabbable.attr "data-old-tabindex", tabbable.attr("tabindex")
            tabbable.attr "tabindex", -1

    restoreTabs = (parent) ->
        $("[data-old-tabindex]", parent).each ->
            tabbable = $(this)
            tabbable.attr "tabindex", tabbable.attr("data-old-tabindex")
            tabbable.removeAttr "data-old-tabindex"

    pub =
        init: ->
            $(document.body).on "keydown", "[data-tabbable]", keydown

            $.subscribe "/tabbing/remove", removeTabs
            $.subscribe "/tabbing/restore", restoreTabs