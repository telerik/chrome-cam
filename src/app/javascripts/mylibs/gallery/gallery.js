(function() {

  define(['mylibs/utils/utils', 'text!mylibs/gallery/views/gallery.html'], function(utils, templateSource) {
    var createPage, loadImages, pub, setupSubscriptionEvents, template;
    template = kendo.template(templateSource);
    loadImages = function() {
      var deferred, token;
      deferred = $.Deferred();
      token = $.subscribe("/pictures/bulk", function(result) {
        var dataSource;
        if (result.message instanceof Array && result.message.length > 0) {
          $.publish("/bar/preview/update", [
            {
              thumbnailURL: result.message.slice(-1)[0].image
            }
          ]);
        }
        $.unsubscribe(token);
        dataSource = new kendo.data.DataSource({
          data: result.message,
          pageSize: 12,
          change: function() {
            return $.publish("/gallery/page", [dataSource]);
          }
        });
        dataSource.read();
        return deferred.resolve(dataSource);
      });
      $.publish("/postman/deliver", [{}, "/file/read", []]);
      return deferred.promise();
    };
    createPage = function(dataSource, $container) {
      var rowLength, rows;
      rowLength = 4;
      rows = [dataSource.view().slice(0 * rowLength, (1 * rowLength)), dataSource.view().slice(1 * rowLength, (2 * rowLength)), dataSource.view().slice(2 * rowLength, (3 * rowLength))];
      return $container.html(template({
        rows: rows
      }));
    };
    setupSubscriptionEvents = function($container) {
      kendo.fx.hide = {
        setup: function(element, options) {
          return $.extend({
            height: 25
          }, options.properties);
        }
      };
      $.subscribe("/gallery/show", function(fileName) {
        return console.log(fileName);
      });
      $.subscribe("/gallery/hide", function() {
        $container.hide();
        return $("#wrap").kendoStop(true).kendoAnimate({
          effects: "expandVertical",
          show: true,
          duration: 1000,
          done: function() {
            return $.publish("/camera/pause", [false]);
          }
        });
      });
      $.subscribe("/gallery/list", function() {
        $.publish("/camera/pause", [true]);
        $container.show();
        return $("#wrap").kendoStop(true).kendoAnimate({
          effects: "expandVertical",
          reverse: true,
          hide: true,
          duration: 1000
        });
      });
      return $.subscribe("/gallery/page", function(dataSource) {
        return createPage(dataSource, $container);
      });
    };
    return pub = {
      init: function(selector) {
        var $container;
        $container = $(selector);
        return loadImages().done(function(dataSource) {
          $container.on("click", ".thumbnail", function() {
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
          $.subscribe("/gallery/add", function(file) {
            return dataSource.add(file);
          });
          return $.publish("/gallery/page", [dataSource]);
        });
      }
    };
  });

}).call(this);
