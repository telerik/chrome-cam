(function() {

  define(['Kendo', 'Glfx', 'mylibs/camera/camera', 'mylibs/bar/bar', 'mylibs/preview/preview', 'mylibs/full/full', 'mylibs/postman/postman', 'mylibs/utils/utils', 'mylibs/gallery/gallery', 'mylibs/events/events', 'libs/record/record', 'text!intro.html'], function(kendo, glfx, camera, bar, preview, full, postman, utils, gallery, events, record, intro) {
    var pub;
    return pub = {
      init: function() {
        events.init();
        postman.init(window.top);
        $.subscribe('/camera/unsupported', function() {
          return $('#pictures').append(intro);
        });
        return camera.init("countdown", function() {
          bar.init("#footer");
          preview.init("#select");
          full.init("#full");
          gallery.init("#gallery");
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
