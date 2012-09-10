(function() {

  define(['Kendo', 'Glfx', 'mylibs/camera/camera', 'mylibs/bar/bar', 'mylibs/preview/preview', 'mylibs/full/full', 'mylibs/postman/postman', 'mylibs/utils/utils', 'mylibs/gallery/gallery', 'mylibs/events/events', 'mylibs/file/filewrapper', 'libs/record/record', 'text!intro.html'], function(kendo, glfx, camera, bar, preview, full, postman, utils, gallery, events, filewrapper, record, intro) {
    var pub;
    return pub = {
      init: function() {
        window.APP = {};
        window.APP.full = full;
        window.APP.preview = preview;
        events.init();
        postman.init(window.top);
        $.subscribe('/camera/unsupported', function() {
          return $('#pictures').append(intro);
        });
        return camera.init("countdown", function() {
          var app;
          bar.init(".footer");
          preview.init(".flip");
          full.init(".full");
          gallery.init("#gallery");
          preview.draw();
          $.publish("/postman/deliver", [
            {
              message: ""
            }, "/app/ready"
          ]);
          return app = new kendo.mobile.Application(document.body, {
            transition: "overlay:up",
            platform: "blackberry"
          });
        });
      }
    };
  });

}).call(this);
