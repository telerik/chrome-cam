(function() {

  define([], function() {
    var pub;
    return pub = {
      init: function() {
        return $(document).keydown(function(e) {
<<<<<<< HEAD
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
=======
          if (e.keyCode === 37) $.publish("/events/key/arrow", ["left"]);
          if (e.keyCode === 39) return $.publish("/events/key/arrow", ["right"]);
>>>>>>> 684a87a9f0e83b1551bd811a5627479f2536fc2f
        });
      }
    };
  });

}).call(this);
