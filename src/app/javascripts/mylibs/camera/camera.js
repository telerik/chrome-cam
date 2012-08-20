(function() {

  define(['mylibs/preview/preview', 'mylibs/utils/utils'], function(preview, utils) {
    /*     Camera
    
    The camera module takes care of getting the users media and drawing it to a canvas.
    It also handles the coutdown that is intitiated
    */
    var $counter, beep, canvas, countdown, ctx, paused, pub, turnOn;
    $counter = {};
    canvas = {};
    ctx = {};
    beep = document.createElement("audio");
    paused = false;
    turnOn = function(callback, testing) {
      window.HTML5CAMERA.canvas = canvas;
      $.subscribe("/camera/update", function(message) {
        var imgData, videoData;
        imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
        videoData = new Uint8ClampedArray(message.image);
        imgData.data.set(videoData);
        ctx.putImageData(imgData, 0, 0);
        return $.publish("/camera/stream", [canvas]);
      });
      return callback();
    };
    countdown = function(num, callback) {
      var counters, index;
      beep.play();
      counters = $counter.find("span");
      index = counters.length - num;
      return $(counters[index]).css("opacity", "1").animate({
        opacity: .1
      }, 1000, function() {
        if (num > 1) {
          num--;
          return countdown(num, callback);
        } else {
          return callback();
        }
      });
    };
    return pub = {
      init: function(counter, callback) {
        var draw, testing, update, video;
        window.HTML5CAMERA = {};
        testing = true;
        $counter = $("#" + counter);
        beep.src = "sounds/beep.mp3";
        beep.buffer = "auto";
        canvas = document.createElement("canvas");
        canvas.width = 720;
        canvas.height = 480;
        video = document.createElement("video");
        video.width = 720;
        video.height = 480;
        ctx = canvas.getContext("2d");
        if (testing) {
          draw = function() {
            utils.getAnimationFrame()(draw);
            return update();
          };
          update = function() {
            var buffer, img;
            ctx.drawImage(video, 0, 0, video.width, video.height);
            img = ctx.getImageData(0, 0, canvas.width, canvas.height);
            buffer = img.data.buffe;
            return $.publish("/camera/update", [
              {
                image: img.data.buffer
              }
            ]);
          };
          navigator.webkitGetUserMedia({
            video: true
          }, function(stream) {
            var e;
            e = window.URL || window.webkitURL;
            video.src = e ? e.createObjectURL(stream) : stream;
            video.play();
            return draw();
          }, function() {
            return console.error("Camera Failed");
          });
        }
        turnOn(callback);
        return $.subscribe("/camera/countdown", function(num, hollaback) {
          return countdown(num, hollaback);
        });
      }
    };
  });

}).call(this);
