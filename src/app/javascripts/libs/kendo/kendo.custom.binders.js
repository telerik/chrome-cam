(function() {

  kendo.data.binders.zoom = kendo.data.Binder.extend({
    refresh: function() {
      var value, visible;
      value = this.bindings["zoom"].get();
      visible = $(this.element).is(":visible");
      console.log(value);
      console.log(visible);
      if (value) {
        if (!visible) {
          $(this.element).kendoStop(true).kendoAnimate({
            effects: "zoomIn fadeIn",
            show: true
          });
        }
      }
      if (!value && visible) {
        return $(this.element).kendoStop(true).kendoAnimate({
          effects: "zoomOut fadeOut",
          show: true
        });
      }
    }
  });

  kendo.data.binders.slideUpDown = kendo.data.Binder.extend({
    refresh: function() {
      var value;
      value = this.bindings["slideUpDown"].get();
      if (value) {
        return $(this.element).kendoStop(true).kendoAnimate({
          effects: "slideIn:up",
          show: true
        });
      } else {
        return $(this.element).kendoStop(true).kendoAnimate({
          effects: "slide:down",
          show: true
        });
      }
    }
  });

}).call(this);
