(function() {

  define(['mylibs/camera/camera', 'mylibs/bar/bar', 'mylibs/preview/preview', 'mylibs/full/full', 'mylibs/postman/postman', 'mylibs/utils/utils', 'text!intro.html'], function(camera, bar, preview, full, postman, utils) {
    var pub;
    return pub = {
      init: function() {
        postman.init();
        $.subscribe('/camera/unsupported', function() {
          return $('#pictures').append(intro);
        });
        return camera.init("countdown", function() {
          bar.init("#footer");
          preview.init("#select");
          full.init("#full");
          preview.draw();
          return $.publish("/postman/deliver", [
            {
              message: ""
            }, "/app/ready"
          ]);
        });
      }
    };
  });

}).call(this);
