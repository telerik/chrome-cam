(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/row.html'], function(kendo, utils, filewrapper, template) {
    var add, animation, at, container, destroy, dim, ds, el, files, get, index, page, pub, selected, total,
      _this = this;
    dim = {
      cols: 4,
      rows: 3
    };
    ds = {};
    files = [];
    container = {};
    el = {};
    selected = {};
    total = 0;
    index = 0;
    animation = {
      effects: "pageturn:horizontal",
      reverse: false,
      duration: 800
    };
    page = function(direction) {
      if (direction > 0 && _this.ds.page() > 1) {
        animation.reverse = true;
        _this.ds.page(_this.ds.page() - 1);
      }
      if (direction < 0 && _this.ds.page() < _this.ds.totalPages()) {
        animation.reverse = false;
        return _this.ds.page(_this.ds.page() + 1);
      }
    };
    destroy = function() {
      var name;
      name = selected.find("img").data("file-name");
      return selected.kendoStop(true).kendoAnimate({
        effects: "zoomOut fadOut",
        hide: true,
        complete: function() {
          return filewrapper.deleteFile(name).done(function() {
            selected.remove();
            return this.ds.remove(this.ds.get(name));
          });
        }
      });
    };
    get = function(name) {
      var match;
      match = _this.ds.get(name);
      return {
        length: _this.ds.view().length,
        index: _this.ds.view().indexOf(match),
        item: match
      };
    };
    at = function(index) {
      var match;
      match = {
        length: _this.ds.view().length,
        index: index,
        item: _this.ds.view()[index]
      };
      return $.publish("/details/update", [match]);
    };
    add = function(item) {
      return _this.ds.add({
        name: item.name,
        file: item.file,
        type: item.type
      });
    };
    return pub = {
      before: function(e) {
        container.parent().height($(window).height() - 50);
        container.parent().width($(window).width());
        return $.publish("/camera/pause", [true]);
      },
      hide: function(e) {
        return $.publish("/camera/pause", [false]);
      },
      swipe: function(e) {
        return page((e.direction === "right") - (e.direction === "left"));
      },
      init: function(selector) {
        var nextPage, page1, page2, previousPage;
        page1 = new kendo.View(selector, null);
        page2 = new kendo.View(selector, null);
        container = page1.container;
        previousPage = page1.render().addClass("page gallery");
        nextPage = page2.render().addClass("page gallery");
        page1.container.on("dblclick", ".thumbnail", function() {
          var media;
          media = $(this).children().first();
          return $.publish("/details/show", [get("" + (media.data("file-name")))]);
        });
        page1.container.on("click", ".thumbnail", function() {
          $.publish("/top/update", ["selected"]);
          page1.find(".thumbnail").removeClass("selected");
          return selected = $(this).addClass("selected");
        });
        filewrapper.list().done(function(f) {
          files = f;
          total = files.length;
          _this.ds = new kendo.data.DataSource({
            data: files,
            pageSize: dim.rows * dim.cols,
            change: function() {
              var i, item, line, row, rows, _fn, _i, _j, _len, _len2,
                _this = this;
              rows = (function() {
                var _ref, _results;
                _results = [];
                for (i = 0, _ref = dim.rows; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
                  _results.push(this.view().slice(i * dim.cols, ((i + 1) * dim.cols)));
                }
                return _results;
              }).call(this);
              for (_i = 0, _len = rows.length; _i < _len; _i++) {
                row = rows[_i];
                line = new kendo.View(nextPage);
                line.render().addClass("gallery-row");
                _fn = function() {
                  return filewrapper.readFile(item.name).done(function(file) {
                    var thumbnail;
                    _this.get(file.name).file = file.file;
                    thumbnail = new kendo.View(line.content, template, file);
                    return thumbnail.render();
                  });
                };
                for (_j = 0, _len2 = row.length; _j < _len2; _j++) {
                  item = row[_j];
                  _fn();
                }
              }
              return container.kendoAnimate({
                effects: animation.effects,
                face: animation.reverse ? nextPage : previousPage,
                back: animation.reverse ? previousPage : nextPage,
                duration: animation.duration,
                reverse: animation.reverse,
                complete: function() {
                  var flipping, justPaged;
                  justPaged = previousPage;
                  previousPage = nextPage;
                  nextPage = justPaged;
                  justPaged.empty();
                  return flipping = false;
                }
              });
            },
            schema: {
              model: {
                id: "name"
              }
            },
            sort: {
              dir: "desc",
              field: "name"
            }
          });
          return _this.ds.read();
        });
        $.publish("/postman/deliver", [{}, "/file/read"]);
        $.subscribe("/gallery/delete", function() {
          return destroy();
        });
        $.subscribe("/gallery/add", function(item) {
          return add(item);
        });
        $.subscribe("/gallery/at", function(index) {
          return at(index);
        });
        return gallery;
      }
    };
  });

}).call(this);
