(function() {

  define(['Kendo', 'text!mylibs/bar/views/top.html'], function(kendo, template) {
    var pub, states, viewModel,
      _this = this;
    viewModel = kendo.observable({
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
        click: function() {
          return $.publish("/gallery/delete");
        }
      }
    });
    states = {
      selected: function() {
        return viewModel.set("selected", true);
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
        _this.view = new kendo.View(container, template);
        _this.view.render(viewModel, true);
        _this.view.find("#back", "back");
        $.subscribe("/top/update", function(state) {
          return states.set(state);
        });
        return _this.view;
      }
    };
  });

}).call(this);
