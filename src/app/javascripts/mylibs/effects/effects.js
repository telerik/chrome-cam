(function() {

  define(['libs/face/ccv', 'libs/face/face'], function(assets) {
    var draw, eyeFactor, faces, ghostBuffer, pox, pub, simple, timeStripsBuffer, webgl;
    faces = [];
    eyeFactor = .05;
    timeStripsBuffer = [];
    ghostBuffer = [];
    webgl = fx.canvas();
    pox = new Image();
    pox.src = "images/pox.png";
    draw = function(canvas, element, effect) {
      var ctx, texture;
      ctx = canvas.getContext("2d");
      texture = webgl.texture(element);
      webgl.draw(texture);
      effect(webgl, element);
      webgl.update();
      texture.destroy();
      return ctx.drawImage(webgl, 0, 0, webgl.width, webgl.height);
    };
    simple = function(canvas, element, x, y, width, height) {
      var ctx;
      ctx = canvas.getContext("2d");
      return ctx.drawImage(element, x, y, width, height);
    };
    return pub = {
      clearBuffer: function() {
        timeStripsBuffer = [];
        return ghostBuffer = [];
      },
      init: function() {
        return pox.src = "images/pox.png";
      },
      data: [
        {
          name: "Normal",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas) {
              return canvas;
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Bulge",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas) {
              return canvas.bulgePinch(canvas.width / 2, canvas.height / 2, (canvas.width / 2) / 2, .65);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Pinch",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.bulgePinch(canvas.width / 2, canvas.height / 2, (canvas.width / 2) / 2, -.65);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Swirl",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.swirl(canvas.width / 2, canvas.height / 2, (canvas.width / 2) / 2, 3);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Dent",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.bulgePinch(canvas.width / 2, canvas.height / 2, canvas.width / 4, -.4);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Zoom Blur",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.zoomBlur(canvas.width / 2, canvas.height / 2, 2, canvas.height / 5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Blockhead",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.blockhead(canvas.width / 2, canvas.height / 2, 200, 300, 1);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Left",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.mirror(0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Bottom",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.mirror(Math.PI * 1.5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Mirror Tube",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.mirrorTube(canvas.width / 2, canvas.height / 2, canvas.height / 4);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Quad",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.quadRotate(0, 0, 0, 0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Sepia",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.sepia(120);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "VHS",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function(canvas, element) {
              return canvas.vhs(frame);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Old Film",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function(canvas, element) {
              return canvas.oldFilm(frame);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Hope",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.hopePoster();
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Ghost",
          filter: function(canvas, element, frame) {
            var effect;
            effect = function(canvas, element) {
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
          name: "Kaleidoscope",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.kaleidoscope(canvas.width / 2, canvas.height / 2, 200, 0);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Inverted",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.invert();
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Comix",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              canvas.quadRotate(0, 0, 0, 0);
              canvas.denoise(50);
              return canvas.ink(.5);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Color Half Tone",
          kind: "webgl",
          filter: function(canvas, element) {
            var effect;
            effect = function(canvas, element) {
              return canvas.colorHalftone(canvas.width / 2, canvas.height / 2, .30, 3);
            };
            return draw(canvas, element, effect);
          }
        }, {
          name: "Frogman",
          filter: function(canvas, element, frame, track) {
            var effect;
            if (track.faces.length !== 0) faces = track.faces;
            effect = function(canvas, element) {
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
          filter: function(canvas, element, frame, stream) {
            var effect;
            if (stream.faces.length !== 0) faces = stream.faces;
            effect = function(canvas, element) {
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
          filter: function(canvas, element, frame, stream) {
            var effect;
            if (stream.faces.length !== 0) faces = stream.faces;
            effect = function(canvas, element) {
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
          name: "Chicken Pox",
          filter: function(canvas, element, frame, stream) {
            var face, factor, height, width, x, y, _i, _len, _results;
            if (stream.faces.length !== 0) faces = stream.faces;
            factor = element.width / stream.trackWidth;
            _results = [];
            for (_i = 0, _len = faces.length; _i < _len; _i++) {
              face = faces[_i];
              width = face.width * factor;
              height = face.height * factor;
              x = face.x * factor;
              y = face.y * factor;
              simple(canvas, element, 0, 0, element.width, element.height);
              _results.push(simple(canvas, pox, x, y, width, height));
            }
            return _results;
          }
        }
      ]
    };
  });

}).call(this);
