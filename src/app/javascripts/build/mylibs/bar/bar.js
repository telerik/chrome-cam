(function() {

  define(['text!mylibs/bar/views/bar.html'], function(template) {
    var pub;
    return pub = {
      init: function(selector) {
        var $container, $content;
        $container = $(selector);
        $content = $(template);
        $content.click(function() {
          return $.publish("/capture/image");
        });
        return $container.append($content);
      }
    };
  });

}).call(this);
