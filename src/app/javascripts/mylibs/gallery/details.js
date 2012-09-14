(function() {

  define(['Kendo', 'text!mylibs/gallery/views/details.html'], function(kendo, template) {
    var hide, index, pub, show, update, viewModel,
      _this = this;
    index = 0;
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
          return $.publish("/gallery/get", [index + 1]);
        }
      }
    });
    hide = function() {
      return _this.details.container.kendoStop(true).kendoAnimate({
        effects: "zoomOut",
        hide: true
      });
    };
    show = function(message) {
      update(message);
      return _this.details.container.kendoStop(true).kendoAnimate({
        effects: "zoomIn",
        show: true,
        complete: function() {
          return $.publish("/top/update", ["details"]);
        }
      });
    };
    update = function(message) {
      viewModel.set("src", message.src);
      viewModel.set("next.visible", message.index < message.length);
      return index = message.length;
    };
    return pub = {
      init: function(selector) {
        _this.details = new kendo.View(selector, template);
        _this.details.render(viewModel, true);
        $.subscribe("/details/hide", function() {
          return hide();
        });
        $.subscribe("/details/show", function(message) {
          return show(message);
        });
        return $.subscribe("/gallery/update", function(message) {});
      }
    };
  });

}).call(this);
