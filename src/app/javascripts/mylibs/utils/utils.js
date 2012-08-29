(function() {

  define([], function() {
    /*     Utils
    
    This file contains utility functions and normalizations. this used to contain more functions, but
    most have been moved into the extension
    */
    var pub;
    return pub = {
      getAnimationFrame: function() {
        return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
          return window.setTimeout(callback, 1000 / 60);
        };
      },
      createVideo: function(frames) {
        var canvas, ctx, framesDone, i, transcode, _ref, _results;
        transcode = function() {
          var blob, i, name, pair, video, _i, _len, _ref;
          video = new Whammy.Video();
          _ref = (function() {
            var _ref, _results;
            _results = [];
            for (i = 0, _ref = frames.length - 2; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
              _results.push(frames.slice(i, (i + 2)));
            }
            return _results;
          })();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            pair = _ref[_i];
            video.add(pair[0].imageData, pair[1].time - pair[0].time);
          }
          blob = video.compile();
          frames = [];
          name = new Date().getTime() + ".webm";
          console.log("Recording Done!");
          return $.publish("/postman/deliver", [
            {
              name: name,
              file: blob
            }, "/file/save"
          ]);
        };
        canvas = document.createElement("canvas");
        canvas.width = 360;
        canvas.height = 240;
        ctx = canvas.getContext("2d");
        framesDone = 0;
        _results = [];
        for (i = 0, _ref = frames.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
          _results.push((function(i) {
            var imageData, videoData;
            imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
            videoData = new Uint8ClampedArray(frames[i].imageData);
            imageData.data.set(videoData);
            ctx.putImageData(imageData, 0, 0);
            frames[i] = {
              imageData: canvas.toDataURL('image/webp', 1),
              time: frames[i].time
            };
            ++framesDone;
            if (framesDone === frames.length) return transcode();
          })(i));
        }
        return _results;
      }
    };
  });

}).call(this);
