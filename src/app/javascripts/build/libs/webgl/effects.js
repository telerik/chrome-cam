(function() {

  define(['libs/face/ccv', 'libs/face/face'], function(assets) {
    var draw, eyeFactor, faces, ghostBuffer, pub, timeStripsBuffer;
    faces = [];
    eyeFactor = .05;
    timeStripsBuffer = [];
    ghostBuffer = [];
    draw = function(canvas, element, effect) {
      var texture;
      texture = canvas.texture(element);
      canvas.draw(texture);
      effect(element);
      canvas.update();
      return texture.destroy();
    };
    return pub = {
      clearBuffer: function() {
        timeStripsBuffer = [];
        return ghostBuffer = [];
      },
      init: function() {},
      data: [
        {
          name: "Normal",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas;
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Bulge",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.bulgePinch(canvas.width / 2, canvas.height / 2, (canvas.width / 2) / 2, .65);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Frogman",
          kind: "webgl",
          filter: function(canvas, element, frame, track) {
            var effect;
            if (track.faces.length !== 0) faces = track.faces;
            effect = function(element) {
              var eyeWidth, face, factor, height, width, x, y, _i, _len, _results;
              factor = element.width / track.trackWidth;
              _results = [];
              for (_i = 0, _len = faces.length; _i < _len; _i++) {
                face = faces[_i];
                width = face.width * factor;
                height = face.height * factor;
                x = face.x * factor;
                y = face.y * factor;
                eyeWidth = eyeFactor * element.width;
                canvas.bulgePinch((x + width / 2) - eyeWidth, y + height / 3, eyeWidth * 2, .65);
                _results.push(canvas.bulgePinch((x + width / 2) + eyeWidth, y + height / 3, eyeWidth * 2, .65));
              }
              return _results;
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Chubby Bunny",
          kind: "webgl",
          filter: function(canvas, element, frame, stream) {
            var effect;
            if (stream.faces.length !== 0) faces = stream.faces;
            effect = function(element) {
              var eyeWidth, face, factor, height, width, x, y, _i, _len, _results;
              factor = element.width / stream.trackWidth;
              _results = [];
              for (_i = 0, _len = faces.length; _i < _len; _i++) {
                face = faces[_i];
                width = face.width * factor;
                height = face.height * factor;
                x = face.x * factor;
                y = face.y * factor;
                eyeWidth = eyeFactor * element.width;
                canvas.bulgePinch((x + width / 2) - eyeWidth, (y + height / 3) + eyeWidth, eyeWidth * 2, .65);
                _results.push(canvas.bulgePinch((x + width / 2) + eyeWidth, (y + height / 3) + eyeWidth, eyeWidth * 2, .65));
              }
              return _results;
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Giraffe",
          kind: "webgl",
          filter: function(canvas, element, frame, stream) {
            var effect;
            if (stream.faces.length !== 0) faces = stream.faces;
            effect = function(element) {
              var face, factor, height, width, x, y, _i, _len;
              factor = element.width / stream.trackWidth;
              for (_i = 0, _len = faces.length; _i < _len; _i++) {
                face = faces[_i];
                width = face.width * factor;
                height = face.height * factor;
                x = face.x * factor;
                y = face.y * factor;
              }
              return canvas.blockhead(x, y + height + 25, 1, canvas.height / 2, 1);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Pinch",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.bulgePinch(canvas.width / 2, canvas.height / 2, (canvas.width / 2) / 2, -.65);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Swirl",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.swirl(canvas.width / 2, canvas.height / 2, (canvas.width / 2) / 2, 3);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Zoom Blur",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.zoomBlur(canvas.width / 2, canvas.height / 2, 2, canvas.height / 5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Blockhead",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.blockhead(canvas.width / 2, canvas.height / 2, 200, 300, 1);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Left",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.mirror(0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Pinch (Evil)",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              canvas.bulgePinch(canvas.width / 2, canvas.height / 2, (canvas.width / 2) / 2, -.65);
              return canvas.mirror(0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Top",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.mirror(Math.PI * .5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Bottom",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.mirror(Math.PI * 1.5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Tube",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.mirrorTube(canvas.width / 2, canvas.height / 2, canvas.height / 4);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Quad",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.quadRotate(0, 0, 0, 0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Quad Color",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.quadColor([1, .2, .1], [0, .8, 0], [.25, .5, 1], [.8, .8, .8]);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Comix",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              canvas.quadRotate(0, 0, 0, 0);
              canvas.denoise(50);
              return canvas.ink(.5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "I Dont' Know",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              canvas.quadRotate(0, 1, 3, 2);
              return canvas.quadRotate(2, 3, 1, 0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Sketch Book",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              canvas.edgeWork(2);
              return canvas.sepia();
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Color Half Tone",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.colorHalftone(canvas.width / 2, canvas.height / 2, .30, 3);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Pixelate",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.pixelate(canvas.width / 2, canvas.height / 2, 10);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Hope Poster",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.hopePoster();
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Photocopy",
          kind: "webgl",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function() {
              return canvas.photocopy(.5, frame);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Old Film",
          kind: "webgl",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function() {
              return canvas.oldFilm(frame);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "VHS",
          kind: "webgl",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function() {
              return canvas.vhs(frame);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Time Strips",
          kind: "webgl",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function() {
              var createBuffers;
              createBuffers = function(length) {
                var _results;
                _results = [];
                while (timeStripsBuffer.length < length) {
                  _results.push(timeStripsBuffer.push(canvas.texture(element)));
                }
                return _results;
              };
              createBuffers(32);
              timeStripsBuffer[frame++ % timeStripsBuffer.length].loadContentsOf(element);
              canvas.timeStrips(timeStripsBuffer, frame);
              return canvas.matrixWarp([-1, 0, 0, 1], false, true);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Your Ghost",
          kind: "webgl",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function() {
              var createBuffers;
              createBuffers = function(length) {
                var _results;
                _results = [];
                while (ghostBuffer.length < length) {
                  _results.push(ghostBuffer.push(canvas.texture(element)));
                }
                return _results;
              };
              createBuffers(32);
              ghostBuffer[frame++ % ghostBuffer.length].loadContentsOf(element);
              canvas.matrixWarp([1, 0, 0, 1], false, true);
              canvas.blend(ghostBuffer[frame % ghostBuffer.length], .5);
              return canvas.matrixWarp([-1, 0, 0, 1], false, true);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Chromed",
          kind: "webgl",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function() {
              return canvas.chromeLogo(canvas.width / 2, canvas.height / 2, frame, canvas.height / 2.5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Kaleidoscope",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.kaleidoscope(canvas.width / 2, canvas.height / 2, 200, 0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Inverted",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function() {
              return canvas.invert();
            };
            return draw(canvas, element, effect);
          }
        }
      ]
    };
  });

}).call(this);
