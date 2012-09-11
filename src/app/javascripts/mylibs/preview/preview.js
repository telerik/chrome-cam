(function() {

  define(['mylibs/effects/effects', 'mylibs/utils/utils', 'text!mylibs/preview/views/preview.html', 'text!mylibs/preview/views/half.html', 'text!mylibs/preview/views/page.html'], function(effects, utils, previewTemplate, halfTemplate, pageTemplate) {
    /*     Select Preview
    
    Select preview shows pages of 6 live previews using webgl effects
    */
    var animation, canvas, ctx, draw, ds, flipping, frame, keyboard, page, paused, previews, pub;
    paused = false;
    canvas = {};
    ctx = {};
    previews = [];
    frame = 0;
    ds = {};
    flipping = false;
    animation = {
      effects: "pageturn:horizontal",
      reverse: false,
      duration: 800
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
          if (!flipping) return page(e);
        });
      } else {
        return $.unsubcribe("/events/key/arrow");
      }
    };
    page = function(direction) {
      if (direction === "left") {
        animation.reverse = false;
        if (ds.page() < ds.totalPages()) return ds.page(ds.page() + 1);
      } else {
        animation.reverse = true;
        if (ds.page() > 1) return ds.page(ds.page() - 1);
      }
    };
    return pub = {
      show: function() {
        return $.publish("/bottom/update", ["preview"]);
      },
      draw: function() {
        return draw();
      },
      swipe: function(e) {
        return page(e.direction);
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
        canvas.width = 360;
        canvas.height = 240;
        page1 = new kendo.View(selector, pageTemplate);
        page2 = new kendo.View(selector, pageTemplate);
        previousPage = page1.render();
        nextPage = page2.render();
        ds = new kendo.data.DataSource({
          data: effects.data,
          pageSize: 6,
          change: function() {
            var item, _fn, _i, _len, _ref;
            flipping = true;
            previews = [];
            _ref = this.view();
            _fn = function(item) {
              var data, filter, filters, html;
              filter = document.createElement("canvas");
              filter.width = canvas.width;
              filter.height = canvas.height;
              data = {
                effect: item.id,
                name: item.name
              };
              filters = new kendo.View(nextPage, previewTemplate, data);
              html = filters.render();
              html.find(".canvas").append(filter).click(function() {
                paused = true;
                return $.publish("/full/show", [item]);
              });
              return previews.push({
                canvas: filter,
                filter: item.filter
              });
            };
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              _fn(item);
            }
            return page1.container.kendoAnimate({
              effects: animation.effects,
              face: animation.reverse ? nextPage : previousPage,
              back: animation.reverse ? previousPage : nextPage,
              duration: animation.duration,
              reverse: animation.reverse,
              complete: function() {
                var justPaged;
                justPaged = previousPage;
                previousPage = nextPage;
                nextPage = justPaged;
                justPaged.empty();
                return flipping = false;
              }
            });
          }
        });
        ds.read();
        return $.subscribe("/preview/pause", function(pause) {
          return paused = pause;
        });
      }
    };
  });

}).call(this);
