(function() {

  define(['Kendo', 'text!mylibs/gallery/views/details.html'], function(kendo, template) {
    var hide, pub, show, viewModel,
      _this = this;
    viewModel = kendo.observable({
      src: null,
      type: "jpeg",
      isVideo: function() {
        return this.get("type") === "webm";
      },
      previous: {
        visible: false,
        click: function(e) {
          return console.log("previous");
        }
      },
      next: {
        visible: false,
        click: function(e) {
          return console.log("next");
        }
      }
    });
    hide = function() {
      return details.container.kendoStop(true).kendoAnimate({
        effects: "zoomOut",
        hide: true
      });
    };
    show = function(message) {
      return details.container.kendoStop(true).kendoAnimate({
        effects: "zoomIn",
        show: true,
        complete: function() {
          viewModel.set("src", message.src);
          return $.publish("/top/update", ["details"]);
        }
      });
    };
    return pub = {
      init: function(selector) {
        _this.details = new kendo.View(selector, template);
        details.render(viewModel, true);
        $.subscribe("/details/hide", function() {
          return hide();
        });
        return $.subscribe("/details/show", function(message) {
          return show(message);
        });
      }
    };
  });

}).call(this);
