(function() {

  define(['Kendo', 'text!mylibs/bar/views/top.html'], function(kendo, template) {
    var CONFIRM_TEXT, pub, states, viewModel,
      _this = this;
    CONFIRM_TEXT = "Are you sure you want to delete this priceless photo?";
    viewModel = kendo.observable({
      current: null,
      selected: false,
      back: {
        details: false,
        text: "< Camera",
        click: function(e) {
          $.publish("/details/hide");
          states.gallery();
          return e.preventDefault();
        }
      },
      destroy: {
        click: function(e) {
          return $.publish("/confirm/show", [CONFIRM_TEXT, "/gallery/delete"]);
        }
      },
      share: {
        save: function(e) {
          var file;
          file = this.get("current");
          return $.publish("/postman/deliver", [
            {
              name: file.name,
              file: file.file
            }, "/file/download"
          ]);
        }
      }
    });
    states = {
      selected: function() {
        return viewModel.set("selected", true);
      },
      deselected: function() {
        return viewModel.set("selected", false);
      },
      details: function() {
        viewModel.set("back.text", "< Gallery");
        return viewModel.set("back.details", true);
      },
      gallery: function() {
        viewModel.set("back.text", "< Camera");
        return viewModel.set("back.details", false);
      },
      set: function(state) {
        states.current = state;
        return states[state]();
      }
    };
    return pub = {
      init: function(container) {
        var back;
        _this.view = new kendo.View(container, template);
        _this.view.render(viewModel, true);
        back = _this.view.find(".back.button");
        $.subscribe("/top/update", function(state) {
          return states.set(state);
        });
        $.subscribe("/item/selected", function(message) {
          return viewModel.set("current", message.item);
        });
        $.subscribe("/keyboard/esc", function() {
          if (states.current === "details") {
            states.set("gallery");
            return back.trigger("click");
          }
        });
        return _this.view;
      }
    };
  });

}).call(this);
