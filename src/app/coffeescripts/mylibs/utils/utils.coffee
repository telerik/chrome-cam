define [ 'mylibs/file/filewrapper' ] , (filewrapper) ->

    ###     Utils

    This file contains utility functions and normalizations. This used to contain more functions, but
    most have been moved into the extension.

    ###

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
