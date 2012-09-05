(function() {

  require.config({
    paths: {
      Kendo: 'libs/kendo/kendo',
      Glfx: 'libs/webgl/glfx'
    }
  });

  require(['app', 'order!libs/jquery/plugins', 'order!libs/whammy/whammy'], function(app) {
    return app.init();
  });

}).call(this);
