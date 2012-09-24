(function() {

  define(['Kendo', 'text!mylibs/bar/views/bottom.html', 'text!mylibs/bar/views/thumbnail.html'], function(kendo, template, thumbnailTemplate) {
    var BROKEN_IMAGE, countdown, pub, states, view, viewModel;
    BROKEN_IMAGE = "styles/images/photoPlaceholder.png";
    view = {};
    viewModel = kendo.observable({
      processing: {
        visible: false
      },
      mode: {
        visible: false,
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
        visible: false,
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
              return states.full();
            });
            $.publish("/capture/" + mode);
            view.el.stop.css("border-radius", 0);
            return view.el.bar.addClass("recording");
          }
        }
      },
      thumbnail: {
        src: BROKEN_IMAGE,
        visible: function() {
          return this.get("enabled") && this.get("active");
        },
        enabled: false,
        active: true
      },
      filters: {
        visible: false,
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
        viewModel.set("mode.visible", false);
        viewModel.set("capture.visible", false);
        viewModel.set("filters.visible", false);
        return viewModel.set("thumbnail.active", true);
      },
      capture: function() {
        viewModel.set("thumbnail.active", true);
        viewModel.set("mode.visible", false);
        viewModel.set("capture.visible", false);
        return viewModel.set("filters.visible", false);
      },
      record: function() {
        viewModel.set("thumbnail.active", false);
        viewModel.set("mode.visible", false);
        return viewModel.set("filters.visible", false);
      },
      full: function() {
        viewModel.set("processing.visible", false);
        viewModel.set("thumbnail.active", true);
        viewModel.set("mode.visible", true);
        viewModel.set("capture.visible", true);
        return viewModel.set("filters.visible", true);
      },
      processing: function() {
        viewModel.set("processing.visible", true);
        viewModel.set("capture.visible", false);
        view.el.bar.removeClass("recording");
        return view.el.stop.css("border-radius", 100);
      },
      set: function(state) {
        return this[state]();
      }
    };
    return pub = {
      init: function(container) {
        view = new kendo.View(container, template);
        view.render(viewModel, true);
        view.find(".galleryLink", "galleryLink");
        $.subscribe("/bottom/update", function(state) {
          return states.set(state);
        });
        $.subscribe("/bottom/thumbnail", function(file) {
          var thumbnail;
          view.el.galleryLink.empty();
          thumbnail = new kendo.View(view.el.galleryLink, thumbnailTemplate, file);
          thumbnail.render();
          return viewModel.set("thumbnail.enabled", true);
        });
        $.subscribe("/keyboard/space", function(e) {
          return viewModel.capture.click.call(viewModel, e);
        });
        view.find(".stop", "stop");
        view.find(".counter", "counters");
        view.find(".bar", "bar");
        return view;
      }
    };
  });

}).call(this);
