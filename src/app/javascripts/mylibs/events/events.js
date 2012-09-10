(function() {

  define([], function() {
    var pub;
    return pub = {
      init: function() {
        return $(document).keydown(function(e) {
          var arrowKeys;
          arrowKeys = {
            37: "left",
            39: "right",
            38: "up",
            40: "down"
          };
          if (e.keyCode in arrowKeys) {
            return $.publish("/events/key/arrow", arrowKeys[e.keyCode]);
          }
        });
      }
    };
  });

}).call(this);
