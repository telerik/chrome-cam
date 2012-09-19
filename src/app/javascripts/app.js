(function() {

  define(['Kendo', 'Glfx', 'mylibs/camera/camera', 'mylibs/bar/bottom', 'mylibs/bar/top', 'mylibs/bar/confirm', 'mylibs/preview/preview', 'mylibs/full/full', 'mylibs/postman/postman', 'mylibs/utils/utils', 'mylibs/gallery/gallery', 'mylibs/gallery/details', 'mylibs/events/events', 'mylibs/file/filewrapper', 'libs/record/record'], function(kendo, glfx, camera, bottom, top, confirm, preview, full, postman, utils, gallery, details, events, filewrapper, record) {
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
          window.APP.confirm = confirm.init("#gallery");
          preview.init("#filters");
          full.init("#capture");
          details.init("#details");
          gallery.init("#thumbnails");
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
