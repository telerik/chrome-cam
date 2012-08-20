(function() {

  define(['libs/webgl/effects', 'mylibs/utils/utils', 'text!mylibs/preview/views/selectPreview.html'], function(effects, utils, template) {
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
      return $.subscribe("/camera/stream", function(stream) {
        var preview, _i, _len, _results;
        if (!paused) {
          ctx.drawImage(stream, 0, 0, canvas.width, canvas.height);
          _results = [];
          for (_i = 0, _len = previews.length; _i < _len; _i++) {
            preview = previews[_i];
            frame++;
            _results.push(preview.filter(preview.canvas, canvas, frame));
          }
          return _results;
        }
      });
    };
    return pub = {
      draw: function() {
        return draw();
      },
      init: function(selector) {
        var bottom, ds, top;
        effects.init();
        $.subscribe("/previews/pause", function(doPause) {
          return paused = doPause;
        });
        canvas = document.createElement("canvas");
        canvas.width = 400;
        canvas.height = 300;
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
                    var x, y;
                    x = $(this).offset().left;
                    y = $(this).offset().top;
                    console.info(x);
                    console.info(y);
                    paused = true;
                    return $.publish("/full/show", [preview, x, y]);
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
