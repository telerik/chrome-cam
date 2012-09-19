(function() {

  define(['Kendo', 'mylibs/effects/effects', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/full/views/full.html', 'text!mylibs/full/views/transfer.html'], function(kendo, effects, utils, filewrapper, template, transferImg) {
    var SECONDS_TO_RECORD, canvas, capture, ctx, draw, effect, flash, frame, frames, full, paused, preview, pub, recording, scaleCanvas, startTime, transfer, video, videoCtx;
    SECONDS_TO_RECORD = 6;
    canvas = {};
    ctx = {};
    video = {};
    videoCtx = {};
    preview = {};
    paused = true;
    frame = 0;
    frames = [];
    recording = false;
    startTime = 0;
    full = {};
    transfer = {};
    effect = {};
    scaleCanvas = {};
    draw = function() {
      return $.subscribe("/camera/stream", function(stream) {
        var secondsRecorded, time;
        if (!paused) {
          frame++;
          effect(canvas, stream.canvas, frame, stream.track);
          if (recording) {
            time = Date.now();
            videoCtx.drawImage(canvas, 0, 0);
            frames.push({
              imageData: videoCtx.getImageData(0, 0, video.width, video.height),
              time: time
            });
            secondsRecorded = (Date.now() - startTime) / 1000;
            return full.el.timer.first().html(kendo.toString(SECONDS_TO_RECORD - secondsRecorded, "0"));
          }
        }
      });
    };
    flash = function(callback, file) {
      full.el.flash.show();
      transfer.content.kendoStop().kendoAnimate({
        effects: "transfer",
        target: $("#destination"),
        duration: 1000,
        ease: "ease-in",
        complete: function() {
          $.publish("/bottom/thumbnail", [file]);
          transfer.destroy();
          transfer = {};
          return callback();
        }
      });
      return full.el.flash.hide();
    };
    capture = function(callback) {
      var data, image, name;
      image = canvas.toDataURL();
      name = new Date().getTime();
      data = {
        src: image,
        height: full.content.height(),
        width: full.content.width()
      };
      transfer = new kendo.View(full.content, transferImg, data);
      transfer.render();
      return transfer.find("img").load(function() {
        var file;
        file = {
          type: "jpeg",
          name: "" + name + ".jpeg",
          file: image
        };
        filewrapper.save(name, image);
        $.publish("/gallery/add", [file]);
        return flash(callback, file);
      });
    };
    return pub = {
      init: function(selector) {
        full = new kendo.View(selector, template);
        canvas = document.createElement("canvas");
        video = document.createElement("canvas");
        video.width = 360;
        video.height = 240;
        canvas.width = 720;
        canvas.height = 480;
        ctx = canvas.getContext("2d");
        videoCtx = video.getContext("2d");
        videoCtx.scale(0.5, 0.5);
        full.render().prepend(canvas);
        full.find(".flash", "flash");
        full.find(".timer", "timer");
        full.find(".transfer", "transfer");
        full.find(".transfer img", "source");
        $.subscribe("/full/show", function(item) {
          return pub.show(item);
        });
        $.subscribe("/full/hide", function() {
          return pub.hide();
        });
        $.subscribe("/capture/photo", function() {
          return pub.photo();
        });
        $.subscribe("/capture/paparazzi", function() {
          return pub.paparazzi();
        });
        $.subscribe("/capture/video", function() {
          return pub.video();
        });
        $.subscribe("/keyboard/esc", function() {
          return pub.hide();
        });
        return draw();
      },
      show: function(item) {
        effect = item.filter;
        paused = false;
        full.content.height(full.container.height()) - 50;
        full.el.transfer.height(full.content.height());
        full.content.width((3 / 2) * full.content.height());
        full.el.transfer.width(full.content.width());
        $(canvas).height(full.content.height());
        return full.container.kendoStop(true).kendoAnimate({
          effects: "zoomIn fadeIn",
          show: true,
          complete: function() {
            return $.publish("/bottom/update", ["full"]);
          }
        });
      },
      hide: function() {
        paused = true;
        $.publish("/bottom/update", ["preview"]);
        return full.container.kendoStop(true).kendoAnimate({
          effects: "zoomOut fadeOut",
          hide: true,
          complete: function() {
            return $.publish("/preview/pause", [false]);
          }
        });
      },
      photo: function() {
        var callback;
        callback = function() {
          return $.publish("/bottom/update", ["full"]);
        };
        return capture(callback);
      },
      paparazzi: function() {
        var callback;
        callback = function() {
          callback = function() {
            callback = function() {
              return $.publish("/bottom/update", ["full"]);
            };
            return capture(callback);
          };
          return capture(callback);
        };
        return capture(callback);
      },
      video: function() {
        console.log("Recording...");
        frames = [];
        startTime = Date.now();
        full.container.find(".timer").removeClass("hidden");
        setTimeout((function() {
          recording = false;
          $.publish("/bottom/update", ["processing"]);
          return setTimeout(function() {
            var data, file, image, result;
            result = utils.createVideo(frames);
            console.log("Recording Done!");
            frames = [];
            full.container.find(".timer").addClass("hidden");
            image = canvas.toDataURL();
            file = {
              type: "webm",
              name: result.name,
              file: result.url
            };
            data = {
              src: image,
              height: full.content.height(),
              width: full.content.width()
            };
            transfer = new kendo.View(full.content, transferImg, data);
            transfer.render();
            transfer.find("img").load(function() {
              return transfer.content.kendoStop().kendoAnimate({
                effects: "transfer",
                target: $("#destination"),
                duration: 1000,
                ease: "ease-in",
                complete: function() {
                  $.publish("/bottom/thumbnail", [file]);
                  $.publish("/gallery/add", [file]);
                  transfer.destroy();
                  return transfer = {};
                }
              });
            });
            return $.publish("/bottom/update", ["full"]);
          }, 0);
        }), SECONDS_TO_RECORD * 1000);
        return recording = true;
      }
    };
  });

}).call(this);
