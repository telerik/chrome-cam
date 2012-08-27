(function() {

  define([], function() {
    var pub;
    return pub = {
      init: function() {
        return $(document).keydown(function(e) {
          if (e.keyCode === 37) $.publish("/events/key/arrow", ["left"]);
          if (e.keyCode === 39) return $.publish("/events/key/arrow", ["right"]);
        });
      }
    };
  });

}).call(this);
