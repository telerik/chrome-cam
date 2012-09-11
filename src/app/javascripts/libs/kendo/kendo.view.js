(function($) {

    var View;
    return kendo.View = (function() {

      function View(container, template, data) {
        
        if (this.container instanceof $) {
          this.container = container
        }
        else {
          this.container = $(container);
        }
        
        this.data = data || {};
        this.template = kendo.template(template);
        this.el = {};
      };

      View.prototype.render = function(viewModel) {
        var html = $(this.template(this.data)).appendTo(this.container);
        if (viewModel) {
          this.viewModel = viewModel;
          kendo.bind(this.container, this.viewModel);
        }
        return this.content = html; 
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

})(jQuery);