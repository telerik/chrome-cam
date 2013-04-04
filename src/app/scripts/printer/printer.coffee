define ["navigation/navigation"], (navigation) ->
    modal = null
    printers = []

    # HACK: This should probably be done in a better way.
    setup = ->
        $.publish "/postman/deliver", [ { paused: true }, "/camera/pause" ]
        $.publish "/postman/deliver", [ false, "/menu/enable" ]
        $.publish "/tabbing/remove", [ $(document.body) ]
        $.publish "/tabbing/restore", [ modal ]
    teardown = ->
        $.publish "/tabbing/restore", [ $(document.body) ]
        $.publish "/postman/deliver", [ { paused: false }, "/camera/pause" ]
        $.publish "/postman/deliver", [ true, "/menu/enable" ]
        $.publish "/postman/deliver", [ modal.find("select").val(), "/printer/select" ]

    pub =
        init: (data) ->
            printers = data
            modal = $("#printerList")
        select: ->
            teardown()
            modal.data("kendoMobileModalView").close()
            navigation.navigate "#home", skip: true
        prompt: ->
            navigation.navigate null, skip: true
            setup()
            
            options = ($("<option />", { text: p.displayName, value: p.id })[0] for p in printers)
            modal.find("select").html("").append($(options))
            modal.data("kendoMobileModalView").open()