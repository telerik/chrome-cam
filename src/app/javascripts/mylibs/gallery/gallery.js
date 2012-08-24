(function() {

  define(['mylibs/utils/utils', 'text!mylibs/gallery/views/gallery.html'], function(utils, template) {
    var loadImages, pub;
    loadImages = function() {
      var deferred, token;
      deferred = $.Deferred();
      token = $.subscribe("/pictures/bulk", function(result) {
        var dataSource;
        $.unsubscribe(token);
        dataSource = new kendo.data.DataSource({
          data: result.message,
          pageSize: 12
        });
        return deferred.resolve(dataSource);
      });
      $.publish("/postman/deliver", [{}, "/file/read", []]);
      return deferred.promise();
    };
    return pub = {
      init: function(selector) {
        var $container, $thumbnailList;
        $container = $(selector);
        $container.append($(template));
        $thumbnailList = $(".thumbnails", $container);
        return loadImages().done(function(dataSource) {
          console.log(dataSource);
          $thumbnailList.on("click", ".thumbnail", function() {
            return $.publish("/gallery/show", [$(this).data("file-name")]);
          });
          $.subscribe("/gallery/hide", function() {
            $container.slideUp();
            return $("#preview").slideDown(function() {
              return $.publish("/previews/pause", [false]);
            });
          });
          $.subscribe("/gallery/show", function(fileName) {
            return console.log(fileName);
          });
          $.subscribe("/gallery/list", function() {
            $.publish("/previews/pause", [true]);
            $container.slideDown();
            return $("#preview").slideUp();
          });
          return $thumbnailList.kendoListView({
            template: kendo.template($("#gallery-thumbnail").html()),
            dataSource: dataSource
          });
        });
      }
    };
  });

}).call(this);
