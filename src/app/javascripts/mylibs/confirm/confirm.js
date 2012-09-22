(function() {

  define(['Kendo', 'text!mylibs/confirm/views/confirm.html'], function(kendo, template) {
    var pub, view, viewModel;
    view = {};
    viewModel = kendo.observable({
      callback: "",
      ok: function(e) {
        view.container.data("kendoMobileModalView").close();
        return $.publish(this.get("callback"));
      },
      cancel: function(e) {
        return view.container.data("kendoMobileModalView").close();
      }
    });
    return pub = {
      init: function(selector) {
        view = new kendo.View(selector, template);
        view.render(viewModel, true);
        view.find(".message", "message");
        return $.subscribe("/confirm/show", function(message, callback) {
          viewModel.set("callback", callback);
          view.el.message.html(message);
          return view.container.data("kendoMobileModalView").open();
        });
      }
    };
  });

}).call(this);
