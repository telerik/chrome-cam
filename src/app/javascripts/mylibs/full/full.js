(function() {

  define(['Kendo', 'mylibs/effects/effects', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'mylibs/config/config', 'text!mylibs/full/views/full.html', 'text!mylibs/full/views/transfer.html'], function(kendo, effects, utils, filewrapper, config, template, transferImg) {
    var SECONDS_TO_RECORD, canvas, capture, ctx, draw, effect, flash, frame, frames, full, index, paused, preview, pub, recording, scaleCanvas, startTime, transfer, video, videoCtx;
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
        var remaining, request, secondsRecorded, time;
        if (!paused) {
          frame++;
          effects.advance(stream.canvas);
          effect(canvas, stream.canvas, frame, stream.track);
          if (recording) {
            time = Date.now();
            videoCtx.drawImage(canvas, 0, 0);
            frames.push({
              imageData: videoCtx.getImageData(0, 0, video.width, video.height),
              time: time
            });
            secondsRecorded = (Date.now() - startTime) / 1000;
            remaining = Math.max(0, SECONDS_TO_RECORD - secondsRecorded);
            full.el.timer.first().html(kendo.toString(remaining, "0"));
          }
          request = function() {
            return $.publish("/postman/deliver", [null, "/camera/request"]);
          };
          return setTimeout(request, 1);
        }
      });
    };
    flash = function(callback, file) {
      return config.get("flash", function(enabled) {
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
      });
    };
    capture = function(callback) {
      var data, image, name;
      image = canvas.toDataURL("image/jpeg", 1.0);
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
          type: "jpg",
          name: "" + name + ".jpg",
          file: image
        };
        filewrapper.save(file.name, image);
        $.publish("/gallery/add", [file]);
        return flash(callback, file);
      });
    };
    index = {
      current: function() {
        var i, _i, _ref;
        for (i = _i = 0, _ref = effects.data.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (effects.data[i].filter === effect) {
            return i;
          }
        }
      },
      max: function() {
        return effects.data.length;
      },
      select: function(i) {
        effect = effects.data[i].filter;
        return $.publish("/postman/deliver", [effects.data[i].tracks, "/tracking/enable"]);
      }
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
          if (!paused) return $.publish("/full/hide");
        });
        $.subscribe("/keyboard/arrow", function(dir) {
          if (paused) {
            return;
          }
          if (dir === "left" && index.current() > 0) {
            index.select(index.current() - 1);
          }
          if (dir === "right" && index.current() + 1 < index.max()) {
            return index.select(index.current() + 1);
          }
        });
        return draw();
      },
      show: function(item) {
        if (!paused) {
          return;
        }
        effect = item.filter;
        paused = false;
        full.el.transfer.height(full.content.height());
        full.el.transfer.width(full.content.width());
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
            $.publish("/preview/pause", [false]);
            return $.publish("/postman/deliver", [null, "/camera/request"]);
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
        var advance, callback, left, wrapper;
        wrapper = full.container.find(".wrapper");
        wrapper.find(".paparazzi").removeClass("hidden");
        left = 4;
        advance = function() {
          wrapper.removeClass("paparazzi-" + left);
          left -= 1;
          return wrapper.addClass("paparazzi-" + left);
        };
        callback = function() {
          callback = function() {
            callback = function() {
              $.publish("/bottom/update", ["full"]);
              wrapper.removeClass("paparazzi-1");
              return wrapper.find(".paparazzi").removeClass("hidden");
            };
            advance();
            return capture(callback);
          };
          advance();
          return capture(callback);
        };
        advance();
        return capture(callback);
      },
      video: function() {
        var done, save;
        if (recording) return;
        recording = true;
        console.log("Recording...");
        frames = [];
        startTime = Date.now();
        full.container.find(".timer").removeClass("hidden");
        save = function() {
          return utils.createVideo(frames).done(function(result) {
            var data, file, image;
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
          });
        };
        done = function() {
          recording = false;
          $.publish("/bottom/update", ["processing"]);
          return setTimeout(save, 0);
        };
        return setTimeout(done, SECONDS_TO_RECORD * 1000);
      }
    };
  });

}).call(this);
