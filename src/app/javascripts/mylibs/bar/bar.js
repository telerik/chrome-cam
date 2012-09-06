(function() {

  define(['Kendo', 'text!mylibs/bar/views/bar.html'], function(kendo, template) {
    var countdown, el, mode, pub, startTime, viewModel;
    el = {};
    startTime = 0;
    mode = "photo";
    kendo.fx.circle = {
      setup: function(element, options) {
        return $.extend({
          borderRadius: 100
        }, options.properties);
      }
    };
    kendo.fx.square = {
      setup: function(element, options) {
        return $.extend({
          borderRadius: 0
        }, options.properties);
      }
    };
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
            capture = function() {
              return $.publish("/capture/" + mode);
            };
            if (e.ctrlKey) {
              return capture();
            } else {
              return countdown(0, capture);
            }
          } else {
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
        click: function(e) {}
      },
      gallery: {
        click: function(e) {
          return $.publish("/gallery/list");
        }
      },
      camera: {
        click: function(e) {
          return console.log("go back to the camera!");
        }
      }
    });
    countdown = function(position, callback) {
      el.capture.hide();
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
            el.capture.show();
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
        el.capture.show = function() {
          return this.kendoStop(true).kendoAnimate({
            effects: "slideIn:up",
            show: true,
            duration: 200
          });
        };
        el.capture.hide = function() {
          return this.kendoStop(true).kendoAnimate({
            effects: "slide:down",
            show: true,
            duration: 200
          });
        };
        el.dot = el.capture.find("> div > div");
        el.mode = el.content.find(".mode");
        el.mode.show = function() {
          return this.kendoStop(true).kendoAnimate({
            effects: "slideIn:right",
            show: true,
            duration: 200
          });
        };
        el.mode.hide = function() {
          return this.kendoStop(true).kendoAnimate({
            effects: "slide:left",
            hide: true,
            duration: 200
          });
        };
        el.counters = el.content.find(".countdown > span");
        el.content.on("click", ".back", function() {
          return $.publish("/gallery/hide");
        });
        el.container.append(el.content);
        kendo.bind(el.container, viewModel);
        $.subscribe("/bar/preview/update", function(message) {
          var image;
          image = $("<img />", {
            src: message.thumbnailURL,
            width: 72,
            height: 48
          });
          return el.content.find(".galleryLink").empty().append(image).removeClass("hidden");
        });
        $.subscribe("/bar/capture/show", function() {
          el.capture.show();
          return el.mode.show();
        });
        $.subscribe("/bar/capture/hide", function() {
          el.capture.hide();
          return el.mode.hide();
        });
        el.content.addClass("previewMode");
        $.subscribe("/bar/gallerymode/show", function() {
          return el.content.removeClass("previewMode").addClass("galleryMode");
        });
        return $.subscribe("/bar/gallerymode/hide", function() {
          return el.content.removeClass("galleryMode").addClass("previewMode");
        });
      }
    };
  });

}).call(this);
