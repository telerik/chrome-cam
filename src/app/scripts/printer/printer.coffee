define [], ->
    modal = null
    printers = []
    pub =
        select: ->
            $.publish "/tabbing/restore", [ $(document.body) ]
            $.publish "/postman/deliver", [ { paused: false }, "/camera/pause" ]
            $.publish "/postman/deliver", [ modal.find("select").val(), "/printer/select" ]
            modal.data("kendoMobileModalView").close()
        init: (data) ->
            printers = data
            modal = $("#printerList")
        prompt: ->
            $.publish "/postman/deliver", [ { paused: true }, "/camera/pause" ]
            $.publish "/postman/deliver", [ false, "/menu/enable" ]
            # HACK: This should probably be done in a better way.
            $.publish "/tabbing/remove", [ $(document.body) ]
            $.publish "/tabbing/restore", [ modal ]
            
            options = ($("<option />", { text: p.displayName, value: p.id })[0] for p in printers)
            modal.find("select").html("").append($(options))
            modal.data("kendoMobileModalView").open()