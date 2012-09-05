(function() {

  define(['mylibs/effects/effects', 'mylibs/utils/utils', 'text!mylibs/preview/views/preview.html', 'text!mylibs/preview/views/half.html', 'text!mylibs/preview/views/page.html'], function(effects, utils, previewTemplate, halfTemplate, pageTemplate) {
    /*     Select Preview
    
    Select preview shows pages of 6 live previews using webgl effects
    */
    var animation, canvas, ctx, draw, ds, el, frame, keyboard, page, paused, previews, pub, webgl;
    paused = false;
    canvas = {};
    ctx = {};
    previews = [];
    el = {};
    webgl = fx.canvas();
    frame = 0;
    ds = {};
    animation = {
      direction: "left",
      "in": function() {
        return "pageturn";
      },
      out: function() {
        return "pageturn:horizontal";
      }
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
    keyboard = function(enabled) {
      if (enabled) {
        return $.subscribe("/events/key/arrow", function(e) {
          return page(e);
        });
      } else {
        return $.unsubcribe("/events/key/arrow");
      }
    };
    page = function(direction) {
      animation.direction = direction;
      if (direction === "left") {
        if (ds.page() < ds.totalPages()) return ds.page(ds.page() + 1);
      } else {
        if (ds.page() > 1) return ds.page(ds.page() - 1);
      }
    };
    return pub = {
      draw: function() {
        return draw();
      },
      init: function(selector) {
        var nextPage, page1, page2, previousPage;
        effects.init();
        keyboard(true);
        $.subscribe("/previews/pause", function(isPaused) {
          return paused = isPaused;
        });
        canvas = document.createElement("canvas");
        ctx = canvas.getContext("2d");
        canvas.width = webgl.width = 360;
        canvas.height = webgl.width = 240;
        el.container = $(selector).kendoTouch({
          enableSwipe: true,
          swipe: function(e) {
            return page(e.direction);
          }
        });
        page1 = $(pageTemplate).appendTo($container);
        page2 = $(pageTemplate).appendTo($container);
        previousPage = page1;
        nextPage = page2;
        ds = new kendo.data.DataSource({
          data: effects.data,
          pageSize: 6,
          change: function() {
            var bottom, create, top;
            previews = [];
            top = this.view().slice(0, 3);
            bottom = this.view().slice(3, 6);
            create = function(row) {
              var half, item, _fn, _i, _len;
              half = $(halfTemplate);
              _fn = function() {
                var $template, content, preview;
                $template = kendo.template(previewTemplate);
                preview = {};
                $.extend(preview, item);
                preview.canvas = fx.canvas();
                preview.canvas.width = canvas.width;
                preview.canvas.height = canvas.height;
                content = $template({
                  name: preview.name
                });
                content = $(content);
                previews.push(preview);
                content.find("a").append(preview.canvas).click(function() {
                  paused = true;
                  return $.publish("/full/show", [preview]);
                });
                return half.append(content);
              };
              for (_i = 0, _len = row.length; _i < _len; _i++) {
                item = row[_i];
                _fn();
              }
              return half;
            };
            nextPage.append(create(top));
            nextPage.append(create(bottom));
            $.publish("/camera/pause", [true]);
            return el.container.kendoAnimate({
              effects: "pageturn:horizontal",
              face: previousPage,
              back: nextPage,
              duration: 1000,
              complete: function() {
                var justPaged;
                justPaged = previousPage;
                previousPage = nextPage;
                nextPage = justPaged;
                return justPaged.empty();
              }
            });
          }
        });
        return ds.read();
      }
    };
  });

}).call(this);
