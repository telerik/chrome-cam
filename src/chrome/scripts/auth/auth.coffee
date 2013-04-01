define [], ->
    pub =
        getToken: (callback) ->
            chrome.experimental.identity.getAuthToken { interactive: true }, (token) ->
                if token
                    callback token
                else
                    chrome.experimental.identity.getAuthToken { interactive: true }, (token) ->
                        callback token