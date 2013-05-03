define ['utils/utils', 'everlive/everlive'], (utils, everlive) ->
    upload = (args) ->
        data = new FormData()
        data.append 'Filename', 'photo.png'
        data.append 'ContentType', 'image/png'
        data.append 'data', utils.toBlob(args.image)

        everlive.done (el) ->
            s = el.setup

            photos = Everlive.$.data('Photo')
            photos.create ImageUrl: args.image, Email: args.email, (data) ->

    pub =
        init: ->
            $.subscribe "/email/post", upload