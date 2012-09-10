(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/gallery.html', 'text!mylibs/gallery/views/details.html'], function(kendo, utils, filewrapper, templateSource, detailsTemplateSource) {
    var createDetailsViewModel, createPage, detailsTemplate, files, loadImages, numberOfRows, pub, rowLength, setupSubscriptionEvents, template;
    template = kendo.template(templateSource);
    detailsTemplate = kendo.template(detailsTemplateSource);
    rowLength = 4;
    numberOfRows = 4;
    files = [];
    loadImages = function() {
      var deferred;
      deferred = $.Deferred();
      filewrapper.list().done(function(f) {
        var dataSource, file, photos;
        files = f;
        if (files && files.length > 0) {
          photos = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = files.length; _i < _len; _i++) {
              file = files[_i];
              if (file.type === 'jpg') _results.push(file);
            }
            return _results;
          })();
          if (photos.length > 0) {
            filewrapper.readFile(photos[photos.length - 1].name).done(function(latestPhoto) {
              return $.publish("/bar/preview/update", [
                {
                  thumbnailURL: latestPhoto.file
                }
              ]);
            });
          }
        }
        dataSource = new kendo.data.DataSource({
          data: files,
          pageSize: rowLength * numberOfRows,
          change: function() {
            return $.publish("/gallery/page", [dataSource]);
          },
          sort: {
            dir: "desc",
            field: "name"
          }
        });
        dataSource.read();
        return deferred.resolve(dataSource);
      });
      $.publish("/postman/deliver", [{}, "/file/read"]);
      return deferred.promise();
    };
    createPage = function(dataSource, $container) {
      var file, i, rows, _i, _len, _ref;
      rows = (function() {
        var _results;
        _results = [];
        for (i = 0; 0 <= numberOfRows ? i < numberOfRows : i > numberOfRows; 0 <= numberOfRows ? i++ : i--) {
          _results.push(dataSource.view().slice(i * rowLength, ((i + 1) * rowLength)));
        }
        return _results;
      })();
      _ref = dataSource.view();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        filewrapper.readFile(file.name).done(function(file) {
          return $container.find("[data-file-name='" + file.name + "']").attr("src", file.file);
        });
      }
      return $container.html(template({
        rows: rows
      }));
    };
    createDetailsViewModel = function(message) {
      var viewModel;
      viewModel = {
        deleteItem: function() {
          var _this = this;
          return filewrapper.deleteFile(this.filename).done(function() {
            return _this.close();
          });
        },
        close: function() {
          return $.publish("/gallery/details/hide");
        },
        canGoToNext: function() {
          return this.get("indexInGallery") > 0;
        },
        canGoToPrevious: function() {
          return this.get("indexInGallery") < files.length - 1;
        },
        goToNext: function() {
          return this.init(files[this.get("indexInGallery") - 1]);
        },
        goToPrevious: function() {
          return this.init(files[this.get("indexInGallery") + 1]);
        },
        getIndexInGallery: function() {
          var i, _ref;
          for (i = 0, _ref = files.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
            if (files[i].name === this.get("filename")) return i;
          }
        },
        isVideo: function() {
          return this.get("type") === "webm";
        },
        init: function(message) {
          var _this = this;
          this.set("filename", message.name);
          this.set("src", message.file || "");
          this.set("type", message.type);
          this.set("indexInGallery", this.getIndexInGallery());
          if (!message.file) {
            filewrapper.readFile(this.get("filename")).done(function(file) {
              return _this.set("src", file.file);
            });
          }
          return this;
        }
      };
      return kendo.observable(viewModel).init(message);
    };
    setupSubscriptionEvents = function($container) {
      kendo.fx.hide = {
        setup: function(element, options) {
          return $.extend({
            height: 25
          }, options.properties);
        }
      };
      $.subscribe("/gallery/details/hide", function() {
        return $container.find(".details").kendoStop(true).kendoAnimate({
          effects: "zoomOut",
          hide: true
        });
      });
      $.subscribe("/gallery/details/show", function(message) {
        var $details, model;
        model = createDetailsViewModel(message);
        $container.find(".details").remove();
        $details = $(detailsTemplate(model));
        kendo.bind($details, model);
        $container.append($details);
        return $details.kendoStop(true).kendoAnimate({
          effects: "zoomIn",
          show: true
        });
      });
      $.subscribe("/gallery/hide", function() {
        console.log("hide gallery");
        $.publish("/camera/pause", [false]);
        return $.publish("/bar/gallerymode/hide");
      });
      $.subscribe("/gallery/list", function() {
        console.log("show gallery");
        return $.publish("/bar/gallerymode/show");
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
          var changePage;
          console.log("done loading images");
          $container.on("dblclick", ".thumbnail", function() {
            var $media;
            $media = $(this).children().first();
            return $.publish("/gallery/details/show", [
              {
                src: $media.attr("src"),
                type: $media.data("media-type"),
                name: $media.data("file-name")
              }
            ]);
          });
          $container.on("click", ".thumbnail", function() {
            $(selector).find(".thumbnail").each(function() {
              return $(this).removeClass("selected");
            });
            return $(this).addClass("selected");
          });
          changePage = function(direction) {
            if (direction > 0 && dataSource.page() > 1) {
              dataSource.page(dataSource.page() - 1);
            }
            if (direction < 0 && dataSource.page() < dataSource.totalPages()) {
              return dataSource.page(dataSource.page() + 1);
            }
          };
          $container.kendoMobileSwipe(function(e) {
            return changePage((e.direction === "right") - (e.direction === "left"));
          });
          $.subscribe("/events/key/arrow", function(e) {
            return changePage((e === "down") - (e === "up"));
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
