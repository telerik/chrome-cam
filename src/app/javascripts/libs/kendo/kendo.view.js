(function($) {

    var View;
    return kendo.View = (function() {

      // view constructor. takes in the container or selector
      // a template, and the data for the template if any
      function View(container, template, data) {
        // if a container element is specified
        if (container) {
          // if the container is a jquery object
          if (this.container instanceof $) {
            // set the internal reference
            this.container = container 
          }
          // otherwise
          else {
            // set the internal reference to a jQuery instance
            // TODO: should probably check that this is a string
            //       before trying to wrap it
            this.container = $(container);
          }
        }
        // otherwise return an empty div as the container
        else return this.container = $("<div></div>");
        
        // set the internal data object to the data passed in,
        // or an empty object if nothing was passed
        this.data = data || {};
        // check to make sure we passed in a template
        // otherwise set it to an empty div
        template = template || "<div></div>";
        // create the kendo template object 
        this.template = kendo.template(template);
        // create an el object that will hold all references to 
        // DOM objects in the view as specified by the "find" method
        this.el = {};
      };

      // renders the template and attaches it to the container. returns
      // a content object which is the template itself as DOM object, 
      // not the container
      View.prototype.render = function(viewModel, bind) {
        // render the kendo template and append it to the container
        var html = $(this.template(this.data)).appendTo(this.container);
        // if a view model was passed in
        if (viewModel) {
          // set the viewModel variable equal to it
          this.viewModel = viewModel;
            // check if bind was specified. it's not done automatically
            // since mobile views don't bind this way
            if (bind) {
              // bind the container to the view model
              kendo.bind(this.container, this.viewModel);
            }
        }
        // return the template content as a DOM object
        return this.content = html; 
      };

      // binds the container to the view model
      View.prototype.bind = function(viewModel) {
        this.viewModel = viewModel
        kendo.bind(this.container, this.viewModel)
      };

      // the find method does a simle jQuery find and caches
      // the matched object if a cache string is specified.
      // all cached objects are available off of the el object.
      View.prototype.find = function(selector, cache) {
        // execute the find
        // TODO: Make sure selector is a string
        var match = this.container.find(selector);
        // if a cache is specified
        if (cache) {
          // cache match on the el object by it's specified
          // name
          this.el[cache] = match;
        };
        // return the mached element
        return match;
      };

      return View;

    })();

})(jQuery);