(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/row.html'], function(kendo, utils, filewrapper, template) {
    var add, animation, at, container, destroy, dim, ds, el, files, get, index, page, pageSize, pub, selected, total,
      _this = this;
    pageSize = 8;
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
      name = selected.children(":first").data("file-name");
      return selected.kendoStop(true).kendoAnimate({
        effects: "zoomOut fadOut",
        hide: true,
        complete: function() {
          var _this = this;
          return filewrapper.deleteFile(name).done(function() {
            selected.remove();
            return _this.ds.remove(_this.ds.get(name));
          });
        }
      });
    };
    get = function(name) {
      var match, position;
      match = _this.ds.get(name);
      index = _this.ds.view().indexOf(match);
      position = _this.ds.page() > 1 ? pageSize * (_this.ds.page() - 1) + index : index;
      return {
        length: _this.ds.data().length,
        index: position,
        item: match
      };
    };
    at = function(index) {
      var match, position, target;
      target = Math.ceil((index + 1) / pageSize);
      if (target !== _this.ds.page()) _this.ds.page(target);
      position = target > 1 ? index - pageSize : index;
      match = {
        length: _this.ds.data().length,
        index: index,
        item: _this.ds.view()[position]
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
        return $.publish("/postman/deliver", [
          {
            paused: true
          }, "/camera/pause"
        ]);
      },
      hide: function(e) {
        return $.publish("/postman/deliver", [
          {
            paused: false
          }, "/camera/pause"
        ]);
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
          var thumb;
          thumb = $(this).children(":first");
          return $.publish("/details/show", [get("" + (thumb.data("file-name")))]);
        });
        page1.container.on("click", ".thumbnail", function() {
          var thumb;
          thumb = $(this).children(":first");
          $.publish("/top/update", ["selected"]);
          page1.find(".thumbnail").removeClass("selected");
          selected = $(this).addClass("selected");
          return $.publish("/item/selected", [get("" + (thumb.data("file-name")))]);
        });
        filewrapper.list().done(function(f) {
          files = f;
          total = files.length;
          _this.ds = new kendo.data.DataSource({
            data: files,
            pageSize: 8,
            change: function() {
              var item, _fn, _i, _len, _ref,
                _this = this;
              _ref = this.view();
              _fn = function() {
                return filewrapper.readFile(item.name).done(function(file) {
                  var model, thumbnail;
                  model = _this.get(file.name);
                  if (_this.page() === 1 && _this.view().indexOf(model) === 0) {
                    $.publish("/thumbnail/update", file.file);
                  }
                  model.file = file.file;
                  thumbnail = new kendo.View(nextPage, template, file);
                  return thumbnail.render();
                });
              };
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                item = _ref[_i];
                _fn();
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
