(function() {

  define(['Kendo', 'mylibs/bar/state', 'text!mylibs/bar/views/bar.html'], function(kendo, state, template) {
    var countdown, el, mode, pub, startTime, viewModel;
    el = {};
    startTime = 0;
    mode = "photo";
    viewModel = kendo.observable({
      mode: {
        click: function(e) {
          var a;
          a = $(e.target);
          mode = a.data("mode");
          el.mode.find("a").removeClass("active");
          return a.addClass("active");
        }
      },
      capture: {
        click: function(e) {
          var capture, token;
          if (mode === "photo") {
            state.set("capture");
            capture = function() {
              return $.publish("/capture/" + mode);
            };
            if (e.ctrlKey) {
              return capture();
            } else {
              return countdown(0, capture);
            }
          } else {
            state.set("recording");
            startTime = Date.now();
            token = $.subscribe("/capture/" + mode + "/completed", function() {
              $.unsubscribe(token);
              el.content.removeClass("recording");
              return el.dot.css("border-radius", "100");
            });
            $.publish("/capture/" + mode);
            el.dot.css("border-radius", "0");
            return el.content.addClass("recording");
          }
        }
      },
      filters: {
        click: function(e) {
          return $.publish("/full/hide");
        }
      },
      gallery: {
        click: function(e) {
          state.set("gallery");
          return $.publish("/gallery/list");
        }
      },
      camera: {
        click: function(e) {
          state.set(state.previous);
          return $.publish("/gallery/hide");
        }
      },
      thumbnail: {
        src: "broken.jpg",
        display: "none"
      }
    });
    countdown = function(position, callback) {
      return $(el.counters[position]).kendoStop(true).kendoAnimate({
        effects: "zoomIn fadeIn",
        duration: 200,
        show: true,
        complete: function() {
          ++position;
          if (position < 3) {
            return setTimeout(function() {
              return countdown(position, callback);
            }, 500);
          } else {
            callback();
            return el.counters.hide();
          }
        }
      });
    };
    return pub = {
      init: function(selector) {
        el.container = $(selector);
        el.content = $(template);
        el.capture = el.content.find(".capture");
        el.capture["in"] = {
          effects: "slideIn:up"
        };
        el.capture.out = {
          effects: "slide:down"
        };
        el.dot = el.capture.find("> div > div");
        el.mode = el.content.find(".mode");
        el.mode["in"] = {
          effects: "slideIn:right"
        };
        el.mode.out = {
          effects: "slide:left"
        };
        el.filters = el.content.find(".filters");
        el.filters["in"] = {
          effects: "slideIn:left fadeIn"
        };
        el.filters.out = {
          effects: "slide:right fadeOut"
        };
        el.share = el.content.find(".share");
        el["delete"] = el.content.find(".delete");
        el.back = el.content.find(".back");
        el.thumbnail = el.content.find(".galleryLink");
        el.thumbnail["in"] = {
          effects: "slideIn:left fadeIn"
        };
        el.thumbnail.out = {
          effects: "slide:right fadeOut"
        };
        el.counters = el.content.find(".countdown > span");
        el.container.append(el.content);
        state = state.init(el);
        kendo.bind(el.container, viewModel);
        $.subscribe("/bar/preview/update", function(message) {
          viewModel.set("thumbnail.src", message.thumbnailURL);
          return el.thumbnail.show();
        });
        return $.subscribe("/bar/update", function(sender) {
          return state.set(sender);
        });
      }
    };
  });

}).call(this);
