// Generated by CoffeeScript 1.4.0
(function() {

  define(['mylibs/utils/utils'], function(utils) {
    var keydown, pub, removeTabs, restoreTabs;
    keydown = function(e) {
      var target;
      if (!(e.which === utils.keys.space || e.which === utils.keys.enter)) {
        return;
      }
      target = $(e.target);
      if (target.data("role") === "button") {
        return target.data("kendoMobileButton").trigger("click");
      } else if (target.data("role") === "clickable") {
        return target.data("kendoMobileClickable").trigger("click");
      }
    };
    removeTabs = function(parent) {
      return $("[tabindex]", parent).each(function() {
        var tabbable;
        tabbable = $(this);
        tabbable.attr("data-old-tabindex", tabbable.attr("tabindex"));
        return tabbable.attr("tabindex", -1);
      });
    };
    restoreTabs = function(parent) {
      return $("[data-old-tabindex]", parent).each(function() {
        var tabbable;
        tabbable = $(this);
        tabbable.attr("tabindex", tabbable.attr("data-old-tabindex"));
        return tabbable.removeAttr("data-old-tabindex");
      });
    };
    return pub = {
      init: function() {
        $(document.body).on("keydown", "[data-tabbable]", keydown);
        $.subscribe("/tabbing/remove", removeTabs);
        return $.subscribe("/tabbing/restore", restoreTabs);
      }
    };
  });

}).call(this);
