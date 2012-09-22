(function() {

  define([], function() {
    var pub;
    return pub = {
      init: function() {
        var p;
        p = function(name, key) {
          return $.publish("/keyboard/" + name, [key]);
        };
        return $(document).keydown(function(e) {
          switch (e.which) {
            case 37:
              return p("arrow", "left");
            case 39:
              return p("arrow", "right");
            case 38:
              return p("arrow", "up");
            case 40:
              return p("arrow", "down");
            case 27:
              return p("esc", "esc");
            case 32:
              return p("space", {
                ctrlKey: e.ctrlKey
              });
          }
        });
      }
    };
  });

}).call(this);
