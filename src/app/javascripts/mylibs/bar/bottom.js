// Generated by CoffeeScript 1.4.0
(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/navigation/navigation', 'text!mylibs/bar/views/bottom.html', 'text!mylibs/bar/views/thumbnail.html'], function(kendo, utils, navigation, template, thumbnailTemplate) {
    var BROKEN_IMAGE, countdown, paused, pub, states, view, viewModel;
    BROKEN_IMAGE = utils.placeholder.image();
    paused = false;
    view = {};
    viewModel = kendo.observable({
      processing: {
        visible: false
      },
      mode: {
        visible: false,
        active: "photo"
      },
      capture: {
        visible: true
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
        open: false,
        css: function() {}
      }
    });
    countdown = function(position, callback) {
      return $("span", view.el.counters[position]).kendoStop(true).kendoAnimate({
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
            view.el.counters.hide();
            return $("span", view.el.counters).hide();
          }
        }
      });
    };
    states = {
      capture: function() {
        viewModel.set("mode.visible", false);
        viewModel.set("capture.visible", false);
        return viewModel.set("filters.visible", false);
      },
      full: function() {
        viewModel.set("mode.visible", true);
        viewModel.set("capture.visible", true);
        return viewModel.set("filters.visible", true);
      },
      set: function(state) {
        return this[state]();
      }
    };
    return pub = {
      pause: function(pausing) {
        return paused = pausing;
      },
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
          if (file) {
            thumbnail = new kendo.View(view.el.galleryLink, thumbnailTemplate, file);
            thumbnail.render();
            return viewModel.set("thumbnail.enabled", true);
          } else {
            return viewModel.set("thumbnail.enabled", false);
          }
        });
        $.subscribe("/keyboard/space", function(e) {
          if (paused) {
            return;
          }
          if (viewModel.get("capture.visible")) {
            return pub.capture(e);
          }
        });
        view.find(".stop", "stop");
        view.find(".counter", "counters");
        view.find(".bar", "bar");
        view.find(".filters", "filters");
        view.find(".capture", "capture");
        return view;
      },
      capture: function(e) {
        var capture, mode;
        $.publish("/full/capture/begin");
        mode = viewModel.get("mode.active");
        states.capture();
        capture = function() {
          $.publish("/capture/" + mode);
          return $.publish("/full/capture/end");
        };
        view.el.counters.css({
          "display": "block"
        });
        $.publish("/countdown/" + mode);
        if (event.ctrlKey || event.metaKey) {
          return capture();
        } else {
          return countdown(0, capture);
        }
      },
      filters: function(e) {
        viewModel.set("filters.open", !viewModel.filters.open);
        view.el.filters.toggleClass("selected", viewModel.filters.open);
        return $.publish("/full/filters/show", [viewModel.filters.open]);
      },
      mode: function(e) {
        var a;
        a = $(e.target).closest("a");
        viewModel.set("mode.active", a.data("mode"));
        a.closest(".bar").find("a").removeClass("selected");
        return a.addClass("selected");
      },
      gallery: function() {
        return navigation.navigate("#gallery");
      }
    };
  });

}).call(this);
