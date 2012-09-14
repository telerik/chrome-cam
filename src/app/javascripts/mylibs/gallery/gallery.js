(function() {

  define(['Kendo', 'mylibs/utils/utils', 'mylibs/file/filewrapper', 'text!mylibs/gallery/views/row.html'], function(kendo, utils, filewrapper, template) {
    var animation, container, destroy, dim, ds, el, files, get, index, page, pub, selected, total,
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
            return selected.remove();
          });
        }
      });
    };
    get = function(name) {
      return _this.ds.get(name);
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
        var f, nextPage, page1, page2, previousPage;
        page1 = new kendo.View(selector, null);
        page2 = new kendo.View(selector, null);
        container = page1.container;
        previousPage = page1.render().addClass("page gallery");
        nextPage = page2.render().addClass("page gallery");
        page1.container.on("dblclick", ".thumbnail", function() {
          var data, media;
          media = $(this).children().first();
          index = get("" + (media.data("file-name")));
          data = {
            src: media.attr("src"),
            type: media.data("media-type"),
            name: media.data("file-name"),
            length: files.length,
            index: index
          };
          return $.publish("/details/show", [data]);
        });
        page1.container.on("click", ".thumbnail", function() {
          $.publish("/top/update", ["selected"]);
          page1.find(".thumbnail").removeClass("selected");
          return selected = $(this).addClass("selected");
        });
        f = [
          {
            name: "123456",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "1",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "2",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "3",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "4",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "5",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "6",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "7",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "8",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "9",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "10",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "11",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "12",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }, {
            name: "13",
            file: "http://mantle.me/me.jpeg",
            type: "jpeg"
          }
        ];
        (function() {
          files = f;
          total = files.length;
          _this.ds = new kendo.data.DataSource({
            data: files,
            pageSize: dim.rows * dim.cols,
            change: function() {
              var i, item, line, row, rows, thumbnail, _i, _j, _len, _len2;
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
                for (_j = 0, _len2 = row.length; _j < _len2; _j++) {
                  item = row[_j];
                  thumbnail = new kendo.View(line.content, template, item);
                  thumbnail.render();
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
        })();
        $.publish("/postman/deliver", [{}, "/file/read"]);
        $.subscribe("/gallery/delete", function() {
          return destroy();
        });
        return gallery;
      }
    };
  });

}).call(this);
