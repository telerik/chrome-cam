(function() {

  (function() {
    return self.addEventListener("message", function(e) {
      var blob, frames, i, name, pair, video, _i, _len, _ref;
      frames = e.data;
      importScripts("../libs/record/whammy.min.js");
      video = new Whammy.Video();
      _ref = (function() {
        var _ref, _results;
        _results = [];
        for (i = 0, _ref = frames.length - 2; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
          _results.push(frames.slice(i, (i + 2)));
        }
        return _results;
      })();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        video.add(pair[0].imageData, pair[1].time - pair[0].time);
      }
      blob = video.compile();
      frames = [];
      name = new Date().getTime() + ".webm";
      return worker.postMessage("done!");
    });
  })();

}).call(this);
