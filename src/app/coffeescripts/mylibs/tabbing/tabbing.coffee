define [ 'mylibs/utils/utils' ], (utils) ->
    pub =
        init: ->
            $(document.body).on "keydown", "*[data-tabable]", (e) ->
                return unless e.which is utils.keys.space or e.which is utils.keys.enter

                target = $(e.target)
                if target.data("role") == "button"
                    target.data("kendoMobileButton").trigger "click", e
                else if target.data("role") == "clickable"
                    target.data("kendoMobileClickable").trigger "click", e
                else
                    target.trigger "click", e
