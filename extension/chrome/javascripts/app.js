(function() {

  define(['mylibs/postman/postman', 'mylibs/utils/utils', 'mylibs/file/file', 'mylibs/intents/intents', 'mylibs/notify/notify', 'mylibs/assets/assets', 'libs/face/track'], function(postman, utils, file, intents, notify, assets, face) {
    'use strict';
    var canvas, ctx, draw, errback, hollaback, iframe, pub, skip, skipBit, skipMax, track, update;
    iframe = iframe = document.getElementById("iframe");
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    track = {};
    skip = false;
    skipBit = 0;
    skipMax = 10;
    draw = function() {
      return update();
    };
    update = function() {
      var buffer, img;
      if (skipBit === 0) track = face.track(video);
      ctx.drawImage(video, 0, 0, video.width, video.height);
      img = ctx.getImageData(0, 0, canvas.width, canvas.height);
      buffer = img.data.buffer;
      $.publish("/postman/deliver", [
        {
          message: {
            image: img.data.buffer,
            track: track
          }
        }, "/camera/update", [buffer]
      ]);
      if (skipBit < 4) {
        skipBit++;
      } else {
        skipBit = 0;
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
        notify.init();
        utils.init();
        intents.init();
        file.init();
        postman.init(iframe.contentWindow);
        $.publish("/file/read", []);
        assets.init();
        face.init(0, 0, 0, 0);
        return navigator.webkitGetUserMedia({
          video: true
        }, hollaback, errback);
      }
    };
  });

}).call(this);
