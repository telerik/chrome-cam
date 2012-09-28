(function() {

  define(['mylibs/postman/postman', 'mylibs/utils/utils', 'mylibs/file/file', 'mylibs/intents/intents', 'mylibs/notify/notify', 'mylibs/assets/assets', 'libs/face/track'], function(postman, utils, file, intents, notify, assets, face) {
    'use strict';
    var canvas, config, ctx, draw, errback, hollaback, iframe, menu, paused, pub, skip, skipBit, skipMax, track, update;
    iframe = iframe = document.getElementById("iframe");
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    track = {};
    paused = false;
    skip = false;
    skipBit = 0;
    skipMax = 10;
    config = {
      get: function(key, fn) {
        return chrome.storage.local.get(key, function(storage) {
          return $.publish("/postman/deliver", [storage[key], "/config/value/" + key]);
        });
      },
      set: function(key, value) {
        var obj;
        obj = {};
        obj[key] = value;
        return chrome.storage.local.set(obj);
      },
      init: function() {
        $.subscribe("/config/get", function(key) {
          return config.get(key);
        });
        $.subscribe("/config/set", function(e) {
          return config.set(e.key, e.value);
        });
        return $.subscribe("/config/all", function() {
          return $.publish("/postman/deliver", [config.values, "/config/values"]);
        });
      }
    };
    menu = function() {
      chrome.contextMenus.onClicked.addListener(function(info, tab) {
        return $.publish("/postman/deliver", [{}, "/menu/click/" + info.menuItemId]);
      });
      return $.subscribe("/menu/enable", function(isEnabled) {
        var menu, menus, _i, _len, _results;
        menus = ["chrome-cam-about-menu", "chrome-cam-settings-menu"];
        _results = [];
        for (_i = 0, _len = menus.length; _i < _len; _i++) {
          menu = menus[_i];
          _results.push(chrome.contextMenus.update(menu, {
            enabled: isEnabled
          }));
        }
        return _results;
      });
    };
    draw = function() {
      return update();
    };
    update = function() {
      var buffer, img;
      if (!paused) {
        if (skipBit === 0) track = face.track(video);
        ctx.drawImage(video, 0, 0, video.width, video.height);
        img = ctx.getImageData(0, 0, canvas.width, canvas.height);
        buffer = img.data.buffer;
        $.publish("/postman/deliver", [
          {
            image: img.data.buffer,
            track: track
          }, "/camera/update", [buffer]
        ]);
        if (skipBit < 4) {
          skipBit++;
        } else {
          skipBit = 0;
        }
      }
      return setTimeout(update, 1000 / 30);
    };
    hollaback = function(stream) {
      var e, video;
      e = window.URL || window.webkitURL;
      video = document.getElementById("video");
      video.src = e ? e.createObjectURL(stream) : stream;
      video.play();
      return draw();
    };
    errback = function() {
      return console.log("Couldn't Get The Video");
    };
    return pub = {
      init: function() {
        var thumbnailWorker;
        utils.init();
        $.subscribe("/camera/pause", function(message) {
          return paused = message.paused;
        });
        navigator.webkitGetUserMedia({
          video: true
        }, hollaback, errback);
        iframe.src = "app/index.html";
        postman.init(iframe.contentWindow);
        thumbnailWorker = new Worker("chrome/javascripts/mylibs/workers/bitmapWorker.js");
        thumbnailWorker.onmessage = function(e) {
          return $.publish("/postman/deliver", [e.data, "/preview/thumbnail/response/"]);
        };
        $.subscribe("/preview/thumbnail/request", function(e) {
          return thumbnailWorker.postMessage({
            width: e.data.width,
            height: e.data.height,
            data: e.data.data,
            key: e.data.key
          });
        });
        $.subscribe("/tab/open", function(url) {
          return chrome.tabs.create({
            url: url
          });
        });
        notify.init();
        intents.init();
        file.init();
        assets.init();
        config.init();
        face.init(0, 0, 0, 0);
        return menu();
      }
    };
  });

}).call(this);
