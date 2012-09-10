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
    el = {};
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
          return page(e);
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
        return $.publish("/bar/update", ["preview"]);
      },
      draw: function() {
        return draw();
      },
      init: function(selector) {
        var nextPage, previousPage;
        effects.init();
        keyboard(true);
        $.subscribe("/previews/pause", function(isPaused) {
          return paused = isPaused;
        });
        canvas = document.createElement("canvas");
        ctx = canvas.getContext("2d");
        canvas.width = 360;
        canvas.height = 240;
        el.container = $(selector).kendoTouch({
          enableSwipe: true,
          swipe: function(e) {
            return page(e.direction);
          }
        });
        el.page1 = $(pageTemplate).appendTo(el.container);
        el.page2 = $(pageTemplate).appendTo(el.container);
        previousPage = el.page1;
        nextPage = el.page2;
        ds = new kendo.data.DataSource({
          data: effects.data,
          pageSize: 6,
          change: function() {
            var bottom, create, top;
            previews = [];
            top = this.view().slice(0, 3);
            bottom = this.view().slice(3, 6);
            create = function(data) {
              var half, item, _fn, _i, _len;
              half = $(halfTemplate);
              _fn = function() {
                var preview, template, thing;
                template = kendo.template(previewTemplate);
                preview = template({
                  effect: item.id,
                  name: item.name
                });
                thing = document.createElement("canvas");
                thing.width = canvas.width;
                thing.height = canvas.height;
                half.append($(preview).find("a").append(thing).end());
                return previews.push({
                  canvas: thing,
                  filter: item.filter
                });
              };
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                item = data[_i];
                _fn();
              }
              return half;
            };
            nextPage.append(create(top));
            nextPage.append(create(bottom));
            return el.container.kendoAnimate({
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
