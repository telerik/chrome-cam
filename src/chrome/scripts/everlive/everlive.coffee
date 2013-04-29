define ->
    deferred = $.Deferred()

    el = new Everlive('LXc4vDwRp1wJ3TDo')

    login = Everlive.$.Users.login('test', 'test')
    login.then (data) ->
        deferred.resolve el
    , (error) ->
        deferred.reject error

    return deferred.promise()