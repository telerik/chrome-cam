(function() {

  define([], function() {
    var pub;
    return pub = {
      get: function(key, fn) {
        var token;
        token = $.subscribe("/config/value/" + key, function(value) {
          $.unsubscribe(token);
          return fn(value);
        });
        return $.publish("/postman/deliver", [key, "/config/get"]);
      },
      set: function(key, value) {
        return $.publish("/postman/deliver", [
          {
            key: key,
            value: value
          }, "/config/set"
        ]);
      }
    };
  });

}).call(this);
