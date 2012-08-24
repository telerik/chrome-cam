(function() {

  define(['text!mylibs/bar/views/bar.html'], function(template) {
    var pub;
    return pub = {
      init: function(selector) {
        var $capture, $container, $content, $counters;
        $container = $(selector);
        $content = $(template);
        $capture = $content.find(".capture");
        $counters = $content.find(".countdown > span");
        $content.on("click", ".capture", function() {
          var countdown;
          $capture.kendoStop(true).kendoAnimate({
            effects: "zoomOut fadeOut",
            duration: 100,
            hide: "true"
          });
          countdown = function(position) {
            return $($counters[position]).kendoStop(true).kendoAnimate({
              effects: "zoomIn fadeIn",
              duration: 200,
              show: true,
              complete: function() {
                ++position;
                if (position < 3) {
                  return setTimeout(function() {
                    return countdown(position);
                  }, 500);
                } else {
                  console.log("clicky!");
                  $.publish("/full/flash");
                  $.publish("/capture/image");
                  $capture.kendoStop(true).kendoAnimate({
                    effects: "zoomIn fadeIn",
                    duration: 100,
                    show: true
                  });
                  return $counters.kendoStop(true).kendoAnimate({
                    effects: "zoomOut fadeOut",
                    hide: true,
                    duration: 100
                  });
                }
              }
            });
          };
          return countdown(0);
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
