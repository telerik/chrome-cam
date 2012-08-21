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
        var $container, $wrapper;
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
        $wrapper = $("<div></div>");
        $container.append($wrapper);
        webgl = fx.canvas();
        $(webgl).dblclick(function() {
          $.publish("/previews/pause", [false]);
          return $container.kendoStop(true).kendoAnimate({
            effects: "zoomOut",
            hide: "true"
          });
        });
        $wrapper.append(webgl);
        $.subscribe("/full/show", function(e) {
          $.extend(preview, e);
          paused = false;
          $wrapper.height($container.height() - 50);
          $wrapper.width((3 / 2) * $wrapper.height());
          $(webgl).width($wrapper.width());
          $(webgl).height("height", $wrapper.height());
          return $container.kendoStop(true).kendoAnimate({
            effects: "zoomIn",
            show: "true"
          });
        });
        $.subscribe("/capture/image", function() {});
        return draw();
      }
    };
  });

}).call(this);
