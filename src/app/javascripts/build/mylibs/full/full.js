(function() {

  define(['mylibs/utils/utils', 'text!mylibs/full/views/full.html', 'libs/webgl/glfx'], function(utils, fullTemplate) {
<<<<<<< HEAD
    var $flash, canvas, ctx, draw, flash, frame, frames, paused, preview, pub, recording, webgl;
=======
    var canvas, ctx, draw, frame, frames, paused, preview, pub, recording, webgl;
>>>>>>> 292326157fd931e6ecb112e74e8204e9fe1a15d1
    canvas = {};
    ctx = {};
    preview = {};
    webgl = {};
    preview = {};
    paused = true;
    frame = 0;
    frames = [];
    recording = false;
<<<<<<< HEAD
    $flash = {};
=======
>>>>>>> 292326157fd931e6ecb112e74e8204e9fe1a15d1
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
    flash = function() {
      $flash.show();
      return $flash.kendoStop(true).kendoAnimate({
        effects: "fadeOut",
        duration: 2000,
        hide: true
      });
    };
    return pub = {
      init: function(selector) {
        var $container, $content;
        $.subscribe("/capture/image", function() {
          var image, name, token;
          flash();
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
              file: image
            }, "/file/save"
          ]);
        });
<<<<<<< HEAD
        $.subscribe("/capture/video", function() {
=======
        $.subscribe("/capture/video/record", function() {
>>>>>>> 292326157fd931e6ecb112e74e8204e9fe1a15d1
          console.log("Recording...");
          frames = [];
          recording = true;
          return setTimeout((function() {
            utils.createVideo(frames);
            console.log("Recording Done!");
            return recording = false;
          }), 6000);
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
          return flash();
        });
        return draw();
      }
    };
  });

}).call(this);
