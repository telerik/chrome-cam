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

  var win = chrome.app.window.create('main.html', { 
  	width: 1280, 
  	height: 750
  	}, 
  	onWindowLoaded);
});

