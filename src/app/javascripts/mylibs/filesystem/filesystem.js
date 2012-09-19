(function() {

  define(['mylibs/utils/utils'], function(utils) {
    var FILE_SYSTEM_SIZE, KIBIBYTE, MEBIBYTE, createTestFile, pub;
    KIBIBYTE = 1024;
    MEBIBYTE = KIBIBYTE * 1024;
    FILE_SYSTEM_SIZE = 5 * MEBIBYTE;
    createTestFile = function(fileName) {
      var file;
      return file = {
        fileName: fileName,
        thumbnailUrl: fileName,
        size: 128 * 1024,
        dateTaken: new Date()
      };
    };
    utils.getFileSystem(window.PERSISTENT, FILE_SYSTEM_SIZE, function(fileSystem) {
      console.log(fileSystem);
      return $.publish("/filesystem/ready");
    }, function(fileError) {
      console.log(fileError);
      return $.publish("/filesystem/error");
    });
    return pub = {
      init: function() {
        var data, i;
        data = (function() {
          var _results;
          _results = [];
          for (i = 1; i <= 20; i++) {
            _results.push(createTestFile(i));
          }
          return _results;
        })();
        return this.dataSource = new kendo.data.DataSource({
          data: data,
          pageSize: 12
        });
      }
    };
  });

}).call(this);
