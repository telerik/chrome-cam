define([

], () ->

pub = 

    init: ->

        # bind to the left and right arrow key presses
        $(document).keydown (e) ->
            arrowKeys =
                37: "left"
                39: "right"
                38: "up"
                40: "down"

            if e.keyCode of arrowKeys
                $.publish "/events/key/arrow", arrowKeys[e.keyCode]
)