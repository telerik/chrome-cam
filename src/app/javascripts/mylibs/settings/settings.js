(function() {

  define(['Kendo', 'text!mylibs/settings/views/settings.html'], function(kendo, template) {
    var SETTINGS_VIEW, oldView, pub, view, viewModel;
    SETTINGS_VIEW = "#settings";
    view = null;
    oldView = "#home";
    viewModel = kendo.observable({
      show: function() {
        $.publish("/postman/deliver", [false, "/menu/enable"]);
        oldView = window.APP.app.view().id;
        return window.APP.app.navigate(SETTINGS_VIEW);
      },
      hide: function() {
        $.publish("/postman/deliver", [true, "/menu/enable"]);
        return window.APP.app.navigate(oldView);
      }
    });
    return pub = {
      init: function(selector) {
        view = new kendo.View(selector, template);
        view.render(viewModel, true);
        return $.subscribe('/menu/click/chrome-cam-settings-menu', function() {
          return viewModel.show();
        });
      }
    };
  });

}).call(this);
