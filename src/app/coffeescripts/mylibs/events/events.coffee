define([

], () ->

    pub = 

        init: ->

            p = (name, key) ->
                $.publish "/keyboard/#{name}", [key]

            # bind to the left and right arrow key presses
            $(document).keydown (e) ->
                switch e.keyCode
                    when 37 then p("arrow", "left")
                    when 39 then p("arrow", "right")
                    when 38 then p("arrow", "up")
                    when 40 then p("arrow", "down")
                    when 27 then p("esc", "esc")
)