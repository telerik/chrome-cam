(function() {

  define(['text!mylibs/bar/views/bar.html'], function(template) {
    var countdown, el, mode, pub;
    mode = "image";
    el = {};
    kendo.fx.circle = {
      setup: function(element, options) {
        return $.extend({
          borderRadius: 100
        }, options.properties);
      }
    };
    kendo.fx.square = {
      setup: function(element, options) {
        return $.extend({
          borderRadius: 0
        }, options.properties);
      }
    };
    countdown = function(position, callback) {
      el.$capture.hide();
      return $(el.$counters[position]).kendoStop(true).kendoAnimate({
        effects: "zoomIn fadeIn",
        duration: 200,
        show: true,
        complete: function() {
          ++position;
          if (position < 3) {
            return setTimeout(function() {
              return countdown(position, callback);
            }, 500);
          } else {
            callback();
            el.$capture.show();
            return el.$counters.hide();
          }
        }
      });
    };
    return pub = {
      init: function(selector) {
        var $container;
        $container = $(selector);
        el.$content = $(template);
        el.$capture = el.$content.find(".capture");
        el.$dot = el.$capture.find("> div > div");
        el.$counters = el.$content.find(".countdown > span");
        el.$content.find(".mode").on("click", "a", function() {
          mode = $(this).data("mode");
          return el.$dot.kendoStop().kendoAnimate({
            effects: $(this).data("shape")
          });
        });
        el.$content.on("click", ".capture", function() {
          if (mode === "image") {
            return countdown(0, function() {
              return $.publish("/capture/" + mode);
            });
          } else {
            return $.publish("/capture/" + mode);
          }
        });
        el.$content.find(".galleryLink").toggle(function() {
          return $.publish("/gallery/list", function() {
            return $.publish("/gallery/hide");
          });
        });
        $container.append(el.$content);
        $.subscribe("/bar/preview/update", function(message) {
          var $image;
          console.log(message);
          $image = $("<img />", {
            src: message.thumbnailURL,
            width: 72,
            height: 48
          });
          return el.$content.find(".galleryLink").empty().append($image);
        });
        $.subscribe("/bar/capture/show", function() {
          return el.$capture.kendoStop(true).kendoAnimate({
            effects: "slideIn:up",
            show: true,
            duration: 200
          });
        });
        $.subscribe("/bar/capture/hide", function() {
          return el.$capture.kendoStop(true).kendoAnimate({
            effects: "slide:down",
            show: true,
            duration: 200
          });
        });
        $(".photo", el.$container).on("click", function() {
          var recordMode;
          $(".mode a", el.$container).removeClass("active");
          $(this).addClass("active");
          return recordMode = "image";
        });
        return $(".video", el.$container).on("click", function() {
          var recordMode;
          $(".mode a", el.$container).removeClass("active");
          $(this).addClass("active");
          return recordMode = "video/record";
        });
      }
    };
  });

}).call(this);
