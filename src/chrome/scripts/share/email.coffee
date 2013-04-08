define ['utils/utils'], (utils) ->
    send = (args) ->
        data = new FormData()
        data.append "email", args.email
        data.append "file", utils.toBlob(args.image)

        $.ajax
            url: 'http://camera-kiosk.appspot.com/send'
            type: 'POST'
            data: data
            cache: false
            contentType: false
            processData: false
    pub =
        init: ->
            $.subscribe "/email/post", send