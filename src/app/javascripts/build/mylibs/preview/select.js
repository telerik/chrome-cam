(function() {

  define(['mylibs/preview/full', 'libs/webgl/effects', 'mylibs/utils/utils', 'text!mylibs/preview/views/selectPreview.html'], function(full, effects, utils, template) {
    /*     Select Preview
    
    Select preview shows pages of 6 live previews using webgl effects
    */
    var $container, canvas, ctx, direction, draw, frame, pageAnimation, paused, previews, pub, webgl;
    paused = false;
    canvas = {};
    ctx = {};
    previews = [];
    $container = {};
    webgl = fx.canvas();
    frame = 0;
    direction = "left";
    pageAnimation = function() {
      return {
        pageOut: "slide:" + direction + " fadeOut",
        pageIn: "slideIn:" + direction + " fadeIn"
      };
    };
    draw = function() {
      var preview, _i, _len;
      if (!paused) {
        ctx.drawImage(window.HTML5CAMERA.canvas, 0, 0, canvas.width, canvas.height);
        for (_i = 0, _len = previews.length; _i < _len; _i++) {
          preview = previews[_i];
          frame++;
          if (preview.kind === "face") {
            preview.filter(preview.canvas, canvas);
          } else {
            preview.filter(preview.canvas, canvas, frame);
          }
        }
      }
      return utils.getAnimationFrame()(draw);
    };
    return pub = {
      draw: function() {
        return draw();
      },
      init: function(selector) {
        var bottom, ds, top;
        full.init();
        effects.init();
        canvas = document.createElement("canvas");
        canvas.width = 344;
        canvas.height = 216;
        ctx = canvas.getContext("2d");
        $container = $("" + selector);
        top = {
          el: $("<div class='half'></div>")
        };
        bottom = {
          el: $("<div class='half'></div>")
        };
        ds = new kendo.data.DataSource({
          data: effects.data,
          pageSize: 6,
          change: function() {
            var create;
            previews = [];
            top.data = this.view().slice(0, 3);
            bottom.data = this.view().slice(3, 6);
            create = function(half) {
              var item, _i, _len, _ref, _results;
              half.el.empty();
              _ref = half.data;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                item = _ref[_i];
                _results.push((function() {
                  var $content, $template, content, preview;
                  $template = kendo.template(template);
                  preview = {};
                  $.extend(preview, item);
                  preview.canvas = fx.canvas();
                  content = $template({
                    name: preview.name
                  });
                  $content = $(content);
                  previews.push(preview);
                  $content.find("a").append(preview.canvas).click(function() {
                    paused = true;
                    return $.publish("/preview/full", []);
                  });
                  return half.el.append($content);
                })());
              }
              return _results;
            };
            create(top);
            return create(bottom);
          }
        }, $container.append(top.el), $container.append(bottom.el));
        return ds.read();
      }
    };
  });

}).call(this);
