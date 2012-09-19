(function() {

  define(['Kendo', 'text!mylibs/bar/views/top.html', 'text!mylibs/bar/views/bottom.html'], function(kendo, topTemplate, bottomTemplate) {
    var View;
    return View = (function() {

      function View(top, bottom) {
        var bottomBar, topBar;
        this.top = top;
        this.bottom = bottom;
        topBar = new kendo.View(this.top, topTemplate);
        bottomBar = new kendo.View(this.bottom, bottomTemplate);
        topBar.render();
        bottomBar.render();
      }

      return View;

    })();
  });

}).call(this);
