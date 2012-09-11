(function() {

  define(['Kendo', 'text!mylibs/bar/views/bottom.html'], function(kendo, template) {
    var countdown, pub, states, view, viewModel;
    view = {};
    viewModel = kendo.observable({
      mode: {
        display: "none",
        active: "photo",
        click: function(e) {
          var a;
          a = $(e.target);
          this.set("mode.active", a.data("mode"));
          a.parent().parent().find("a").removeClass("active");
          return a.addClass("active");
        }
      },
      capture: {
        display: "none",
        click: function(e) {
          var capture, mode, startTime, token;
          mode = this.get("mode.active");
          if (mode === "photo" || mode === "paparazzi") {
            states.capture();
            capture = function() {
              return $.publish("/capture/" + mode);
            };
            if (e.ctrlKey) {
              return capture();
            } else {
              return countdown(0, capture);
            }
          } else {
            states.record();
            startTime = Date.now();
            token = $.subscribe("/recording/done", function() {
              $.unsubscribe(token);
              view.el.bar.removeClass("recording");
              view.el.stop.css("border-radius", 100);
              return states.full();
            });
            $.publish("/capture/" + mode);
            view.el.stop.css("border-radius", 0);
            return view.el.bar.addClass("recording");
          }
        }
      },
      thumbnail: {
        src: "images/broke.png",
        display: null
      },
      filters: {
        display: "none",
        click: function() {
          return $.publish("/full/hide");
        }
      }
    });
    countdown = function(position, callback) {
      return $(view.el.counters[position]).kendoStop(true).kendoAnimate({
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
            return view.el.counters.hide();
          }
        }
      });
    };
    states = {
      preview: function() {
        viewModel.set("mode.display", "none");
        viewModel.set("capture.display", "none");
        viewModel.set("filters.display", "none");
        return viewModel.set("thumbnail.display", null);
      },
      capture: function() {
        viewModel.set("thumbnail.display", "none");
        viewModel.set("mode.display", "none");
        viewModel.set("capture.display", "none");
        return viewModel.set("filters.display", "none");
      },
      record: function() {
        viewModel.set("thumbnail.display", "none");
        viewModel.set("mode.display", "none");
        return viewModel.set("filters.display", "none");
      },
      full: function() {
        viewModel.set("thumbnail.display", null);
        viewModel.set("mode.display", null);
        viewModel.set("capture.display", null);
        return viewModel.set("filters.display", null);
      },
      set: function(state) {
        return this[state]();
      }
    };
    return pub = {
      init: function(container) {
        view = new kendo.View(container, template);
        view.render(viewModel, true);
        $.subscribe("/bottom/update", function(state) {
          return states.set(state);
        });
        $.subscribe("/bottom/thumbnail", function(image) {
          return viewModel.set("thumbnail.src", image);
        });
        view.find(".stop", "stop");
        view.find(".counter", "counters");
        view.find(".bar", "bar");
        return view;
      }
    };
  });

}).call(this);
