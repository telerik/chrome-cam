define ['utils/utils', 'everlive/everlive'], (utils, everlive) ->
    send = (args, file) ->
        photos = Everlive.$.data('Photo')
        photos.create ImageUrl: file.Uri, Email: args.email, (data) ->
            # hooray!

    upload = (args) ->
        data = new FormData()
        data.append 'Filename', 'photo.png'
        data.append 'ContentType', 'image/png'
        data.append 'data', utils.toBlob(args.image)

        everlive.done (el) ->
            s = el.setup

            opts =
                type: 'POST'
                url: "#{s.scheme}:#{s.url}#{s.apiKey}/Files"
                headers:
                    Authorization: 'Bearer ' + s.token
                data: data
                contentType: false
                processData: false

            $.ajax(opts).done (response) ->
                file = response.Result[0]
                send args, file

    pub =
        init: ->
            $.subscribe "/email/post", upload