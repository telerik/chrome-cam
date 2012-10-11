define [], () ->

    key =
        arrows:
            up: 38
            down: 40
            left: 37
            right: 39
        esc: 27
        space: ' '.charCodeAt(0)
        w: 'W'.charCodeAt(0)

    pub = 

        init: ->

            p = (name, key) ->
                $.publish "/keyboard/#{name}", [key]

            # bind to the left and right arrow key presses
            $(document).keydown (e) ->
                switch e.which
                    when key.arrows.left then p("arrow", "left")
                    when key.arrows.right then p("arrow", "right")
                    when key.arrows.up then p("arrow", "up")
                    when key.arrows.down then p("arrow", "down")
                    when key.esc then p("esc", "esc")
                    when key.space then p("space", ctrlKey: e.ctrlKey or e.metaKey)
                    when key.w then p("close") if e.ctrlKey or e.metaKey