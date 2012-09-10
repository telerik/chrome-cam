(function() {
  var __hasProp = Object.prototype.hasOwnProperty;

  define(['Kendo'], function(kendo) {
    var pub;
    return pub = {
      init: function(el) {
        var key, value, _fn;
        _fn = function(value) {
          if (value["in"]) {
            value.show = function() {
              return value.kendoStop(true).kendoAnimate({
                effects: value["in"].effects,
                show: true,
                duration: 200,
                complete: value.complete || null
              });
            };
          }
          if (value.out) {
            return value.hide = function() {
              return value.kendoStop(true).kendoAnimate({
                effects: value.out.effects,
                hide: true,
                duration: 200,
                complete: value.complete || null
              });
            };
          }
        };
        for (key in el) {
          if (!__hasProp.call(el, key)) continue;
          value = el[key];
          _fn(value);
        }
        return {
          full: function() {
            el.content.removeClass("recording");
            el.share.hide();
            el["delete"].hide();
            el.back.hide();
            el.thumbnail.hide();
            el.mode.show();
            el.capture.show();
            return el.filters.show();
          },
          preview: function() {
            el.content.removeClass("recording");
            el.share.hide();
            el["delete"].hide();
            el.back.hide();
            el.thumbnail.show();
            el.mode.hide();
            el.capture.hide();
            return el.filters.hide();
          },
          capture: function() {
            el.mode.hide();
            el.capture.hide();
            return el.filters.hide();
          },
          recording: function() {
            el.content.addClass("recording");
            el.capture.hide();
            el.mode.hide();
            return el.filters.hide();
          },
          gallery: function() {
            el.mode.hide();
            el.capture.hide();
            el.thumbnail.hide();
            el.filters.hide;
            el.share.show();
            el["delete"].show();
            return el.back.show();
          },
          previous: "preview",
          current: "preview",
          set: function(sender) {
            this.previous = this.current;
            this.current = sender;
            return this[sender]();
          }
        };
      }
    };
  });

}).call(this);
