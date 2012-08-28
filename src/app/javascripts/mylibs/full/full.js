(function() {

  define(['mylibs/utils/utils', 'text!mylibs/full/views/full.html', 'libs/webgl/glfx'], function(utils, fullTemplate) {
    var canvas, ctx, draw, frame, frames, paused, preview, pub, recording, webgl;
    canvas = {};
    ctx = {};
    preview = {};
    webgl = {};
    preview = {};
    paused = true;
    frame = 0;
    frames = [];
    recording = false;
    draw = function() {
      return $.subscribe("/camera/stream", function(stream) {
        if (!paused) {
          frame++;
          preview.filter(webgl, stream.canvas, frame, stream.track);
          if (recording) {
            return frames.push({
              imageData: webgl.getPixelArray(),
              time: Date.now()
            });
          }
        }
      });
    };
    return pub = {
      init: function(selector) {
        var $container, $content, $flash;
        $.subscribe("/capture/image", function() {
          var image, name, token;
          image = webgl.toDataURL();
          name = new Date().getTime() + ".jpg";
          token = $.subscribe("/file/saved/" + name, function() {
            $.publish("/bar/preview/update", [
              {
                thumbnailURL: image
              }
            ]);
            return $.unsubscribe(token);
          });
          return $.publish("/postman/deliver", [
            {
              name: name,
              image: image
            }, "/file/save"
          ]);
        });
        $.subscribe("/capture/video/record", function() {
          console.log("Recording...");
          frames = [];
          recording = true;
          return setTimeout((function() {
            utils.createVideo(frames);
            console.log("Recording Done!");
            return recording = false;
          }), 6000);
        });
        $.subscribe("/capture/video", function() {
          var record, recordStart;
          frames = [];
          recordStart = Date.now();
          return record = true;
        });
        kendo.fx.grow = {
          setup: function(element, options) {
            return $.extend({
              top: options.top,
              left: options.left,
              width: options.width,
              height: options.height
            }, options.properties);
          }
        };
        $container = $(selector);
        canvas = document.createElement("canvas");
        ctx = canvas.getContext("2d");
        $content = $(fullTemplate).appendTo($container);
        $flash = $content.find(".flash");
        webgl = fx.canvas();
        $(webgl).dblclick(function() {
          $.publish("/bar/capture/hide");
          $.publish("/camera/pause", [true]);
          return $container.kendoStop(true).kendoAnimate({
            effects: "zoomOut",
            hide: "true",
            complete: function() {
              paused = true;
              $.publish("/camera/pause", [false]);
              return $.publish("/previews/pause", [false]);
            }
          });
        });
        $content.prepend(webgl);
        $.subscribe("/full/show", function(e) {
          $.publish("/bar/capture/show");
          $.extend(preview, e);
          $.publish("/camera/pause", [true]);
          $content.height($container.height() - 50);
          $content.width((3 / 2) * $content.height());
          $(webgl).width($content.width());
          $(webgl).height("height", $content.height());
          return $container.kendoStop(true).kendoAnimate({
            effects: "zoomIn",
            show: "true",
            complete: function() {
              $.publish("/camera/pause", [false]);
              return paused = false;
            }
          });
        });
        $.subscribe("/full/flash", function() {
          $flash.show();
          return $flash.kendoStop(true).kendoAnimate({
            effects: "fadeOut",
            duration: 2000,
            hide: true
          });
        });
        return draw();
      }
    };
  });

}).call(this);
