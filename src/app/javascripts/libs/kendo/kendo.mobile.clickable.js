(function ($) {
	
	var ui = kendo.mobile.ui,
		Button = ui.Button,
		Widget = ui.Widget,
		support = kendo.support,
        os = support.mobileOS,
        ANDROID3UP = os.android && os.flatVersion >= 300;

	var Clickable = Button.extend({

		init: function (element, options) {

			var that = this;

            Widget.fn.init.call(that, element, options);

            that.element
                .on("up", "_release")
                .on("down", "_activate")
                .on("up cancel", "_deactivate")
                .on("mouseover", "_mouseover")
                .on("mouseout", "_mouseout")

            if (ANDROID3UP) {
                that.element.on("move", "_timeoutDeactivate");
            }
		},

		options: {
			name: "Clickable"
		},

		_mouseover: function (e) {
			this.trigger("mouseover", { target: e.target });
		},

		_mouseout: function (e) {
			this.trigger("mouseout", { target: e.target });
		}
	});

	// add this new widget to the UI namespace.
	ui.plugin(Clickable);

}(jQuery));