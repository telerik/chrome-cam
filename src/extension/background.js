var APP;

chrome.runtime.onInstalled.addListener(function() {
    chrome.contextMenus.create({
        id: "chrome-cam-about-menu",
        title: "About...",
        contexts: ["page"]
    });
});

chrome.app.runtime.onLaunched.addListener(function() {
    var onWindowLoaded = function(win) {
        APP = win;

        win.onClosed.addListener(function() {
            APP.contentWindow.cleanup();

            try {
                chrome.power.releaseKeepAwake("display");
            } catch (ex) {
                // this device probably doesn't support the power API.
            }
        });
    }

    var width = 989;
    var height = 689;

    var dimensions = {
        defaultWidth: width,
        minWidth: width,
        defaultHeight: height,
        minHeight: height,
        id: 'camera'
    };

    try {
        chrome.power.requestKeepAwake("display");
    } catch (ex) {
        // this device probably doesn't support the power API.
    }

    var win = chrome.app.window.create('main.html', dimensions, onWindowLoaded);
});

