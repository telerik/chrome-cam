define [], ->
    pub =
        init: (filters) ->
            pub.items = filters
        items: []
        page:
            size: 20