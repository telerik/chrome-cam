define [ 'mylibs/utils/utils' ], (utils) ->
    level = 0

    keydown = (e) ->
        return unless e.which is utils.keys.space or e.which is utils.keys.enter

        target = $(e.target)
        if target.data("role") == "button"
            target.data("kendoMobileButton").trigger "click", e
        else if target.data("role") == "clickable"
            target.data("kendoMobileClickable").trigger "click", e

    removeTabindices = ->
        $("[data-tabbable]").attr "tabindex", -1

    setLevel = (level) ->
        @level = level

        removeTabindices()

        # This is hacky, but kendo seems to be storing the view we're
        # navigating to in memory. So if we make changes to it in the DOM, it'll
        # be overwritten by the (older) copy kendo keeps in memory. We need to wait
        # for the transition to finish before we can set the tabindex's.
        setTimeout (->
            $("[data-tab-level='#{level}']").attr "tabindex", 0
            $("[data-tab-level='#{level}'][data-default-action]").focus()
        ), 400

    pub =
        init: ->
            $(document.body).on "keydown", "[data-tabbable]", keydown

            $.subscribe "/tabbing/level/set", setLevel
            $.subscribe "/tabbing/refresh", ->
                $("[data-tab-level='#{level}']").attr "tabindex", 0