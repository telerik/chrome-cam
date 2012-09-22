(function() {

  define(['mylibs/utils/utils'], function(utils) {
    /*   File
    
    The file module takes care of all the reading and writing to and from the file system
    */
    var blobBuiler, clear, compare, destroy, download, errorHandler, fileSystem, getFileExtension, list, myPicturesDir, pub, read, readSingleFile, save, withFileSystem;
    window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;
    fileSystem = null;
    myPicturesDir = {};
    blobBuiler = {};
    compare = function(a, b) {
      if (a.name < b.name) return -1;
      if (a.name > b.name) return 1;
      return 0;
    };
    getFileExtension = function(filename) {
      return filename.split('.').pop();
    };
    errorHandler = function(e) {
      var msg;
      msg = '';
      switch (e.code) {
        case FileError.QUOTA_EXCEEDED_ERR:
          msg = 'QUOTA_EXCEEDED_ERR';
          break;
        case FileError.NOT_FOUND_ERR:
          msg = 'NOT_FOUND_ERR';
          break;
        case FileError.SECURITY_ERR:
          msg = 'SECURITY_ERR';
          break;
        case FileError.INVALID_MODIFICATION_ERR:
          msg = 'INVALID_MODIFICATION_ERR';
          break;
        case FileError.INVALID_STATE_ERR:
          msg = 'INVALID_STATE_ERR';
          break;
        default:
          msg = 'Unknown Error';
      }
      $.publish("/notify/show", ["File Error", msg, true]);
      return $.publish("/notify/show", ["File Access Denied", "Access to the file system could not be obtained.", false]);
    };
    withFileSystem = function(fn) {
      if (fileSystem) {
        return fn(fileSystem);
      } else {
        return window.webkitStorageInfo.requestQuota(PERSISTENT, 5000 * 1024, function(grantedBytes) {
          var success;
          success = function(fs) {
            fileSystem = fs;
            return fn(fs);
          };
          return window.requestFileSystem(PERSISTENT, grantedBytes, success, errorHandler);
        });
      }
    };
    save = function(name, blob) {
      if (typeof blob === "string") blob = utils.toBlob(blob);
      return withFileSystem(function() {
        return fileSystem.root.getFile(name, {
          create: true
        }, function(fileEntry) {
          return fileEntry.createWriter(function(fileWriter) {
            fileWriter.onwrite = function(e) {
              $.publish("/share/gdrive/upload", [blob]);
              return $.publish("/postman/deliver", [{}, "/file/saved/" + name, []]);
            };
            fileWriter.onerror = function(e) {
              return errorHandler(e);
            };
            return fileWriter.write(blob);
          });
        }, errorHandler);
      });
    };
    destroy = function(name) {
      return withFileSystem(function() {
        return fileSystem.root.getFile(name, {
          create: false
        }, function(fileEntry) {
          return fileEntry.remove(function() {
            $.publish("/notify/show", ["File Deleted!", "The picture was deleted successfully", false]);
            return $.publish("/postman/deliver", [
              {
                message: ""
              }, "/file/deleted/" + name, []
            ]);
          }, errorHandler);
        }, errorHandler);
      });
    };
    download = function(name, dataURL) {
      var blob;
      blob = utils.toBlob(dataURL);
      return chrome.fileSystem.chooseFile({
        type: "saveFile"
      }, function(fileEntry) {
        return fileEntry.createWriter(function(fileWriter) {
          fileWriter.onwriteend = function(e) {
            return $.publish("/notify/show", ["File Saved", "The picture was saved succesfully", false]);
          };
          fileWriter.onerror = function(e) {
            return errorHandler(e);
          };
          return fileWriter.write(blob);
        });
      });
    };
    list = function() {
      return withFileSystem(function(fs) {
        var dirReader;
        dirReader = fs.root.createReader();
        return dirReader.readEntries(function(results) {
          var entry, files;
          files = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = results.length; _i < _len; _i++) {
              entry = results[_i];
              if (entry.isFile) {
                _results.push({
                  name: entry.name,
                  type: getFileExtension(entry.name)
                });
              }
            }
            return _results;
          })();
          files.sort(compare);
          return $.publish("/postman/deliver", [
            {
              message: files
            }, "/file/listResult", []
          ]);
        });
      });
    };
    readSingleFile = function(filename) {
      return withFileSystem(function() {
        return fileSystem.root.getFile(filename, null, function(fileEntry) {
          return fileEntry.file(function(file) {
            var reader;
            reader = new FileReader();
            reader.onloadend = function(e) {
              var result;
              result = {
                name: filename,
                type: getFileExtension(filename),
                file: this.result
              };
              return $.publish("/postman/deliver", [
                {
                  message: result
                }, "/pictures/" + filename, []
              ]);
            };
            return reader.readAsDataURL(file);
          });
        });
      });
    };
    read = function() {
      return withFileSystem(function(fs) {
        return fs.root.getDirectory("MyPictures", {
          create: true
        }, function(dirEntry) {
          var dirReader, entries, files;
          myPicturesDir = dirEntry;
          entries = [];
          files = [];
          dirReader = fs.root.createReader();
          read = function() {
            return dirReader.readEntries(function(results) {
              var entry, readFile, _i, _len;
              for (_i = 0, _len = results.length; _i < _len; _i++) {
                entry = results[_i];
                if (entry.isFile) entries.push(entry);
              }
              readFile = function(i) {
                var name, type;
                entry = entries[i];
                if (entry && entry.isFile) {
                  name = entry.name;
                  type = name.split(".").pop();
                  return entry.file(function(file) {
                    var reader;
                    reader = new FileReader();
                    reader.onloadend = function(e) {
                      files.push({
                        name: name,
                        file: this.result,
                        type: type,
                        strip: false
                      });
                      if (files.length === entries.length) {
                        files.sort(compare);
                        return $.publish("/postman/deliver", [
                          {
                            message: files
                          }, "/pictures/bulk", []
                        ]);
                      } else {
                        return readFile(++i);
                      }
                    };
                    return reader.readAsDataURL(file);
                  });
                }
              };
              if (entries.length > 0) {
                return readFile(0);
              } else {
                return $.publish("/postman/deliver", [
                  {
                    message: []
                  }, "/pictures/bulk", []
                ]);
              }
            });
          };
          return read();
        }, errorHandler);
      });
    };
    clear = function() {
      return withFileSystem(function(fs) {
        var dirReader;
        dirReader = fs.root.createReader();
        return dirReader.readEntries(function(entries) {
          var deletedCount, entry, totalCount, _i, _len, _results;
          deletedCount = 0;
          totalCount = entries.length;
          _results = [];
          for (_i = 0, _len = entries.length; _i < _len; _i++) {
            entry = entries[_i];
            _results.push((function(entry) {
              return entry.remove(function() {
                ++deletedCount;
                if (deletedCount === totalCount) {
                  return $.publish("/postman/deliver", [{}, "/file/cleared"]);
                }
              });
            })(entry));
          }
          return _results;
        });
      });
    };
    return pub = {
      init: function(kb) {
        $.subscribe("/file/save", function(message) {
          return save(message.name, message.file);
        });
        $.subscribe("/file/delete", function(message) {
          return destroy(message.name);
        });
        $.subscribe("/file/read", function(message) {
          return read();
        });
        $.subscribe("/file/download", function(message) {
          return download(message.name, message.file);
        });
        $.subscribe("/file/list", function(message) {
          return list();
        });
        $.subscribe("/file/readFile", function(message) {
          return readSingleFile(message.name);
        });
        return $.subscribe("/file/clear", function(message) {
          return clear();
        });
      }
    };
  });

}).call(this);
