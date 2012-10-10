// Generated by CoffeeScript 1.3.3
(function() {

  define(['Kendo', 'mylibs/utils/utils', 'text!mylibs/gallery/views/details.html'], function(kendo, utils, template) {
    var hide, index, pub, show, update, viewModel, visible,
      _this = this;
    index = 0;
    visible = false;
    viewModel = kendo.observable({
      video: {
        src: function() {
          return utils.placeholder.image();
        }
      },
      img: {
        src: function() {
          return utils.placeholder.image();
        }
      },
      type: "jpeg",
      isVideo: function() {
        return this.get("type") === "webm";
      },
      next: {
        visible: false,
        click: function(e) {
          return $.publish("/gallery/at", [index + 1]);
        }
      },
      previous: {
        visible: false,
        click: function(e) {
          return $.publish("/gallery/at", [index - 1]);
        }
      }
    });
    hide = function() {
      $.publish("/top/update", ["gallery"]);
      return _this.details.container.kendoStop(true).kendoAnimate({
        effects: "zoomOut",
        hide: true,
        complete: function() {
          return $.unsubscribe("/gallery/delete");
        }
      });
    };
    show = function(message) {
      update(message);
      return _this.details.container.kendoStop(true).kendoAnimate({
        effects: "zoomIn",
        show: true,
        complete: function() {
          $.publish("/top/update", ["details"]);
          return $.subscribe("/gallery/delete", function() {
            return hide();
          });
        }
      });
    };
    update = function(message) {
      viewModel.set("type", message.item.type);
      viewModel.set("img.src", message.item.file);
      viewModel.set("next.visible", message.index < message.length - 1);
      viewModel.set("previous.visible", message.index > 0 && message.length > 1);
      return index = message.index;
    };
    return pub = {
      init: function(selector) {
        var page;
        _this.details = new kendo.View(selector, template);
        _this.details.render(viewModel, true);
        $.subscribe("/details/hide", function() {
          visible = false;
          return hide();
        });
        $.subscribe("/details/show", function(message) {
          visible = true;
          return show(message);
        });
        $.subscribe("/details/update", function(message) {
          return update(message);
        });
        page = function(direction) {
          if (!visible) {
            return;
          }
          if (direction === "left" && viewModel.previous.visible) {
            viewModel.previous.click();
          }
          if (direction === "right" && viewModel.next.visible) {
            viewModel.next.click();
          }
          return false;
        };
        return $.subscribe("/keyboard/arrow", page, true);
      }
    };
  });

}).call(this);
