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

