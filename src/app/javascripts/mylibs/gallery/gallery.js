(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/thumb.html'], function(kendo, utils, filewrapper, template) {
    var active, add, animation, at, container, create, data, destroy, ds, el, flipping, get, index, page, pageSize, pages, pub, render, select, selected, total,
      _this = this;
    pageSize = 12;
    ds = {};
    data = [];
    container = {};
    el = {};
    selected = {};
    total = 0;
    index = 0;
    flipping = false;
    pages = {
      previous: {},
      next: {}
    };
    active = {};
    animation = {
      effects: "pageturn:horizontal",
      reverse: false,
      duration: 800
    };
    select = function(name) {
      selected = container.find("[name='" + name + "']").parent(":first");
      container.find(".thumbnail").removeClass("selected");
      return selected.addClass("selected");
    };
    page = function(direction) {
      if (!flipping) {
        flipping = true;
        if (direction > 0 && _this.ds.page() > 1) {
          animation.reverse = true;
          _this.ds.page(_this.ds.page() - 1);
        }
        if (direction < 0 && _this.ds.page() < _this.ds.totalPages()) {
          animation.reverse = false;
          _this.ds.page(_this.ds.page() + 1);
        }
        return render(true);
      }
    };
    destroy = function() {
      var name,
        _this = this;
      name = selected.children(":first").attr("name");
      return selected.kendoStop(true).kendoAnimate({
        effects: "zoomOut fadOut",
        hide: true,
        complete: function() {
          return filewrapper.deleteFile(name).done(function() {
            selected.remove();
            _this.ds.remove(_this.ds.get(name));
            return render();
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
      return select(name);
    };
    at = function(index) {
      var match, position, target;
      target = Math.ceil((index + 1) / pageSize);
      if (target !== _this.ds.page()) {
        _this.ds.page(target);
        render();
      }
      position = target > 1 ? index - pageSize : index;
      match = {
        length: _this.ds.data().length,
        index: index,
        item: _this.ds.view()[position]
      };
      $.publish("/details/update", [match]);
      return select(match.item.name);
    };
    add = function(item) {
      item = {
        name: item.name,
        file: item.file,
        type: item.type
      };
      return _this.ds.add(item);
    };
    create = function(item) {
      var element;
      element = {};
      if (item.type === "webm") {
        element = document.createElement("video");
      } else {
        element = new Image();
      }
      element.src = item.file;
      element.name = item.name;
      element.width = 270;
      element.height = 180;
      element.setAttribute("class", "hidden");
      element.onload = function() {
        return $(element).kendoAnimate({
          effects: "fadeIn",
          show: true
        });
      };
      return element;
    };
    render = function(flip) {
      var complete, item, thumbnail, thumbs, _i, _len, _ref;
      thumbs = [];
      _ref = _this.ds.view();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        thumbnail = new kendo.View(pages.next, "<div class='thumbnail'></div>");
        thumbs.push({
          dom: thumbnail.render(),
          data: item
        });
      }
      complete = function() {
        var justPaged;
        setTimeout(function() {
          var item, _j, _len2, _results;
          _results = [];
          for (_j = 0, _len2 = thumbs.length; _j < _len2; _j++) {
            item = thumbs[_j];
            _results.push((function() {
              var element;
              element = create(item.data);
              return item.dom.append(element);
            })());
          }
          return _results;
        }, 50);
        pages.next.show();
        justPaged = pages.previous;
        justPaged.hide();
        justPaged.empty();
        pages.previous = pages.next;
        pages.next = justPaged;
        return flipping = false;
      };
      if (flip) {
        return container.kendoAnimate({
          effects: animation.effects,
          face: animation.reverse ? pages.next : pages.previous,
          back: animation.reverse ? pages.previous : pages.next,
          duration: animation.duration,
          reverse: animation.reverse,
          complete: complete
        });
      } else {
        return complete();
      }
    };
    return pub = {
      before: function(e) {
        $.publish("/postman/deliver", [
          {
            paused: true
          }, "/camera/pause"
        ]);
        return $.subscribe("/keyboard/arrow", function(e) {
          if (!flipping) return page((e === "right") - (e === "left"));
        });
      },
      hide: function(e) {
        $.publish("/postman/deliver", [
          {
            paused: false
          }, "/camera/pause"
        ]);
        $.unsubscribe("/keyboard/arrow");
        pages.next.empty();
        return pages.previous.empty();
      },
      show: function(e) {
        return setTimeout(function() {
          return render();
        }, 420);
      },
      swipe: function(e) {
        return page((e.direction === "right") - (e.direction === "left"));
      },
      init: function(selector) {
        var page1, page2;
        page1 = new kendo.View(selector, null);
        page2 = new kendo.View(selector, null);
        container = page1.container;
        pages.previous = page1.render().addClass("page gallery");
        active = pages.next = page2.render().addClass("page gallery");
        page1.container.on("dblclick", ".thumbnail", function() {
          var thumb;
          thumb = $(this).children(":first");
          return $.publish("/details/show", [get("" + (thumb.attr("name")))]);
        });
        page1.container.on("click", ".thumbnail", function() {
          var thumb;
          thumb = $(this).children(":first");
          $.publish("/top/update", ["selected"]);
          $.publish("/item/selected", [get("" + (thumb.attr("name")))]);
          return select(thumb.attr("name"));
        });
        $.subscribe("/pictures/bulk", function(message) {
          _this.ds = new kendo.data.DataSource({
            data: message.message,
            pageSize: 12,
            change: function() {
              if (this.page() === 1) {
                return $.publish("/bottom/thumbnail", [this.view()[0].file]);
              }
            },
            sort: {
              dir: "desc",
              field: "name"
            },
            schema: {
              model: {
                id: "name"
              }
            }
          });
          return _this.ds.read();
        });
        $.subscribe("/gallery/delete", function() {
          return destroy();
        });
        $.subscribe("/gallery/add", function(item) {
          return add(item);
        });
        $.subscribe("/gallery/at", function(index) {
          return at(index);
        });
        $.publish("/postman/deliver", [{}, "/file/read"]);
        return gallery;
      }
    };
  });

}).call(this);
