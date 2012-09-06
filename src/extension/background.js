chrome.app.runtime.onLaunched.addListener(function() { 
  
  function onWindowLoaded(win) {
  	APP = win;
  }

  var win = chrome.app.window.create('main.html', { 
  	width: 1280, 
  	height: 800
  	}, 
  	onWindowLoaded);
});

