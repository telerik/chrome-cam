define [ 'mylibs/utils/utils' ], (utils) ->
    pub =
        init: ->

            p = (name, key) ->
                $.publish "/keyboard/#{name}", [key]

            # bind to the left and right arrow key presses
            $(document).keydown (e) ->
                switch e.which
                    when utils.keys.arrows.left then p("arrow", "left")
                    when utils.keys.arrows.right then p("arrow", "right")
                    when utils.keys.arrows.up then p("arrow", "up")
                    when utils.keys.arrows.down then p("arrow", "down")
                    when utils.keys.esc then p("esc", "esc")
                    when utils.keys.space then p("space", ctrlKey: e.ctrlKey or e.metaKey)
                    when utils.keys.w then p("close") if e.ctrlKey or e.metaKey
                    when utils.keys.enter then p("enter")
                    when utils.keys.page.up then p("page", "up")
                    when utils.keys.page.down then p("page", "down")

