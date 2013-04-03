define [
    'utils/utils'
    'file/filewrapper'
    'navigation/navigation'
    'text!views/gallery/thumb.html'
], (utils, filewrapper, navigation, template) ->
    columns = 3
    rows = 3
    pageSize = columns * rows

    files = []
    ds = {}
    data = []
    container = {}
    el = {}
    selected = {}
    total = 0
    index = 0
    flipping = false
    pages =
        previous: {}
        next: {}
    active = {}
    details = false
    keyboard = {}
    keepAlive = false

    back = ->
        navigation.navigate "#home" unless keepAlive
    refresh = utils.debounce(back, 15000)

    navigation.navigating.to "#gallery", ->
        refresh()

    animation =
        effects: "pageturn:horizontal"
        reverse: false
        duration: 800

    deselect = =>
        container.find(".thumbnail").removeClass "selected"
        selected = null
        $.publish "/galleryBar/update", [ "deselected" ]

    select = (name) =>
        refresh()
        # find the item with the specified name
        item = container.find("[data-name='#{name}']")
        selected = item.parent(":first")

        # if this item already has the "selected class", this is the second
        # click which will open the details view
        if selected.hasClass("selected")
            keys.unbind()

            $.publish "/details/show", [ get("#{item.data("name")}") ]
        else
            container.find(".thumbnail").removeClass("selected").removeAttr "tabindex"
            selected.addClass "selected"
            selected.attr "tabindex", 0
            selected.focus()

            $.publish "/item/selected", [ get(name) ]
            $.publish "/galleryBar/update", [ "selected" ]

    page = (direction) =>

        return if flipping

        arrows.both.hide()

        if direction > 0 and ds.page() > 1
            flipping = true
            animation.reverse = true
            ds.page ds.page() - 1
            render(true)
        if direction < 0 and ds.page() < ds.totalPages()
            flipping = true
            animation.reverse = false
            ds.page ds.page() + 1
            render(true)

    clear = ->
        pages.previous.empty()
        pages.next.empty()

        $.publish "/postman/deliver", [ {}, "/file/read" ]

    destroy = ->
        refresh()
        name = selected.children(":first").attr("data-name")

        selected.kendoStop(true).kendoAnimate
            effects: "zoomOut fadeOut"
            hide: true
            complete: =>
                filewrapper.deleteFile(name).done =>
                    $.publish "/galleryBar/update", ["deselected"]
                    selected.remove()
                    ds.remove(ds.get(name))
                    render()


    get = (name) =>
        # find the match in the data source
        match = ds.get(name)
        # now get its index in the current view
        relativeIndex = ds.view().indexOf(match)
        # the actual index of this item in relation to the whole set
        # of data is the page number times. it's zero based so we have to do
        # some funky calculations
        position = if ds.page() > 1 then pageSize * (ds.page() - 1) + relativeIndex else relativeIndex
        return { length: ds.data().length, index: position, item: match }

    at = (newIndex, noPage, noSelect) =>
        return if newIndex < 0 or newIndex >= ds.data().length
        index = newIndex

        # we may need to page the data before grabbing the item.
        # to get the current page, divide the index by the pageSize. then
        target = Math.ceil((index + 1) / pageSize)
        # go ahead and go to that page if needed
        if (target != ds.page())
            unless noPage
                ds.page(target)
                render()
        # the actual index of the item within the page has to be recalculated if
        # the current page is greater than 1
        position = index - pageSize * (target - 1)
        # now we can search the current datasource view for the item at the correct index
        match = { length: ds.data().length, index: index, item: ds.view()[position] }
        $.publish "/details/update", [match]

        if noSelect
            $.publish "/item/selected", [ match ]
            $.publish "/galleryBar/update", [ "selected" ]
        else
            select match.item.name

    dataSource =
        create: (data) =>
            ds = new kendo.data.DataSource
                data: data
                pageSize: pageSize
                change: ->
                    deselect()
                sort:
                    dir: "desc"
                    field: "name"
                schema:
                    model:
                        id: "name"

    add = (item) =>
        item = { name: item.name, type: item.type }
        # check to make sure there is a data source before trying to add to it
        if not ds
            ds = dataSource.create([item])
        else
            # add the item to the datasource
            ds.add(item)

    create = (item) ->

        element = {}
        fadeIn = (e) ->
            $(e).kendoAnimate
                effects: "fadeIn"
                show: true

        element = new Image()
        element.onload = fadeIn(element)

        element.src = item.file
        element.setAttribute("data-name", item.name)
        element.setAttribute("draggable", true)

        element.width = 240
        element.height = 180

        element.setAttribute("class", "hidden")

        $(element).on "focus", (e) ->
            $(e.target).parent().addClass "selected"

        $(element).kendoMobileClickable {
            click: pub.click
        }

        return element

    render = (flip) =>

        files = []

        files.push file.name for file in ds.view()

        filewrapper.readBulk(files).done (message) =>
            compare = (a, b) ->
                if a.name > b.name
                    return -1

                if a.name < b.name
                    return 1

                return 0

            message.sort compare

            thumbs = []

            for item in message
                thumbnail = new kendo.View(pages.next, template)
                thumbs.push(dom: thumbnail.render({}, true), data: item)

                # turn the thumbnail into something clickable


            $("#gallery").css "pointer-events", "none"

            complete = =>

                setTimeout ->
                    for item in thumbs
                        do ->
                            element = create(item.data)
                            item.dom.append(element)

                    first = thumbs[0].dom
                    first.attr "tabindex", 0
                    first.addClass "selected"
                    selected = first
                , 50

                # the current page becomes the next page
                pages.next.show()

                justPaged = pages.previous
                justPaged.hide()
                justPaged.empty()

                pages.previous = pages.next
                pages.next = justPaged

                flipping = false

                arrows.left.toggle ds.page() > 1
                arrows.right.toggle ds.page() < ds.totalPages()

                $("#gallery").css "pointer-events", "auto"

                setTimeout ->
                    at (ds.page() - 1) * pageSize, false, true
                , 50

            if flip
                # move the current page out and the next page in
                container.kendoAnimate
                    effects: animation.effects
                    face: if animation.reverse then pages.next else pages.previous
                    back: if animation.reverse then pages.previous else pages.next
                    duration: animation.duration
                    reverse: animation.reverse
                    complete: complete

            else
                complete()

    keys = {
        tokens: [],
        bound: false,
        bind: ->
            return if @bound

            @tokens.push(
                $.subscribe "/keyboard/arrow", (key) ->
                    position = index % pageSize
                    switch key
                        when "left" then if index % columns > 0
                            at index - 1, true, false
                        when "right" then if index % columns < columns - 1
                            at index + 1, true, false
                        when "up" then if position >= columns
                            at index-columns, true, false
                        when "down" then if position < (rows-1)*columns
                            at index+columns, true, false
            )

            @tokens.push(
                $.subscribe "/keyboard/page", (dir) ->
                    if dir == "down"
                        page -1
                    if dir == "up"
                        page 1
            )

            @tokens.push(
                $.subscribe "/keyboard/enter", ->
                    at index, false, false
            )
            @bound = true

        unbind: ->
            return unless @bound

            @tokens = $.map(@tokens, (item) ->
                $.unsubscribe(item)
            )
            @bound = false
    }

    arrows =
        left: null
        right: null
        both: null
        init: (parent) ->
            arrows.left = parent.find(".previous")
            arrows.left.hide()
            arrows.right = parent.find(".next")
            arrows.both = $([arrows.left[0], arrows.right[0]])

    pub =

        before: (e) ->
            # pause the camera. there is no need for it right now.
            $.publish "/postman/deliver", [{ paused: true }, "/camera/pause"]

            # listen to keyboard events
            keys.bind()

        hide: (e) ->
            # don't respond to the keyboard events anymore
            keys.unbind()

            pages.next.empty()
            pages.previous.empty()

        show: (e) =>
            setTimeout render, 420

        previous: (e) ->
            page 1

        next: (e) ->
            page -1

        swipe: (e) ->
            page (e.direction == "right") - (e.direction == "left")

        click: (e) ->
            thumb = @element
            $.publish "/galleryBar/update", ["selected"]
            select thumb.data("name")

        init: (selector) =>
            list = $(selector)

            thumbnails = $("#thumbnails", list)

            # create the pages that hold the thumbnails
            # in order to page through previews, we need to create two pages. the current
            # page and the next page.
            page1 = new kendo.View(thumbnails, null)
            page2 = new kendo.View(thumbnails, null)

            # get a reference to the view container
            container = page1.container

            arrows.init $(list)

            pages.previous = page1.render().addClass("page gallery")
            active = pages.next = page2.render().addClass("page gallery")

            $.subscribe "/gallery/details", (d) ->
                refresh()
                details = d

            $.subscribe "/gallery/delete", ->
                destroy()

            $.subscribe "/gallery/add", (item) ->
                add(item)

            $.subscribe "/gallery/at", (index) ->
                at index, false, false

            $.subscribe "/gallery/clear", =>
                $.publish "/bottom/thumbnail"
                filewrapper.clear().done =>
                    clear()

            $.subscribe "/gallery/keepAlive", (flag) ->
                keepAlive = flag
                refresh()

            $.subscribe "/gallery/keyboard", (bind) ->
                if bind
                    keys.bind()
                else
                    keys.unbind()

            filewrapper.fileListing().done (message) =>
                ds = dataSource.create message
                ds.read()
                if ds.view().length > 0
                    filewrapper.readFile(ds.view()[0]).done (file) =>
                        $.publish "/bottom/thumbnail", [file]

            return gallery

