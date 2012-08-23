(function() {

  define(['text!mylibs/bar/views/bar.html'], function(template) {
    var pub;
    return pub = {
      init: function(selector) {
        var $capture, $container, $content;
        $container = $(selector);
        $content = $(template);
        $capture = $content.find(".capture");
        $content.on("click", ".capture", function() {
          console.log("clicky!");
          return $.publish("/capture/image");
        });
        $container.append($content);
        $.subscribe("/bar/capture/show", function() {
          return $capture.kendoStop(true).kendoAnimate({
            effects: "slideIn:up",
            show: true,
            duration: 200
          });
        });
        return $.subscribe("/bar/capture/hide", function() {
          return $capture.kendoStop(true).kendoAnimate({
            effects: "slide:down",
            show: true,
            duration: 200
          });
        });
      }
    };
  });

}).call(this);
