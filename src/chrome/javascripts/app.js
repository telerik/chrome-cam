(function() {

  define(['mylibs/postman/postman', 'mylibs/utils/utils', 'mylibs/file/file', 'mylibs/notify/notify', 'mylibs/localization/localization', 'libs/face/track'], function(postman, utils, file, notify, localization, face) {
    'use strict';

    var canvas, ctx, draw, errback, hollaback, iframe, menu, paused, pub, skip, skipBit, skipMax, track, update;
    iframe = iframe = document.getElementById("iframe");
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    track = {};
    paused = false;
    skip = false;
    skipBit = 0;
    skipMax = 10;
    menu = function() {
      chrome.contextMenus.onClicked.addListener(function(info, tab) {
        return $.publish("/postman/deliver", [{}, "/menu/click/" + info.menuItemId]);
      });
      return $.subscribe("/menu/enable", function(isEnabled) {
        var menus, _i, _len, _results;
        menus = ["chrome-cam-about-menu"];
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
      if (paused) {
        return;
      }
      if (skipBit === 0) {
        track = face.track(video);
      }
      ctx.drawImage(video, 0, 0, video.width, video.height);
      img = ctx.getImageData(0, 0, canvas.width, canvas.height);
      buffer = img.data.buffer;
      $.publish("/postman/deliver", [
        {
          image: buffer,
          track: track
        }, "/camera/update", [buffer]
      ]);
      if (skipBit < 4) {
        return skipBit++;
      } else {
        return skipBit = 0;
      }
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
        utils.init();
        $.subscribe("/camera/pause", function(message) {
          return paused = message.paused;
        });
        $.subscribe("/camera/request", function() {
          return update();
        });
        navigator.webkitGetUserMedia({
          video: true
        }, hollaback, errback);
        iframe.src = "app/index.html";
        postman.init(iframe.contentWindow);
        $.subscribe("/tab/open", function(url) {
          return chrome.tabs.create({
            url: url
          });
        });
        $.subscribe("/localization/request", function() {
          return $.publish("/postman/deliver", [localization, "/localization/response"]);
        });
        $.subscribe("/window/close", function() {
          return window.close();
        });
        notify.init();
        file.init();
        face.init(0, 0, 0, 0);
        menu();
        return $(iframe).focus();
      }
    };
  });

}).call(this);
