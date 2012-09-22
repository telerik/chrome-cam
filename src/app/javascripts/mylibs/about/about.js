(function() {

  define(['Kendo', 'text!mylibs/about/views/about.html'], function(kendo, template) {
    var previous, pub, viewModel;
    previous = "#home";
    viewModel = kendo.observable({
      back: function() {
        $.publish("/postman/deliver", [true, "/menu/enable"]);
        return window.APP.app.navigate(previous);
      },
      goto: function(e) {
        return $.publish("/postman/deliver", [$(e.currentTarget).attr("href"), "/tab/open"]);
      }
    });
    return pub = {
      before: function() {
        return $.publish("/postman/deliver", [
          {
            paused: true
          }, "/camera/pause"
        ]);
      },
      hide: function() {
        return $.publish("/postman/deliver", [
          {
            paused: false
          }, "/camera/pause"
        ]);
      },
      init: function(selector) {
        var view;
        view = new kendo.View(selector, template);
        view.render(viewModel, true);
        return $.subscribe('/menu/click/chrome-cam-about-menu', function() {
          $.publish("/postman/deliver", [false, "/menu/enable"]);
          previous = window.APP.app.view().id;
          return window.APP.app.navigate(selector);
        });
      }
    };
  });

}).call(this);
