define [], ->
    pub =
        placeholder:
            image: ->
                "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="

        oppositeDirectionOf: (dir) ->
            switch dir
                when "left" then "right"
                when "right" then "left"
                when "up" then "down"
                when "down" then "up"

        debounce: (fn, wait) ->
            timeout = null
            wrapped = ->
                clearTimeout timeout if timeout
                bounce = ->
                    timeout = null
                    fn()
                timeout = setTimeout(bounce, wait)

        keys:
            arrows:
                up: 38
                down: 40
                left: 37
                right: 39
            esc: 27
            space: ' '.charCodeAt(0)
            enter: 13
            w: 'W'.charCodeAt(0)
            page:
                up: 33
                down: 34
