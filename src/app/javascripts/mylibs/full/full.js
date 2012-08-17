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
      if (!paused) {
        ctx.drawImage(window.HTML5CAMERA.canvas, 0, 0, canvas.width, canvas.height);
        frame++;
        preview.filter(webgl, canvas, frame);
      }
      return utils.getAnimationFrame()(draw);
    };
    return pub = {
      init: function(selector) {
        var $container;
        $container = $(selector);
        canvas = document.createElement("canvas");
        ctx = canvas.getContext("2d");
        canvas.width = $container.width();
        canvas.height = $container.height();
        webgl = fx.canvas();
        $(webgl).dblclick(function() {
          return $container.kendoStop(true).kendoAnimate({
            effects: "zoomOut fadeOut",
            hide: true,
            duration: 200,
            complete: function() {
              return paused = true;
            }
          });
        });
        $container.append(webgl);
        $.subscribe("/full/show", function(e) {
          $.extend(preview, e);
          paused = false;
          return $container.kendoStop().kendoAnimate({
            effects: "zoomIn fadeIn",
            show: true,
            duration: 200
          });
        });
        $.subscribe("full/hide", function() {});
        return draw();
      }
    };
  });

}).call(this);
