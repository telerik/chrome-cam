define [], ->
    pub =
        getToken: (callback) ->
            chrome.identity.getAuthToken { interactive: false }, (token) ->
                if token
                    callback token
                else
                    chrome.identity.getAuthToken { interactive: true }, (token) ->
                        callback token