define [ 'mylibs/utils/utils' ], (utils) ->
    level = 0

    removeTabindices = ->
        $("[data-tabbable]").attr "tabindex", -1

    pub =
        init: ->
            $(document.body).on "keydown", "[data-tabbable]", (e) ->
                return unless e.which is utils.keys.space or e.which is utils.keys.enter

                target = $(e.target)
                if target.data("role") == "button"
                    target.data("kendoMobileButton").trigger "click", e
                else if target.data("role") == "clickable"
                    target.data("kendoMobileClickable").trigger "click", e
                else
                    target.trigger "click", e

        setLevel: (level) ->
            return unless @level != level

            @level = level

            deferred = $.Deferred()

            removeTabindices()

            # This is extremely hacky, but kendo seems to be storing the view we're
            # navigating to in memory. So if we make changes to it in the DOM, it'll
            # be overwritten by the (older) copy kendo keeps in memory. We need to wait
            # for the transition to finish before we can set the tabindex's.
            setTimeout (->
                $("[data-tab-level='#{level}']").attr "tabindex", 0
                $("[data-tab-level='#{level}'][data-default-action]").focus()
                deferred.resolve()
            ), 400

            return deferred.promise()

        refresh: ->
            $("[data-tab-level='#{level}']").attr "tabindex", 0