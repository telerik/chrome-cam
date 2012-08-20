(function() {

  define(['text!mylibs/bar/views/bar.html'], function(template) {
    var pub;
    return pub = {
      init: function(selector) {
        var $container, $content;
        $container = $(selector);
        return $content = kendo.template(template);
      }
    };
  });

}).call(this);
