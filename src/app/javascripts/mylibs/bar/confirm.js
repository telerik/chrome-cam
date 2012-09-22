(function() {

  define(['Kendo', 'text!mylibs/bar/views/confirm.html'], function(kendo, template) {
    var pub, viewModel;
    viewModel = {
      ok: function() {
        $.publish("/gallery/delete");
        return $("#confirm").data("kendoMobilePopOver").close();
      },
      cancel: function() {
        return $("#confirm").data("kendoMobilePopOver").close();
      }
    };
    return pub = {
      init: function(selector) {
        var view;
        view = new kendo.View(selector, template);
        return view.render(viewModel, true);
      }
    };
  });

}).call(this);
