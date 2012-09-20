chrome.runtime.onInstalled.addListener(function() {
  chrome.contextMenus.create({
    id: "chrome-cam-about-menu",
    title: "About...",
    contexts: ["page"]
  });
  chrome.contextMenus.create({
    id: "chrome-cam-settings-menu",
    title: "Settings...",
    contexts: ["page"]
  });
});

chrome.app.runtime.onLaunched.addListener(function() { 
  
  function onWindowLoaded(win) {
    APP = win;
  }

  var dimensions = { 
    width: 1280,
    height: 750
  };
  
  var win = chrome.app.window.create('main.html', dimensions, onWindowLoaded);
});

