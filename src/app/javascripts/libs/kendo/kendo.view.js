(function() {

    var View;
    return kendo.View = (function() {

      function View(container, template) {
        this.container = $(container);
        this.template = kendo.template(template);
        this.el = {};
      };

      View.prototype.render = function(viewModel) {
        var html = this.template({});
        this.container.html(html);
        if (viewModel) {
          this.viewModel = viewModel;
          kendo.bind(this.container, this.viewModel);
        }
      };

      View.prototype.bind = function(viewModel) {
        this.viewModel = viewModel
        kendo.bind(this.container, this.viewModel)
      };

      View.prototype.find = function(selector, cache) {
        var match = this.container.find(selector);
        if (cache) {
          this.el[cache] = match;
        };
        return match;
      };

      return View;

    })();

}).call(this);