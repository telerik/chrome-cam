(function() {

  define(['mylibs/utils/utils', 'text!mylibs/gallery/views/gallery.html'], function(utils, template) {
    var loadImages, pub, setupSubscriptionEvents;
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
    setupSubscriptionEvents = function($container) {
      $.subscribe("/gallery/show", function(fileName) {
        return console.log(fileName);
      });
      $.subscribe("/gallery/hide", function() {
        $container.kendoStop().kendoAnimate({
          effect: "slide:down",
          duration: 1000,
          hide: true
        });
        return $("#preview").kendoStop().kendoAnimate({
          effect: "slideIn:down",
          duration: 1000,
          show: true,
          complete: function() {
            return $.publish("/previews/pause", [false]);
          }
        });
      });
      return $.subscribe("/gallery/list", function() {
        $.publish("/previews/pause", [true]);
        $container.kendoStop().kendoAnimate({
          effect: "slideIn:up",
          duration: 1000,
          show: true
        });
        return $("#preview").kendoStop().kendoAnimate({
          effect: "slide:up",
          duration: 1000,
          hide: true
        });
      });
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
          $container.kendoMobileSwipe(function(e) {
            if (e.direction === "right" && dataSource.page() > 1) {
              dataSource.page(dataSource.page() - 1);
            }
            if (e.direction === "left" && dataSource.page() < dataSource.totalPages()) {
              return dataSource.page(dataSource.page() + 1);
            }
          });
          setupSubscriptionEvents($container);
          return $thumbnailList.kendoListView({
            template: kendo.template($("#gallery-thumbnail").html()),
            dataSource: dataSource
          });
        });
      }
    };
  });

}).call(this);
