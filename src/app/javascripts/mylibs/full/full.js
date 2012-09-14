(function() {

  define(['Kendo', 'mylibs/effects/effects', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/full/views/full.html', 'text!mylibs/full/views/transfer.html'], function(kendo, effects, utils, filewrapper, template, transferImg) {
    var canvas, capture, ctx, draw, effect, flash, frame, frames, full, paused, preview, pub, recording, startTime, transfer;
    canvas = {};
    ctx = {};
    preview = {};
    paused = true;
    frame = 0;
    frames = [];
    recording = false;
    startTime = 0;
    full = {};
    transfer = {};
    effect = {};
    draw = function() {
      return $.subscribe("/camera/stream", function(stream) {
        var time;
        if (!paused) {
          frame++;
          effect(canvas, stream.canvas, frame, stream.track);
          if (recording) {
            time = Date.now();
            frames.push({
              imageData: ctx.getImageData(0, 0, 720, 480),
              time: Date.now()
            });
            return full.el.timer.first().html(kendo.toString((Date.now() - startTime) / 1000, "0"));
          }
        }
      });
    };
    flash = function(callback, image) {
      full.el.flash.show();
      transfer.content.kendoStop().kendoAnimate({
        effects: "transfer",
        target: $("#destination"),
        duration: 2002,
        ease: "ease-in",
        complete: function() {
          $.publish("/bottom/thumbnail", [image]);
          transfer.destroy();
          transfer = {};
          return callback();
        }
      });
      return full.el.flash.hide();
    };
    capture = function(callback) {
      var data, image;
      image = canvas.toDataURL();
      data = {
        src: image,
        height: full.content.height(),
        width: full.content.width()
      };
      transfer = new kendo.View(full.content, transferImg, data);
      transfer.render();
      return transfer.find("img").load(function() {
        var name;
        name = new Date().getTime() + ".jpg";
        filewrapper.save(name, image).done(function() {
          $.publish("/bottom/thumbnail", [image]);
          return $.publish("/gallery/add", [
            {
              type: 'jpg',
              name: name
            }
          ]);
        });
        return flash(callback, image);
      });
    };
    return pub = {
      init: function(selector) {
        full = new kendo.View(selector, template);
        canvas = document.createElement("canvas");
        canvas.width = 720;
        canvas.height = 480;
        ctx = canvas.getContext("2d");
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
          $.publish("/bottom/update", ["processing"]);
          return setTimeout(function() {
            utils.createVideo(frames);
            console.log("Recording Done!");
            recording = false;
            full.container.find(".timer").addClass("hidden");
            return $.publish("/recording/done", ["full"]);
          }, 500);
        }), 6000);
        return recording = true;
      }
    };
  });

}).call(this);
