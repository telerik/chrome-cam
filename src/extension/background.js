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

  var width = 989;
  var height = 689;

  var dimensions = { 
    width: width,
    minWidth: width,
    maxWidth: width,
    height: height,
    minHeight: height,
    maxHeight: height
  };
  
  var win = chrome.app.window.create('main.html', dimensions, onWindowLoaded);
});

