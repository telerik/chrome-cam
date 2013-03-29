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
        var releasePower = function() {};

        APP = win;

        if (win.isFullscreen()) {
            try {
                chrome.power.requestKeepAwake("display");
                releasePower = function() {
                    chrome.power.releaseKeepAwake("display");
                };
            } catch (ex) {
                // this device probably doesn't support the power API.
            }
        }

        win.onClosed.addListener(function() {
            APP.contentWindow.cleanup();
            releasePower();
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

    var win = chrome.app.window.create('main.html', dimensions, onWindowLoaded);
});

