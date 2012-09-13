(function() {

  define(['Kendo', 'Glfx', 'mylibs/camera/camera', 'mylibs/bar/bottom', 'mylibs/bar/top', 'mylibs/preview/preview', 'mylibs/full/full', 'mylibs/postman/postman', 'mylibs/utils/utils', 'mylibs/gallery/gallery', 'mylibs/gallery/details', 'mylibs/share/share', 'mylibs/events/events', 'mylibs/file/filewrapper', 'libs/record/record', 'text!intro.html'], function(kendo, glfx, camera, bottom, top, preview, full, postman, utils, gallery, details, share, events, filewrapper, record, intro) {
    var pub;
    return pub = {
      init: function() {
        window.APP = {};
        window.APP.full = full;
        window.APP.filters = preview;
        window.APP.gallery = gallery;
        events.init();
        postman.init(window.top);
        $.subscribe('/camera/unsupported', function() {
          return $('#pictures').append(intro);
        });
        return camera.init("countdown", function() {
          window.APP.bottom = bottom.init(".bottom");
          window.APP.top = top.init(".top");
          preview.init(".flip");
          full.init("#capture");
          details.init("#details");
          gallery.init("#thumbnails");
          window.APP.share = share.init("#gallery");
          preview.draw();
          $.publish("/postman/deliver", [
            {
              message: ""
            }, "/app/ready"
          ]);
          return window.APP.app = new kendo.mobile.Application(document.body, {
            transition: "overlay:up",
            platform: "blackberry"
          });
        });
      }
    };
  });

}).call(this);
