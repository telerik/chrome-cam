(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/row.html'], function(kendo, utils, filewrapper, template) {
    var deleteFile, destroy, dim, ds, el, files, gallery, page, pub, viewModel,
      _this = this;
    dim = {
      cols: 4,
      rows: 4
    };
    ds = {};
    files = [];
    gallery = {};
    el = {};
    viewModel = kendo.observable({
      thumbnail: {
        click: function(e) {
          gallery.container.find(".thumbnail").removeClass("selected");
          return $(e).addClass("selected");
        }
      }
    });
    deleteFile = function(filename) {
      return filewrapper.deleteFile(filename).done(function() {
        return $.publish("/gallery/remove", [filename]);
      });
    };
    page = function(direction) {
      if (direction > 0 && _this.ds.page() > 1) _this.ds.page(_this.ds.page() - 1);
      if (direction < 0 && _this.ds.page() < _this.ds.totalPages()) {
        return _this.ds.page(_this.ds.page() + 1);
      }
    };
    destroy = function() {
      return gallery.find("[data-file-name='" + fileName + "']").kendoAnimate({
        effects: "fadeOut",
        complete: function() {
          var deleted, file, _i, _len, _ref;
          _ref = this.ds._data;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            file = _ref[_i];
            if (file.name === filename) deleted = file;
          }
          return this.ds.remove(deleted);
        }
      });
    };
    return pub = {
      before: function(e) {
        gallery.container.parent().height($(window).height());
        gallery.container.parent().width($(window).width());
        return $.publish("/camera/pause", [true]);
      },
      hide: function(e) {
        return $.publish("/camera/pause", [false]);
      },
      init: function(selector) {
        gallery = new kendo.View(selector);
        gallery.render(viewModel).addClass("gallery");
        gallery.container.on("dblclick", ".thumbnail", function() {
          var media;
          console.log("Double Down!");
          media = $(this).children().first();
          return $.publish("/details/show", [
            {
              src: media.attr("src"),
              type: media.data("media-type"),
              name: media.data("file-name")
            }
          ]);
        });
        gallery.container.on("click", ".thumbnail", function() {
          gallery.find(".thumbnail").removeClass("selected");
          return $(this).addClass("selected");
        });
        filewrapper.list().done(function(f) {
          var file, photos;
          files = f;
          _this.ds = new kendo.data.DataSource({
            data: files,
            pageSize: dim.rows * dim.cols,
            change: function() {
              var i, item, line, row, rows, _i, _len, _results;
              rows = (function() {
                var _ref, _results;
                _results = [];
                for (i = 0, _ref = dim.rows; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
                  _results.push(this.view().slice(i * dim.cols, ((i + 1) * dim.cols)));
                }
                return _results;
              }).call(this);
              _results = [];
              for (_i = 0, _len = rows.length; _i < _len; _i++) {
                row = rows[_i];
                line = new kendo.View(gallery.content);
                line.render().addClass("gallery-row");
                _results.push((function() {
                  var _j, _len2, _results2;
                  _results2 = [];
                  for (_j = 0, _len2 = row.length; _j < _len2; _j++) {
                    item = row[_j];
                    _results2.push((function() {
                      return filewrapper.readFile(item.name).done(function(file) {
                        var thumbnail;
                        thumbnail = new kendo.View(line.content, template, file);
                        return thumbnail.render();
                      });
                    })());
                  }
                  return _results2;
                })());
              }
              return _results;
            },
            sort: {
              dir: "desc",
              field: "name"
            }
          });
          _this.ds.read();
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
              return filewrapper.readFile(photos[photos.length - 1].name).done(function(latestPhoto) {
                return $.publish("/bottom/thumbnail", [latestPhoto.file]);
              });
            }
          }
        });
        $.publish("/postman/deliver", [{}, "/file/read"]);
        return gallery;
      }
    };
  });

}).call(this);
