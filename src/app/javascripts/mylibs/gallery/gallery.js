(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/gallery.html', 'text!mylibs/gallery/views/details.html'], function(kendo, utils, filewrapper, templateSource, detailsTemplateSource) {
    var createDetailsViewModel, createPage, deleteFile, detailsTemplate, el, files, getElementForFile, loadImages, numberOfRows, pub, rowLength, setupSubscriptionEvents, template;
    template = kendo.template(templateSource);
    detailsTemplate = kendo.template(detailsTemplateSource);
    rowLength = 4;
    numberOfRows = 4;
    files = [];
    el = {};
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
              return $.publish("/bottom/thumbnail", [latestPhoto.file]);
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
    getElementForFile = function(fileName) {
      return el.container.find("[data-file-name='" + fileName + "']");
    };
    createPage = function(dataSource) {
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
          return getElementForFile(file.name).attr("src", file.file);
        });
      }
      return el.container.html(template({
        rows: rows
      }));
    };
    deleteFile = function(filename) {
      return filewrapper.deleteFile(filename).done(function() {
        return $.publish("/gallery/remove", [filename]);
      });
    };
    createDetailsViewModel = function(message) {
      var viewModel;
      viewModel = {
        deleteItem: function() {
          this.close();
          return deleteFile(this.filename);
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
    setupSubscriptionEvents = function() {
      kendo.fx.hide = {
        setup: function(element, options) {
          return $.extend({
            height: 25
          }, options.properties);
        }
      };
      $.subscribe("/gallery/details/hide", function() {
        return el.container.find(".details").kendoStop(true).kendoAnimate({
          effects: "zoomOut",
          hide: true
        });
      });
      $.subscribe("/gallery/details/show", function(message) {
        var $details, model;
        model = createDetailsViewModel(message);
        el.container.find(".details").remove();
        $details = $(detailsTemplate(model));
        kendo.bind($details, model);
        el.container.append($details);
        return $details.kendoStop(true).kendoAnimate({
          effects: "zoomIn",
          show: true
        });
      });
      $.subscribe("/gallery/hide", function() {
        $.publish("/camera/pause", [false]);
        return $.publish("/bar/gallerymode/hide");
      });
      return $.subscribe("/gallery/page", function(dataSource) {
        return createPage(dataSource);
      });
    };
    return pub = {
      view: {
        before: function() {
          el.container.height($(window).height());
          return el.container.width($(window).width());
        },
        show: function() {}
      },
      init: function(selector) {
        var $container;
        $container = $(selector);
        el.container = $container;
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
            var item;
            $(selector).find(".thumbnail").each(function() {
              return $(this).removeClass("selected");
            });
            $(this).addClass("selected");
            item = $(this).children();
            return $.publish("/item/selected", [
              {
                name: item.data("file-name"),
                file: item.attr("src")
              }
            ]);
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
          $.subscribe("/keyboard/arrow", function(e) {
            return changePage((e === "down") - (e === "up"));
          });
          setupSubscriptionEvents();
          $.subscribe("/gallery/add", function(file) {
            return dataSource.add(file);
          });
          $.subscribe("/gallery/remove", function(filename) {
            return getElementForFile(filename).kendoAnimate({
              effects: "fadeOut",
              complete: function() {
                var deleted, file, _i, _len, _ref;
                _ref = dataSource._data;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  file = _ref[_i];
                  if (file.name === filename) deleted = file;
                }
                return dataSource.remove(deleted);
              }
            });
          });
          return $.publish("/gallery/page", [dataSource]);
        });
      }
    };
  });

}).call(this);
