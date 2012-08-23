(function() {

  define(['libs/webgl/effects', 'mylibs/utils/utils', 'text!mylibs/preview/views/preview.html', 'text!mylibs/preview/views/half.html', 'text!mylibs/preview/views/page.html'], function(effects, utils, previewTemplate, halfTemplate, pageTemplate) {
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
          ctx.drawImage(stream.canvas, 0, 0, canvas.width, canvas.height);
          _results = [];
          for (_i = 0, _len = previews.length; _i < _len; _i++) {
            preview = previews[_i];
            frame++;
            _results.push(preview.filter(preview.canvas, canvas, frame, stream.track));
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
        var $currentPage, $nextPage, bottom, currentPage, ds, nextPage, top;
        effects.init();
        $.subscribe("/previews/pause", function(isPaused) {
          return paused = isPaused;
        });
        canvas = document.createElement("canvas");
        ctx = canvas.getContext("2d");
        canvas.width = 360;
        canvas.height = 240;
        $container = $(selector);
        $container.kendoMobileSwipe(function() {
          $.publish("/camera/pause", [true]);
          if (ds.page() < ds.totalPages()) {
            return ds.page(ds.page() + 1);
          } else {
            return ds.page(1);
          }
        }, {
          surface: $container
        });
        top = {
          el: $(halfTemplate)
        };
        bottom = {
          el: $(halfTemplate)
        };
        $currentPage = $(pageTemplate).appendTo($container);
        $nextPage = $(pageTemplate).appendTo($container);
        currentPage = $currentPage;
        nextPage = $nextPage;
        currentPage = $nextPage;
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
                  $template = kendo.template(previewTemplate);
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
                    return $.publish("/full/show", [preview]);
                  });
                  return half.el.append($content);
                })());
              }
              return _results;
            };
            create(top);
            create(bottom);
            nextPage.append(top.el);
            return nextPage.append(bottom.el);
          }
        });
        return ds.read();
      }
    };
  });

}).call(this);
