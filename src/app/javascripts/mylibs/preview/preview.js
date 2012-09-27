(function() {

  define(['mylibs/effects/effects', 'mylibs/utils/utils', 'text!mylibs/preview/views/preview.html'], function(effects, utils, previewTemplate) {
    /*     Select Preview
    
    Select preview shows pages of 6 live previews using webgl effects
    */
    var animation, arrows, canvas, ctx, draw, ds, flipping, frame, isFirstChange, keyboard, page, paused, previews, pub, setThumbnailsToBeUpdated, shouldUpdateThumbnails;
    paused = false;
    canvas = {};
    ctx = {};
    previews = [];
    frame = 0;
    ds = {};
    flipping = false;
    shouldUpdateThumbnails = true;
    setThumbnailsToBeUpdated = function() {
      if (!flipping) return shouldUpdateThumbnails = true;
    };
    setInterval(setThumbnailsToBeUpdated, 1000);
    animation = {
      effects: "pageturn:horizontal",
      reverse: false,
      duration: 800
    };
    isFirstChange = true;
    draw = function() {
      return $.subscribe("/camera/stream", function(stream) {
        var eventData, imageData, preview, previewContext, _i, _len;
        if (!paused) {
          ctx.drawImage(stream.canvas, 0, 0, canvas.width, canvas.height);
          effects.advance(canvas);
          for (_i = 0, _len = previews.length; _i < _len; _i++) {
            preview = previews[_i];
            frame++;
            preview.filter(preview.canvas, canvas, frame, stream.track);
            if (shouldUpdateThumbnails) {
              previewContext = preview.canvas.getContext("2d");
              imageData = previewContext.getImageData(0, 0, preview.canvas.width, preview.canvas.height);
              eventData = {
                width: imageData.width,
                height: imageData.height,
                data: imageData.data,
                key: preview.name
              };
              $.publish("/postman/deliver", [
                {
                  data: eventData
                }, "/preview/thumbnail/request"
              ]);
            }
          }
          return shouldUpdateThumbnails = false;
        }
      });
    };
    keyboard = function(enabled) {
      if (enabled) {
        return $.subscribe("/keyboard/arrow", function(e) {
          if (!flipping) return page(e);
        });
      } else {
        return $.unsubcribe("/keyboard/arrow");
      }
    };
    page = function(direction) {
      arrows.both.hide();
      if (direction === "left") {
        animation.reverse = false;
        if (ds.page() < ds.totalPages()) return ds.page(ds.page() + 1);
      } else {
        animation.reverse = true;
        if (ds.page() > 1) return ds.page(ds.page() - 1);
      }
    };
    arrows = {
      left: null,
      right: null,
      both: null,
      init: function(parent) {
        arrows.left = parent.find(".previous");
        arrows.left.hide();
        arrows.right = parent.find(".next");
        arrows.both = $([arrows.left[0], arrows.right[0]]);
        arrows.left.on("click", function() {
          return page("right");
        });
        return arrows.right.on("click", function() {
          return page("left");
        });
      }
    };
    return pub = {
      draw: function() {
        return draw();
      },
      before: function() {
        return $.publish("/camera/pause", [false]);
      },
      swipe: function(e) {
        if (!flipping) return page(e.direction);
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
        page1 = new kendo.View(selector, null);
        page2 = new kendo.View(selector, null);
        previousPage = page1.render().addClass("page");
        nextPage = page2.render().addClass("page");
        arrows.init($(selector).parent());
        ds = new kendo.data.DataSource({
          data: effects.data,
          pageSize: 6,
          change: function() {
            var flipCompleted, flippy, index, item, tracks, _fn, _i, _len, _ref;
            flipping = true;
            previews = [];
            index = 0;
            tracks = false;
            _ref = this.view();
            _fn = function(item) {
              var data, filter, filters, html, img;
              filter = document.createElement("canvas");
              filter.width = canvas.width;
              filter.height = canvas.height;
              img = document.createElement("img");
              img.width = canvas.width;
              img.height = canvas.height;
              data = {
                effect: item.id,
                name: item.name,
                col: index % 3,
                row: Math.floor(index / 3)
              };
              index++;
              filters = new kendo.View(nextPage, previewTemplate, data);
              html = filters.render();
              html.find(".canvas").append(filter).append(img).click(function() {
                paused = true;
                return $.publish("/full/show", [item]);
              });
              previews.push({
                canvas: filter,
                filter: item.filter,
                name: item.name
              });
              return tracks = tracks || item.tracks;
            };
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              _fn(item);
            }
            $.publish("/postman/deliver", [tracks, "/tracking/enable"]);
            page1.container.find("canvas").hide();
            page1.container.find("img").show();
            shouldUpdateThumbnails = true;
            flipCompleted = function() {
              var justPaged;
              page1.container.find("img").hide();
              page1.container.find("canvas").show();
              justPaged = previousPage;
              previousPage = nextPage;
              nextPage = justPaged;
              justPaged.empty();
              flipping = false;
              if (ds.page() > 1) arrows.left.show();
              if (ds.page() < ds.totalPages()) return arrows.right.show();
            };
            flippy = function() {
              return page1.container.kendoAnimate({
                effects: animation.effects,
                face: animation.reverse ? nextPage : previousPage,
                back: animation.reverse ? previousPage : nextPage,
                duration: animation.duration,
                reverse: animation.reverse,
                complete: flipCompleted
              });
            };
            if (isFirstChange) {
              setTimeout(flipCompleted, 100);
              return isFirstChange = false;
            } else {
              return setTimeout(flippy, 100);
            }
          }
        });
        ds.read();
        $.subscribe("/preview/thumbnail/response/", function(e) {
          return $("[data-filter-name='" + e.key + "']", selector).find("img").attr("src", e.src);
        });
        return $.subscribe("/preview/pause", function(pause) {
          return paused = pause;
        });
      }
    };
  });

}).call(this);
