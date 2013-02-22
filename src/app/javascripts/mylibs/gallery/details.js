// Generated by CoffeeScript 1.4.0
(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/details.html'], function(kendo, utils, filewrapper, template) {
    var details, hide, index, keys, page, pub, show, token, tokens, update, updating, viewModel, visible;
    index = 0;
    visible = false;
    details = {};
    tokens = {};
    token = null;
    updating = false;
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
        visible: false
      },
      previous: {
        visible: false
      }
    });
    page = function(direction) {
      if (!(visible || !updating)) {
        return;
      }
      if (direction === "left" && viewModel.previous.visible) {
        updating = true;
        pub.previous();
      }
      if (direction === "right" && viewModel.next.visible) {
        updating = true;
        pub.next();
      }
      return false;
    };
    hide = function() {
      $.publish("/galleryBar/update", ["gallery"]);
      $.publish("/gallery/keyboard", [true]);
      $.publish("/details/hiding");
      keys.unbind();
      return kendo.fx(details.container).zoom("out").play().done(function() {
        $.unsubscribe(tokens["delete"]);
        return tokens["delete"] = null;
      });
    };
    show = function(message) {
      update(message);
      keys.bind();
      tokens["delete"] = $.subscribe("/gallery/delete", function() {
        return hide();
      });
      return kendo.fx(details.container).zoom("in").play().done(function() {
        $.publish("/details/shown");
        return $.publish("/galleryBar/update", ["details"]);
      });
    };
    update = function(message) {
      var _this = this;
      return filewrapper.readFile(message.item).done(function(data) {
        viewModel.set("type", message.item.type);
        viewModel.set("img.src", data.file);
        viewModel.set("next.visible", message.index < message.length - 1);
        viewModel.set("previous.visible", message.index > 0 && message.length > 1);
        index = message.index;
        return updating = false;
      });
    };
    keys = {
      bound: false,
      bind: function() {
        if (this.bound) {
          return;
        }
        tokens.arrow = $.subscribe("/keyboard/arrow", page, true);
        tokens.esc = $.subscribe("/keyboard/esc", hide);
        return this.bound = true;
      },
      unbind: function() {
        if (!this.bound) {
          return;
        }
        $.unsubscribe(tokens.arrow);
        $.unsubscribe(tokens.esc);
        return this.bound = false;
      }
    };
    return pub = {
      init: function(selector) {
        var that,
          _this = this;
        that = this;
        details = new kendo.View(selector, template);
        details.render(viewModel, true);
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
        return $.subscribe("/details/keyboard", function(bind) {
          if (bind) {
            return keys.bind();
          } else {
            return keys.unbind();
          }
        });
      },
      next: function(e) {
        return $.publish("/gallery/at", [index + 1]);
      },
      previous: function(e) {
        return $.publish("/gallery/at", [index - 1]);
      }
    };
  });

}).call(this);
