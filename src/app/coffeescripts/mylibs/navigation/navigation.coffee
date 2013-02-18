define [], ->
    "use strict"

    callbacks =
        to: {}
        from: {}
        always: []

    pub =
        navigate: (view) ->
            deferreds = []


            previous = window.APP.app.view().id

            callback(previous, view) for callback in callbacks.always

            if previous of callbacks.from
                deferreds.push callback() for callback in callbacks.from[previous]

            if view of callbacks.to
                deferreds.push callback() for callback in callbacks.to[view]

            $.when.apply($, deferreds).done ->
                window.APP.app.navigate view

        navigating:
            always: (callback) ->
                callbacks.always.push callback

            to: (view, callback) ->
                unless view of callbacks.to
                    callbacks.to[view] = []
                callbacks.to[view].push callback

            from: (view, callback) ->
                unless view of callbacks.from
                    callbacks.from[view] = []
                callbacks.from[view].push callback

