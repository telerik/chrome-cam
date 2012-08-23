(function() {

  define(['text!mylibs/bar/views/bar.html'], function(template) {
    var pub;
    return pub = {
      init: function(selector) {
        var $container, $content;
        $container = $(selector);
        $content = $(template);
        $content.on("click", ".capture", function() {
          console.log("clicky!");
          return $.publish("/capture/image");
        });
        return $container.append($content);
      }
    };
  });

}).call(this);
