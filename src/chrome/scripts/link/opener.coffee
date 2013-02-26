define [], ->
    link = null
    pub =
        init: ->
            link = document.getElementById("opener")
            $.subscribe "/link/open", (data) ->
                link.href = data.link
                link.click()
