chrome.runtime.onInstalled.addListener(function() {
  chrome.contextMenus.create({
    id: "chrome-cam-about-menu",
    title: "About...",
    contexts: ["page"]
  });
});

chrome.app.runtime.onLaunched.addListener(function() { 
  
  function onWindowLoaded(win) {
    APP = win;
  }

  var dimensions = { 
    width: 1200,
    minWidth: 1200,
    maxWidth: 1200,
    height: 750,
    minHeight: 750,
    maxHeight: 750
  };
  
  var win = chrome.app.window.create('main.html', dimensions, onWindowLoaded);
});

