(function() {

  define(['Kendo', 'text!mylibs/share/views/share.html'], function(kendo, template) {
    var pub, viewModel;
    viewModel = kendo.observable({
      selected: null,
      download: function() {
        var selected;
        selected = this.get("selected");
        return $.publish("/postman/deliver", [
          {
            name: selected.name,
            file: selected.file
          }, "/file/download"
        ]);
      }
    });
    return pub = {
      init: function(selector) {
        var share;
        share = new kendo.View(selector, template);
        share.render(viewModel);
        return share;
      }
    };
  });

}).call(this);
