(function() {

  define(['mylibs/utils/utils', 'libs/webgl/glfx'], function(utils) {
    var canvas, ctx, draw, frame, paused, preview, pub, webgl;
    canvas = {};
    ctx = {};
    preview = {};
    webgl = {};
    preview = {};
    paused = true;
    frame = 0;
    draw = function() {
      return $.subscribe("/camera/stream", function() {
        if (!paused) {
          frame++;
          return preview.filter(webgl, window.HTML5CAMERA.canvas, frame);
        }
      });
    };
    return pub = {
      init: function(selector) {
        var $container;
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
        webgl = fx.canvas();
        $(webgl).dblclick(function() {
          $.publish("/previews/pause", [false]);
          return $container.kendoStop().kendoAnimate({
            effects: "grow",
            top: preview.canvas.offsetTop,
            left: preview.canvas.offsetLeft,
            width: preview.canvas.width,
            height: preview.canvas.height
          }, function() {
            return $container.hide();
          });
        });
        $container.append(webgl);
        $.subscribe("/full/show", function(e) {
          var fullHeight, fullWidth, x, y;
          $.extend(preview, e);
          paused = false;
          y = preview.canvas.offsetTop;
          x = preview.canvas.offsetLeft;
          $container.css("top", y);
          $container.css("left", x);
          fullWidth = $(document).width();
          fullHeight = $(document).height();
          $container.width(preview.canvas.width);
          $container.height(preview.canvas.height);
          $container.show();
          return $container.kendoStop().kendoAnimate({
            effects: "grow",
            top: 0,
            left: 0,
            width: fullWidth,
            height: fullHeight
          });
        });
        $.subscribe("full/hide", function() {});
        return draw();
      }
    };
  });

}).call(this);
