(function() {
  var ByRate, DieOnSurface, Emission, Explosion, Fixed, Force, Friction, Instant, Life, Limited, LinearSpline, Live, MacroAction, MacroInitializer, Move, NoRandom, Particle, ParticleSubSystem, Path, Point, Ponctual, Random, Rectangle, SIGNALS, SubSystem, Surface, System, UntilDeath, agt, construct, equalEnough, floor, i, j, mockListener, pt, round, testPropertyLength, testSplineLength, testSplineMethod, testSplineProperty, time, v, v2, _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (typeof module === 'undefined') {
    window.global = window;
    agt = global.agt;
  } else {
    global.agt = agt = require('../../../lib/agt');
  }

  global.DEFAULT_SEGMENTS = 36;

  global.DEG_TO_RAD = Math.PI / 180;

  global.BUILDS = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 0; _i <= 24; i = ++_i) {
      _results.push(new Function("return new arguments[0](" + (((function() {
        var _j, _results1;
        _results1 = [];
        for (j = _j = 0; 0 <= i ? _j <= i : _j >= i; j = 0 <= i ? ++_j : --_j) {
          if (j !== 0) {
            _results1.push("arguments[1][" + (j - 1) + "]");
          }
        }
        return _results1;
      })()).join(",")) + ");"));
    }
    return _results;
  })();

  global.first = function(a) {
    return a[0];
  };

  global.last = function(a) {
    return a[a.length - 1];
  };

  global.merge = function(a, b) {
    var k, v, _results;
    _results = [];
    for (k in b) {
      v = b[k];
      _results.push(a[k] = v);
    }
    return _results;
  };

  global.eachPair = function(o, block) {
    var k, v, _results;
    _results = [];
    for (k in o) {
      v = o[k];
      _results.push(typeof block === "function" ? block(k, v) : void 0);
    }
    return _results;
  };

  global.step = function(a, s, b) {
    var l, r, _i;
    r = [];
    l = a.length / s;
    for (i = _i = 0; 0 <= l ? _i < l : _i > l; i = 0 <= l ? ++_i : --_i) {
      r.push(a.slice(i * s, +(i * s + s - 1) + 1 || 9e9));
    }
    return r.forEach(function(a) {
      if (a.length) {
        return b(a);
      }
    });
  };

  global.withLoop = function(times, block) {
    var n, _i, _ref, _results;
    if (times == null) {
      times = 20;
    }
    if (typeof times === 'function') {
      _ref = [20, times], times = _ref[0], block = _ref[1];
    }
    _results = [];
    for (n = _i = 0; 0 <= times ? _i <= times : _i >= times; n = 0 <= times ? ++_i : --_i) {
      _results.push(block.call(this, n));
    }
    return _results;
  };

  agt.Impulse.prototype.start = function() {
    return this.running = true;
  };

  time = 0;

  global.animate = function(t) {
    return agt.Impulse.instance().dispatch(t, t / 1000, time += t);
  };

  global.testProperty = function(source, property) {
    return {
      shouldBe: function(value) {
        return describe("" + source + " " + property + " property", function() {
          beforeEach(function() {
            return jasmine.addMatchers({
              toBeClose: function() {
                return {
                  compare: function(actual, value) {
                    var result;
                    result = {};
                    result.message = "Expected " + actual + " to be equal to " + value + " with a precision of 1e-10";
                    result.pass = Math.deltaBelowRatio(actual, value);
                    return result;
                  }
                };
              }
            });
          });
          return it("should be " + value, function() {
            return expect(this[source][property]).toBeClose(value);
          });
        });
      }
    };
  };

  global.addCircleMatchers = function(scope) {
    return jasmine.addMatchers({
      toBeCircle: function() {
        return {
          compare: function(actual, radius, x, y, segments) {
            var result;
            result = {};
            result.message = "Expected " + actual + " to be a circle with radius=" + radius + ", x=" + x + ", y=" + y + ", segments=" + segments;
            result.pass = actual.radius === radius && actual.x === x && actual.y === y && actual.segments === segments;
            return result;
          }
        };
      }
    });
  };

  global.circle = function(radius, x, y, segments) {
    return new agt.geom.Circle(radius, x, y, segments);
  };

  global.circleData = function(radius, x, y, segments) {
    var data;
    data = {
      radius: radius,
      x: x,
      y: y,
      segments: segments
    };
    merge(data, {
      acreage: Math.PI * radius * radius,
      length: 2 * Math.PI * radius,
      top: y - radius,
      bottom: y + radius,
      left: x - radius,
      right: x + radius
    });
    merge(data, {
      bounds: {
        top: data.top,
        bottom: data.bottom,
        left: data.left,
        right: data.right
      }
    });
    return data;
  };

  global.circleFactories = {
    'three numbers': {
      args: [1, 1, 1],
      test: [1, 1, 1, DEFAULT_SEGMENTS]
    },
    'with four numbers': {
      args: [2, 3, 4, 60],
      test: [2, 3, 4, 60]
    },
    'without arguments': {
      args: [],
      test: [1, 0, 0, DEFAULT_SEGMENTS]
    },
    'with a circle without segments': {
      args: [
        {
          x: 1,
          y: 1,
          radius: 1
        }
      ],
      test: [1, 1, 1, DEFAULT_SEGMENTS]
    },
    'with a circle with segments': {
      args: [
        {
          x: 1,
          y: 1,
          radius: 1,
          segments: 60
        }
      ],
      test: [1, 1, 1, 60]
    },
    'with partial circle': {
      args: [
        {
          x: 1
        }
      ],
      test: [1, 1, 0, 36]
    }
  };

  global.addDiamondMatchers = function(scope) {
    return jasmine.addMatchers({
      toBeDiamond: function() {
        return {
          compare: function(actual, topLength, rightLength, bottomLength, leftLength, x, y, rotation) {
            var result;
            result = {};
            result.message = "Expected " + actual + " to be a diamond with leftLength=" + leftLength + ", rightLength=" + rightLength + ", topLength=" + topLength + ", bottomLength=" + bottomLength + ", x=" + x + ", y=" + y + ", rotation=" + rotation;
            result.pass = actual.leftLength === leftLength && actual.topLength === topLength && actual.rightLength === rightLength && actual.bottomLength === bottomLength && actual.x === x && actual.y === y && actual.rotation === rotation;
            return result;
          }
        };
      }
    });
  };

  global.diamond = function(topLength, rightLength, bottomLength, leftLength, x, y, rotation) {
    return new agt.geom.Diamond(topLength, rightLength, bottomLength, leftLength, x, y, rotation);
  };

  global.diamondData = function(topLength, rightLength, bottomLength, leftLength, x, y, rotation) {
    var bottomVec, center, data, leftVec, rightVec, topVec;
    center = point(x, y);
    topVec = point(0, -topLength).rotate(rotation);
    bottomVec = point(0, bottomLength).rotate(rotation);
    leftVec = point(-leftLength, 0).rotate(rotation);
    rightVec = point(rightLength, 0).rotate(rotation);
    data = {
      topLength: topLength,
      rightLength: rightLength,
      bottomLength: bottomLength,
      leftLength: leftLength,
      x: x,
      y: y,
      rotation: rotation
    };
    merge(data, {
      center: center,
      topCorner: center.add(topVec),
      bottomCorner: center.add(bottomVec),
      leftCorner: center.add(leftVec),
      rightCorner: center.add(rightVec)
    });
    merge(data, {
      topLeftEdge: data.topCorner.subtract(data.leftCorner),
      topRightEdge: data.rightCorner.subtract(data.topCorner),
      bottomRightEdge: data.bottomCorner.subtract(data.rightCorner),
      bottomLeftEdge: data.leftCorner.subtract(data.bottomCorner)
    });
    merge(data, {
      topLeftQuadrant: triangle(data.center, data.topCorner, data.leftCorner),
      topRightQuadrant: triangle(data.center, data.topCorner, data.rightCorner),
      bottomLeftQuadrant: triangle(data.center, data.bottomCorner, data.leftCorner),
      bottomRightQuadrant: triangle(data.center, data.bottomCorner, data.rightCorner)
    });
    merge(data, {
      length: data.topLeftEdge.length() + data.topRightEdge.length() + data.bottomLeftEdge.length() + data.bottomRightEdge.length(),
      acreage: data.topLeftQuadrant.acreage() + data.topRightQuadrant.acreage() + data.bottomLeftQuadrant.acreage() + data.bottomRightQuadrant.acreage(),
      top: Math.min(data.topCorner.y, data.leftCorner.y, data.rightCorner.y, data.bottomCorner.y),
      bottom: Math.max(data.topCorner.y, data.leftCorner.y, data.rightCorner.y, data.bottomCorner.y),
      left: Math.min(data.topCorner.x, data.leftCorner.x, data.rightCorner.x, data.bottomCorner.x),
      right: Math.max(data.topCorner.x, data.leftCorner.x, data.rightCorner.x, data.bottomCorner.x)
    });
    merge(data, {
      bounds: {
        top: data.top,
        bottom: data.bottom,
        left: data.left,
        right: data.right
      }
    });
    return data;
  };

  global.diamondFactories = {
    'with all properties': {
      args: [1, 2, 3, 4, 5, 6, 7],
      test: [1, 2, 3, 4, 5, 6, 7]
    },
    'without rotation': {
      args: [1, 2, 3, 4, 5, 6],
      test: [1, 2, 3, 4, 5, 6, 0]
    },
    'without neither position nor rotation': {
      args: [1, 2, 3, 4],
      test: [1, 2, 3, 4, 0, 0, 0]
    },
    'with an object with all properties': {
      args: [
        {
          topLength: 1,
          rightLength: 2,
          bottomLength: 3,
          leftLength: 4,
          x: 5,
          y: 6,
          rotation: 7
        }
      ],
      test: [1, 2, 3, 4, 5, 6, 7]
    },
    'with a partial object': {
      args: [
        {
          topLength: 1,
          rightLength: 2,
          x: 5
        }
      ],
      test: [1, 2, 1, 1, 5, 0, 0]
    }
  };

  global.addEllipsisMatchers = function(scope) {
    return jasmine.addMatchers({
      toBeEllipsis: function() {
        return {
          compare: function(actual, r1, r2, x, y, rotation, segments) {
            var result;
            result = {};
            result.message = "Expected " + actual + " to be an ellipsis with radius1=" + r1 + ", radius2=" + r2 + ", x=" + x + ", y=" + y + ", rotation=" + rotation + ", segments=" + segments;
            result.pass = actual.radius1 === r1 && actual.radius2 === r2 && actual.x === x && actual.y === y && actual.rotation === rotation && actual.segments === segments;
            return result;
          }
        };
      }
    });
  };

  global.ellipsis = function(r1, r2, x, y, rotation, segments) {
    return new agt.geom.Ellipsis(r1, r2, x, y, rotation, segments);
  };

  global.ellipsisData = function(radius1, radius2, x, y, rotation, segments) {
    var a, b, data, phi, t1, t2, x1, x2, y1, y2;
    data = {
      radius1: radius1,
      radius2: radius2,
      x: x,
      y: y,
      rotation: rotation,
      segments: segments
    };
    merge(data, {
      acreage: Math.PI * radius1 * radius2,
      length: Math.PI * (3 * (radius1 + radius2) - Math.sqrt((3 * radius1 + radius2) * (radius1 + radius2 * 3)))
    });
    a = radius1;
    b = radius2;
    phi = rotation;
    t1 = Math.atan(-b * Math.tan(phi) / a);
    t2 = Math.atan(b * (Math.cos(phi) / Math.sin(phi)) / a);
    x1 = x + a * Math.cos(t1 + Math.PI) * Math.cos(phi) - b * Math.sin(t1 + Math.PI) * Math.sin(phi);
    x2 = x + a * Math.cos(t1) * Math.cos(phi) - b * Math.sin(t1) * Math.sin(phi);
    y1 = y + a * Math.cos(t2) * Math.sin(phi) + b * Math.sin(t2) * Math.cos(phi);
    y2 = y + a * Math.cos(t2 + Math.PI) * Math.sin(phi) + b * Math.sin(t2 + Math.PI) * Math.cos(phi);
    merge(data, {
      left: Math.min(x1, x2),
      right: Math.max(x1, x2),
      top: Math.min(y1, y2),
      bottom: Math.max(y1, y2)
    });
    merge(data, {
      bounds: {
        top: data.top,
        bottom: data.bottom,
        left: data.left,
        right: data.right
      }
    });
    return data;
  };

  global.ellipsisFactories = {
    'with four numbers': {
      args: [1, 2, 3, 4],
      test: [1, 2, 3, 4, 0, DEFAULT_SEGMENTS]
    },
    'with five numbers': {
      args: [1, 2, 3, 4, 5],
      test: [1, 2, 3, 4, 5, DEFAULT_SEGMENTS]
    },
    'with six numbers': {
      args: [1, 2, 3, 4, 5, 60],
      test: [1, 2, 3, 4, 5, 60]
    },
    'without arguments': {
      args: [],
      test: [1, 1, 0, 0, 0, DEFAULT_SEGMENTS]
    },
    'with an ellipsis without rotation or segments': {
      args: [
        {
          radius1: 1,
          radius2: 2,
          x: 3,
          y: 4
        }
      ],
      test: [1, 2, 3, 4, 0, DEFAULT_SEGMENTS]
    },
    'with an ellipsis without segments': {
      args: [
        {
          radius1: 1,
          radius2: 2,
          x: 3,
          y: 4,
          rotation: 120
        }
      ],
      test: [1, 2, 3, 4, 120, DEFAULT_SEGMENTS]
    },
    'with an ellipsis': {
      args: [
        {
          radius1: 1,
          radius2: 2,
          x: 3,
          y: 4,
          rotation: 5,
          segments: 60
        }
      ],
      test: [1, 2, 3, 4, 5, 60]
    }
  };

  global.geometry = function(source) {
    return {
      shouldBe: {
        translatable: function() {
          var xAmount, yAmount;
          xAmount = 5;
          yAmount = 3;
          return describe('its translate method', function() {
            describe('called with an object', function() {
              return it('translates the geometry', function() {
                var original, pt, pt2, target, _i, _len, _ref, _results;
                target = this[source];
                original = target.points();
                target.translate({
                  x: xAmount,
                  y: yAmount
                });
                _ref = target.points();
                _results = [];
                for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
                  pt = _ref[i];
                  pt2 = original[i];
                  _results.push(expect(pt).toBeSamePoint(pt2.add(xAmount, yAmount)));
                }
                return _results;
              });
            });
            describe('call with two number', function() {
              return it('translates the geometry', function() {
                var original, pt, pt2, target, _i, _len, _ref, _results;
                target = this[source];
                original = target.points();
                target.translate(xAmount, yAmount);
                _ref = target.points();
                _results = [];
                for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
                  pt = _ref[i];
                  pt2 = original[i];
                  _results.push(expect(pt).toBeSamePoint(pt2.add(xAmount, yAmount)));
                }
                return _results;
              });
            });
            return it('returns the instance', function() {
              return expect(this[source].translate()).toBe(this[source]);
            });
          });
        },
        rotatable: function() {
          var rotation;
          rotation = 10;
          return describe('its rotate method', function() {
            it('rotates the geometry around its center', function() {
              var center, original, pt, pt2, target, _i, _len, _ref, _results;
              target = this[source];
              center = target.center();
              original = target.points();
              target.rotate(rotation);
              _ref = target.points();
              _results = [];
              for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
                pt = _ref[i];
                pt2 = original[i];
                _results.push(expect(pt).toBeSamePoint(pt2.rotateAround(center, rotation)));
              }
              return _results;
            });
            return it('returns the instance', function() {
              return expect(this[source].rotate(0)).toBe(this[source]);
            });
          });
        },
        scalable: function() {
          var scale;
          scale = 2;
          return describe('its scale method', function() {
            it('scales the geometry around its center', function() {
              var center, original, pt, pt2, target, _i, _len, _ref, _results;
              target = this[source];
              center = target.center();
              original = target.points();
              target.scale(scale);
              _ref = target.points();
              _results = [];
              for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
                pt = _ref[i];
                pt2 = original[i];
                _results.push(expect(pt).toBeSamePoint(center.add(pt2.subtract(center).scale(scale))));
              }
              return _results;
            });
            return it('returns the instance', function() {
              return expect(this[source].scale(1)).toBe(this[source]);
            });
          });
        },
        closedGeometry: function() {
          return it('is a closed geometry', function() {
            return expect(this[source].closedGeometry()).toBeTruthy();
          });
        },
        openGeometry: function() {
          return it('is an open geometry', function() {
            return expect(this[source].closedGeometry()).toBeFalsy();
          });
        }
      }
    };
  };

  global.testDrawingOf = function(source) {
    return describe("with drawing api", function() {
      beforeEach(function() {
        return this.context = {
          fill: (function(_this) {
            return function() {
              return _this.fillCalled = true;
            };
          })(this),
          stroke: (function(_this) {
            return function() {
              return _this.strokeCalled = true;
            };
          })(this),
          beginPath: (function(_this) {
            return function() {
              return _this.beginPathCalled = true;
            };
          })(this),
          closePath: (function(_this) {
            return function() {
              return _this.closePathCalled = true;
            };
          })(this),
          moveTo: (function(_this) {
            return function() {
              return _this.moveToCalled = true;
            };
          })(this),
          lineTo: (function(_this) {
            return function() {
              return _this.lineToCalled = true;
            };
          })(this),
          arc: (function(_this) {
            return function() {
              return _this.arcCalled = true;
            };
          })(this),
          save: (function(_this) {
            return function() {
              return _this.saveCalled = true;
            };
          })(this),
          restore: (function(_this) {
            return function() {
              return _this.restoreCalled = true;
            };
          })(this),
          translate: (function(_this) {
            return function() {
              return _this.translateCalled = true;
            };
          })(this),
          rotate: (function(_this) {
            return function() {
              return _this.rotateCalled = true;
            };
          })(this),
          scale: (function(_this) {
            return function() {
              return _this.scaleCalled = true;
            };
          })(this)
        };
      });
      describe("the " + source + " stroke method", function() {
        beforeEach(function() {
          this.color = "#ffffff";
          return this[source].stroke(this.context, this.color);
        });
        it('sets the stroke style on the context object', function() {
          return expect(this.context.strokeStyle).toBe(this.color);
        });
        return it('calls the stroke method of the context object', function() {
          return expect(this.strokeCalled).toBeTruthy();
        });
      });
      return describe("the " + source + " fill method", function() {
        beforeEach(function() {
          this.color = "#ffffff";
          return this[source].fill(this.context, this.color);
        });
        it('sets the fill style on the context object', function() {
          return expect(this.context.fillStyle).toBe(this.color);
        });
        return it('calls the fill method of the context object', function() {
          return expect(this.fillCalled).toBeTruthy();
        });
      });
    });
  };

  global.matrix = function(a, b, c, d, tx, ty) {
    return new agt.geom.Matrix(a, b, c, d, tx, ty);
  };

  matrix.identity = function() {
    return new agt.geom.Matrix;
  };

  matrix.transformed = function() {
    return new agt.geom.Matrix(1, 2, 3, 4, 5, 6);
  };

  matrix.inverted = function() {
    return new agt.geom.Matrix(-2, 1, 1.5, -0.5, 1, -2);
  };

  matrix.translated = function() {
    return new agt.geom.Matrix(1, 2, 3, 4, 3, 8);
  };

  matrix.scaled = function() {
    return new agt.geom.Matrix(0.5, 2, 3, 8, 2.5, 12);
  };

  matrix.rotated = function() {
    var a, angle, b, c, cos, d, sin, tx, ty, _ref;
    _ref = [1, 2, 3, 4, 5, 6], a = _ref[0], b = _ref[1], c = _ref[2], d = _ref[3], tx = _ref[4], ty = _ref[5];
    angle = 72;
    cos = Math.cos(angle);
    sin = Math.sin(angle);
    return new agt.geom.Matrix(a * cos - b * sin, a * sin + b * cos, c * cos - d * sin, c * sin + d * cos, tx * cos - ty * sin, tx * sin + ty * cos);
  };

  matrix.appended = function() {
    return new agt.geom.Matrix(6 * 1 + 5 * 3, 6 * 2 + 5 * 4, 4 * 1 + 3 * 3, 4 * 2 + 3 * 4, 2 * 1 + 1 * 3 + 5, 2 * 2 + 1 * 4 + 6);
  };

  matrix.prepended = function() {
    return new agt.geom.Matrix(1 * 6 + 2 * 4, 1 * 5 + 2 * 3, 3 * 6 + 4 * 4, 3 * 5 + 4 * 3, 5 * 6 + 6 * 4 + 2, 5 * 5 + 6 * 3 + 1);
  };

  matrix.skewed = function() {
    var a, b, c, d, _ref;
    _ref = [Math.cos(2), Math.sin(2), -Math.sin(-2), Math.cos(-2)], a = _ref[0], b = _ref[1], c = _ref[2], d = _ref[3];
    return new agt.geom.Matrix(a * 1 + b * 3, a * 2 + b * 4, c * 1 + d * 3, c * 2 + d * 4, 5, 6);
  };

  global.addMatrixMatchers = function(scope) {
    return jasmine.addMatchers({
      toBeSameMatrix: function() {
        return {
          compare: function(actual, m) {
            var result;
            result = {};
            result.message = "Expected " + actual + " to be a matrix equal to " + m;
            result.pass = actual.a === m.a && actual.b === m.b && actual.c === m.c && actual.d === m.d && actual.tx === m.tx && actual.ty === m.ty;
            return result;
          }
        };
      },
      toBeIdentity: function() {
        return {
          compare: function(actual) {
            var result;
            result = {};
            result.message = "Expected " + this.actual + " to be an identity matrix";
            result.pass = actual.a === 1 && actual.b === 0 && actual.c === 0 && actual.d === 1 && actual.tx === 0 && actual.ty === 0;
            return result;
          }
        };
      }
    });
  };

  global.lengthOf = function(source) {
    return {
      shouldBe: function(length) {
        return it("has a length of " + length, function() {
          return expect(this[source].length()).toBeClose(length);
        });
      }
    };
  };

  equalEnough = Math.deltaBelowRatio;

  global.addPointMatchers = function(scope) {
    return jasmine.addMatchers({
      toBeClose: function() {
        return {
          compare: function(actual, value) {
            var result;
            result = {};
            result.message = "Expected " + actual + " to be equal to " + value + " with a precision of 1e-10";
            result.pass = equalEnough(actual, value);
            return result;
          }
        };
      },
      toBePoint: function() {
        return {
          compare: function(actual, x, y) {
            var result;
            if (x == null) {
              x = 0;
            }
            if (y == null) {
              y = 0;
            }
            result = {};
            result.message = "Expected " + actual + " to be a point with x=" + x + " and y=" + y;
            result.pass = equalEnough(actual.x, x) && equalEnough(actual.y, y);
            return result;
          }
        };
      },
      toBeSamePoint: function() {
        return {
          compare: function(actual, pt) {
            var result;
            result = {};
            result.message = "Expected " + actual + " to be a point equivalent to (" + pt.x + "," + pt.y + ")";
            result.pass = equalEnough(actual.x, pt.x) && equalEnough(actual.y, pt.y);
            return result;
          }
        };
      }
    });
  };

  global.point = function(x, y) {
    return new agt.geom.Point(x, y);
  };

  global.pointLike = function(x, y) {
    return {
      x: x,
      y: y
    };
  };

  global.pointOperator = function(operator) {
    var operatorActions, operatorOption;
    operatorActions = {
      copy: function(expectation) {
        return it("returns a copy of the point", function() {
          return expect(expectation.call(this)).toBeSamePoint(this.point);
        });
      },
      throws: function(expectation) {
        return it('throws an error', function() {
          return expect((function(_this) {
            return function() {
              return expectation.call(_this);
            };
          })(this)).toThrow();
        });
      },
      "null": function(expectation) {
        return it('returns null', function() {
          return expect(expectation.call(this)).toBeNull();
        });
      },
      nan: function(expectation) {
        return it('returns nan', function() {
          return expect(expectation.call(this)).toBe(NaN);
        });
      }
    };
    operatorOption = function(value, actions, expectation) {
      if (actions == null) {
        actions = {};
      }
      if (expectation == null) {
        expectation = null;
      }
      switch (typeof value) {
        case 'function':
          return it('', function() {
            return value.call(this, expectation != null ? expectation.call(this) : void 0);
          });
        case 'string':
          return typeof actions[value] === "function" ? actions[value](expectation) : void 0;
      }
    };
    return {
      "with": function(x1, y1) {
        this.x1 = x1;
        this.y1 = y1;
        return this;
      },
      and: function(x2, y2) {
        this.x2 = x2;
        this.y2 = y2;
        return this;
      },
      where: function(options) {
        this.options = options;
        return this;
      },
      should: function(message, block) {
        var options, x1, x2, y1, y2;
        x1 = this.x1, x2 = this.x2, y1 = this.y1, y2 = this.y2, options = this.options;
        return describe("::" + operator + " called", function() {
          beforeEach(function() {
            return this.point = new agt.geom.Point(x1, y1);
          });
          describe('with another point', function() {
            return it(message, function() {
              return block.call(this, this.point[operator](point(x2, y2)));
            });
          });
          describe('with a point-like object', function() {
            return it(message, function() {
              return block.call(this, this.point[operator](pointLike(x2, y2)));
            });
          });
          if (options.emptyArguments != null) {
            describe('with no argument', function() {
              return operatorOption(options.emptyArguments, operatorActions, function() {
                return this.point[operator]();
              });
            });
          }
          if (options.emptyObject != null) {
            describe('with an empty object', function() {
              return operatorOption(options.emptyObject, operatorActions, function() {
                return this.point[operator]({});
              });
            });
          }
          if (options.partialObject != null) {
            describe('with a partial object', function() {
              return operatorOption(options.partialObject, operatorActions, function() {
                return this.point[operator]({
                  x: x2
                });
              });
            });
          }
          if (options.singleNumber != null) {
            describe('with only one number', function() {
              return operatorOption(options.singleNumber, operatorActions, function() {
                return this.point[operator](x2);
              });
            });
          }
          if (options.nullArgument != null) {
            return describe('with null', function() {
              return operatorOption(options.nullArgument, operatorActions, function() {
                return this.point[operator](null);
              });
            });
          }
        });
      }
    };
  };

  global.calledWithPoints = function() {
    var coordinates;
    coordinates = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (coordinates.length % 2 === 1) {
      throw new Error("coordinates must be even");
    }
    return {
      where: function(options) {
        this.options = options;
        return this;
      },
      should: function(message, block) {
        return step(coordinates, 2, (function(_this) {
          return function(_arg) {
            var options, x, y;
            x = _arg[0], y = _arg[1];
            options = _this.options;
            describe("called with point (" + x + "," + y + ")", function() {
              return it(message, function() {
                return block.call(this, this[options.source][options.method](point(x, y)), x, y);
              });
            });
            return describe('called with a point-like object', function() {
              return it(message, function() {
                return block.call(this, this[options.source][options.method](pointLike(x, y)), x, y);
              });
            });
          };
        })(this));
      }
    };
  };

  global.pointOf = function() {
    var args, method, source;
    source = arguments[0], method = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    return {
      shouldBe: function(x, y) {
        var _ref;
        if (typeof x === 'object') {
          _ref = x, x = _ref.x, y = _ref.y;
        }
        beforeEach(function() {
          return addPointMatchers(this);
        });
        return describe("the " + source + " " + method + " method", function() {
          return it("returns a point equal to (" + x + "," + y + ")", function() {
            source = this[source];
            return expect(source[method].apply(source, args)).toBePoint(x, y);
          });
        });
      }
    };
  };

  global.polygon = function(vertices) {
    return new agt.geom.Polygon(vertices);
  };

  global.polygonData = function(vertices) {
    var data;
    data = {
      vertices: vertices
    };
    merge(data, {
      source: "new agt.geom.Polygon([" + (vertices.map(function(pt) {
        return pt.toSource();
      })) + "])"
    });
    return data;
  };

  global.polygonFactories = {
    'with four points in an array': {
      args: function() {
        return [[point(0, 0), point(4, 0), point(4, 4), point(0, 4)]];
      },
      test: function() {
        return [point(0, 0), point(4, 0), point(4, 4), point(0, 4)];
      }
    },
    'with an object containing vertices': {
      args: function() {
        return [
          {
            vertices: [point(0, 0), point(4, 0), point(4, 4), point(0, 4)]
          }
        ];
      },
      test: function() {
        return [point(0, 0), point(4, 0), point(4, 4), point(0, 4)];
      }
    }
  };

  global.proxyable = function(source) {
    return {
      shouldDefine: function(methods) {
        return {
          asProxyable: function() {
            return eachPair(methods, function(method, type) {
              return describe("its " + method + " method", function() {
                return it("is proxyable as " + type, function() {
                  var meth;
                  meth = this[source][method].proxyable;
                  return expect(meth).toBe(type);
                });
              });
            });
          }
        };
      }
    };
  };

  global.rectangle = function(x, y, width, height, rotation) {
    return new agt.geom.Rectangle(x, y, width, height, rotation);
  };

  global.addRectangleMatchers = function(scope) {
    return jasmine.addMatchers({
      toBeRectangle: function() {
        return {
          compare: function(actual, x, y, width, height, rotation) {
            var result;
            if (x == null) {
              x = 0;
            }
            if (y == null) {
              y = 0;
            }
            if (width == null) {
              width = 0;
            }
            if (height == null) {
              height = 0;
            }
            if (rotation == null) {
              rotation = 0;
            }
            result = {};
            result.message = "Expect " + actual + "to be a rectangle equals to (" + x + "," + y + "," + width + "," + height + "," + rotation + ")";
            result.pass = actual.x === x && actual.y === y && actual.width === width && actual.height === height && actual.rotation === rotation;
            return result;
          }
        };
      }
    });
  };

  global.testRotatedRectangle = function(source, x, y, width, height, rotation) {
    var bounds, data, methods;
    data = rectangleData(x, y, width, height, rotation);
    methods = ['topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'topEdge', 'bottomEdge', 'leftEdge', 'rightEdge', 'center', 'topEdgeCenter', 'bottomEdgeCenter', 'leftEdgeCenter', 'rightEdgeCenter', 'diagonal'];
    bounds = ['top', 'bottom', 'left', 'right'];
    methods.forEach(function(m) {
      return pointOf(source, m).shouldBe(data[m]);
    });
    return bounds.forEach(function(k) {
      return describe("the " + source + " " + k + " method", function() {
        return it("returns " + data[k], function() {
          return expect(this[source][k]()).toBeClose(data[k]);
        });
      });
    });
  };

  global.rectangleData = function(x, y, width, height, rotation) {
    var source, xLeftEdge, xTopEdge, yLeftEdge, yTopEdge, _ref;
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    if (width == null) {
      width = 0;
    }
    if (height == null) {
      height = 0;
    }
    if (rotation == null) {
      rotation = 0;
    }
    if (typeof x === 'object') {
      _ref = x, x = _ref.x, y = _ref.y, width = _ref.width, height = _ref.height, rotation = _ref.rotation;
    }
    xTopEdge = width * Math.cos(rotation);
    yTopEdge = width * Math.sin(rotation);
    xLeftEdge = height * Math.cos(rotation + Math.PI / 2);
    yLeftEdge = height * Math.sin(rotation + Math.PI / 2);
    source = "new agt.geom.Rectangle(" + x + "," + y + "," + width + "," + height + "," + rotation + ")";
    return {
      topEdge: {
        x: xTopEdge,
        y: yTopEdge
      },
      leftEdge: {
        x: xLeftEdge,
        y: yLeftEdge
      },
      bottomEdge: {
        x: xTopEdge,
        y: yTopEdge
      },
      rightEdge: {
        x: xLeftEdge,
        y: yLeftEdge
      },
      diagonal: {
        x: xLeftEdge + xTopEdge,
        y: yLeftEdge + yTopEdge
      },
      topLeft: {
        x: x,
        y: y
      },
      topRight: {
        x: x + xTopEdge,
        y: y + yTopEdge
      },
      bottomRight: {
        x: x + xTopEdge + xLeftEdge,
        y: y + yTopEdge + yLeftEdge
      },
      bottomLeft: {
        x: x + xLeftEdge,
        y: y + yLeftEdge
      },
      topEdgeCenter: {
        x: x + xTopEdge / 2,
        y: y + yTopEdge / 2
      },
      bottomEdgeCenter: {
        x: x + xLeftEdge + xTopEdge / 2,
        y: y + yLeftEdge + yTopEdge / 2
      },
      leftEdgeCenter: {
        x: x + xLeftEdge / 2,
        y: y + yLeftEdge / 2
      },
      rightEdgeCenter: {
        x: x + xTopEdge + xLeftEdge / 2,
        y: y + yTopEdge + yLeftEdge / 2
      },
      center: {
        x: x + xTopEdge / 2 + xLeftEdge / 2,
        y: y + yTopEdge / 2 + yLeftEdge / 2
      },
      topEdgeCenter: {
        x: x + xTopEdge / 2,
        y: y + yTopEdge / 2
      },
      bottomEdgeCenter: {
        x: x + xTopEdge / 2 + xLeftEdge,
        y: y + yTopEdge / 2 + yLeftEdge
      },
      leftEdgeCenter: {
        x: x + xLeftEdge / 2,
        y: y + yLeftEdge / 2
      },
      rightEdgeCenter: {
        x: x + xLeftEdge / 2 + xTopEdge,
        y: y + yLeftEdge / 2 + yTopEdge
      },
      top: Math.min(y, y + yTopEdge, y + yLeftEdge, y + yTopEdge + yLeftEdge),
      bottom: Math.max(y, y + yTopEdge, y + yLeftEdge, y + yTopEdge + yLeftEdge),
      left: Math.min(x, x + xTopEdge, x + xLeftEdge, x + xTopEdge + xLeftEdge),
      right: Math.max(x, x + xTopEdge, x + xLeftEdge, x + xTopEdge + xLeftEdge),
      source: source
    };
  };

  global.addSpiralMatchers = function(scope) {
    return jasmine.addMatchers({
      toBeSpiral: function() {
        return {
          compare: function(actual, r1, r2, twirl, x, y, rotation, segments) {
            var result;
            result = {};
            result.message = function() {
              return "Expected " + actual + " to be an spiral with radius1=" + r1 + ", radius2=" + r2 + ", twirl=" + twirl + ", x=" + x + ", y=" + y + ", rotation=" + rotation + ", segments=" + segments;
            };
            result.pass = actual.radius1 === r1 && actual.radius2 === r2 && actual.twirl === twirl && actual.x === x && actual.y === y && actual.rotation === rotation && actual.segments === segments;
            return result;
          }
        };
      }
    });
  };

  global.spiral = function(r1, r2, twirl, x, y, rotation, segments) {
    return new agt.geom.Spiral(r1, r2, twirl, x, y, rotation, segments);
  };

  global.spiralData = function(radius1, radius2, twirl, x, y, rotation, segments) {
    var a, b, data, k, phi, source, t1, t2, v, x1, x2, y1, y2;
    data = {
      radius1: radius1,
      radius2: radius2,
      twirl: twirl,
      x: x,
      y: y,
      rotation: rotation,
      segments: segments
    };
    source = "new agt.geom.Spiral(" + (((function() {
      var _results;
      _results = [];
      for (k in data) {
        v = data[k];
        _results.push(v);
      }
      return _results;
    })()).join(',')) + ")";
    merge(data, {
      source: source,
      acreage: Math.PI * radius1 * radius2,
      length: Math.PI * (3 * (radius1 + radius2) - Math.sqrt((3 * radius1 + radius2) * (radius1 + radius2 * 3)))
    });
    a = radius1;
    b = radius2;
    phi = rotation;
    t1 = Math.atan(-b * Math.tan(phi) / a);
    t2 = Math.atan(b * (Math.cos(phi) / Math.sin(phi)) / a);
    x1 = x + a * Math.cos(t1 + Math.PI) * Math.cos(phi) - b * Math.sin(t1 + Math.PI) * Math.sin(phi);
    x2 = x + a * Math.cos(t1) * Math.cos(phi) - b * Math.sin(t1) * Math.sin(phi);
    y1 = y + a * Math.cos(t2) * Math.sin(phi) + b * Math.sin(t2) * Math.cos(phi);
    y2 = y + a * Math.cos(t2 + Math.PI) * Math.sin(phi) + b * Math.sin(t2 + Math.PI) * Math.cos(phi);
    merge(data, {
      left: Math.min(x1, x2),
      right: Math.max(x1, x2),
      top: Math.min(y1, y2),
      bottom: Math.max(y1, y2)
    });
    merge(data, {
      bounds: {
        top: data.top,
        bottom: data.bottom,
        left: data.left,
        right: data.right
      }
    });
    return data;
  };

  global.spiralFactories = {
    'with five numbers': {
      args: [1, 2, 3, 4, 5],
      test: [1, 2, 3, 4, 5, 0, DEFAULT_SEGMENTS]
    },
    'with six numbers': {
      args: [1, 2, 3, 4, 5, 6],
      test: [1, 2, 3, 4, 5, 6, DEFAULT_SEGMENTS]
    },
    'with seven numbers': {
      args: [1, 2, 3, 4, 5, 6, 60],
      test: [1, 2, 3, 4, 5, 6, 60]
    },
    'without arguments': {
      args: [],
      test: [1, 1, 1, 0, 0, 0, DEFAULT_SEGMENTS]
    },
    'with a spiral without rotation, twirl or segments': {
      args: [
        {
          radius1: 1,
          radius2: 2,
          x: 3,
          y: 4
        }
      ],
      test: [1, 2, 1, 3, 4, 0, DEFAULT_SEGMENTS]
    },
    'with a spiral without segments': {
      args: [
        {
          radius1: 1,
          radius2: 2,
          twirl: 3,
          x: 4,
          y: 5,
          rotation: 120
        }
      ],
      test: [1, 2, 3, 4, 5, 120, DEFAULT_SEGMENTS]
    },
    'with a spiral': {
      args: [
        {
          radius1: 1,
          radius2: 2,
          twirl: 3,
          x: 4,
          y: 5,
          rotation: 6,
          segments: 60
        }
      ],
      test: [1, 2, 3, 4, 5, 6, 60]
    }
  };

  Point = agt.geom.Point;

  construct = function(klass, args) {
    var f;
    f = BUILDS[args != null ? args.length : 0];
    return f(klass, args);
  };

  testSplineMethod = function(method, source, expected) {
    return describe("its " + method + " method", function() {
      return it("returns " + expected, function() {
        return expect(this[source][method]()).toBeClose(expected);
      });
    });
  };

  testSplineLength = function(method, source, expected) {
    return describe("its " + method + " method", function() {
      return it("returns an array of length " + expected, function() {
        return expect(this[source][method]().length).toBeClose(expected);
      });
    });
  };

  testSplineProperty = function(property, source, expected) {
    return describe("its " + property + " property", function() {
      return it("is " + expected, function() {
        return expect(this[source][property]).toBeClose(expected);
      });
    });
  };

  testPropertyLength = function(property, source, expected) {
    return describe("its " + property + " property", function() {
      return it("has " + expected + " elements", function() {
        return expect(this[source][property].length).toBeClose(expected);
      });
    });
  };

  global.testIntersectionsMethodsOf = function(klass) {
    var mid, segmentSize, vertices;
    segmentSize = klass.segmentSize();
    mid = segmentSize / 2;
    vertices = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= segmentSize ? _i <= segmentSize : _i >= segmentSize; i = 0 <= segmentSize ? ++_i : --_i) {
        _results.push(point(i, 0));
      }
      return _results;
    })();
    return describe("when instanciated with " + vertices, function() {
      beforeEach(function() {
        addPointMatchers(this);
        return this.spline = construct(klass, [vertices]);
      });
      describe('its intersects method', function() {
        describe('called with a simple line crossing it in the middle', function() {
          return it('returns true', function() {
            return expect(this.spline.intersects({
              points: function() {
                return [point(mid, -1), point(mid, 1)];
              }
            })).toBeTruthy();
          });
        });
        return describe('called with a simple line not crossing it', function() {
          return it('returns false', function() {
            return expect(this.spline.intersects({
              points: function() {
                return [point(-2, -1), point(-2, 1)];
              }
            })).toBeFalsy();
          });
        });
      });
      return describe('its intersections method', function() {
        describe('called with a simple line crossing it in the middle', function() {
          return it('returns true', function() {
            var intersections;
            intersections = this.spline.intersections({
              points: function() {
                return [point(mid, -1), point(mid, 1)];
              }
            });
            expect(intersections.length).toBe(1);
            return expect(intersections[0]).toBePoint(mid, 0);
          });
        });
        return describe('called with a simple line not crossing it', function() {
          return it('returns false', function() {
            var intersections;
            intersections = this.spline.intersections({
              points: function() {
                return [point(-2, -1), point(-2, 1)];
              }
            });
            return expect(intersections).toBeNull();
          });
        });
      });
    });
  };

  global.testPathMethodsOf = function(klass) {
    var hpoints, segmentSize, vpoints;
    segmentSize = klass.segmentSize();
    hpoints = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= segmentSize ? _i <= segmentSize : _i >= segmentSize; i = 0 <= segmentSize ? ++_i : --_i) {
        _results.push(point(i, 0));
      }
      return _results;
    })();
    vpoints = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= segmentSize ? _i <= segmentSize : _i >= segmentSize; i = 0 <= segmentSize ? ++_i : --_i) {
        _results.push(point(0, i));
      }
      return _results;
    })();
    return [hpoints, vpoints].forEach(function(vertices) {
      return describe("when instanciated with " + vertices, function() {
        beforeEach(function() {
          addPointMatchers(this);
          return this.spline = construct(klass, [vertices]);
        });
        return describe('its pathPointAt method', function() {
          describe('called with 0', function() {
            return it('returns the first vertice', function() {
              return expect(this.spline.pathPointAt(0)).toBeSamePoint(first(vertices));
            });
          });
          describe('called with 0.5', function() {
            return it('returns the first vertice', function() {
              return expect(this.spline.pathPointAt(0.5)).toBeSamePoint(first(vertices).add(last(vertices).scale(0.5)));
            });
          });
          return describe('called with 1', function() {
            return it('returns the last vertice', function() {
              return expect(this.spline.pathPointAt(1)).toBeSamePoint(last(vertices));
            });
          });
        });
      });
    });
  };

  global.spline = function(source) {
    return {
      shouldBe: {
        cloneable: function() {
          return describe('its clone method', function() {
            beforeEach(function() {
              this.target = this[source];
              return this.copy = this.target.clone();
            });
            it('returns a copy of the spline', function() {
              expect(this.copy).toBeDefined();
              return expect(this.copy.vertices).toEqual(this.target.vertices);
            });
            return it('returns a simple reference to the original vertices', function() {
              var vertex, _i, _len, _ref, _results;
              expect(this.copy.vertices).not.toBe(this.target.vertices);
              _ref = this.copy.vertices;
              _results = [];
              for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
                vertex = _ref[i];
                _results.push(expect(vertex).not.toBe(this.target.vertices[i]));
              }
              return _results;
            });
          });
        },
        formattable: function(classname) {
          describe('its classname method', function() {
            return it('returns its class name', function() {
              return expect(this[source].classname()).toBe(classname);
            });
          });
          return describe('its toString method', function() {
            return it('returns the classname in a formatted string', function() {
              return expect(this[source].toString().indexOf(classname)).not.toBe(-1);
            });
          });
        },
        sourcable: function(pkg) {
          return describe('its toSource method', function() {
            return it('returns the code to create the spline again', function() {
              var result, target, verticesSource;
              target = this[source];
              result = target.toSource();
              verticesSource = target.vertices.map(function(p) {
                return p.toSource();
              });
              return expect(result).toBe("new " + pkg + "([" + (verticesSource.join(',')) + "]," + target.bias + ")");
            });
          });
        }
      },
      shouldHave: function(expected) {
        return {
          segments: function() {
            return testSplineMethod('segments', source, expected);
          },
          points: function() {
            return testSplineLength('points', source, expected);
          },
          vertices: function() {
            return testPropertyLength('vertices', source, expected);
          }
        };
      },
      shouldValidateWith: function(expected) {
        return {
          vertices: function() {
            return describe("its validateVertices method", function() {
              var failingAmount;
              failingAmount = expected - 1;
              describe("called with " + failingAmount + " vertices", function() {
                return it('returns false', function() {
                  var n, res, vertices;
                  vertices = (function() {
                    var _i, _ref, _results;
                    _results = [];
                    for (n = _i = 0, _ref = failingAmount - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; n = 0 <= _ref ? ++_i : --_i) {
                      _results.push(point());
                    }
                    return _results;
                  })();
                  res = this[source].validateVertices(vertices);
                  return expect(res).toBeFalsy();
                });
              });
              return describe("called with " + expected + " vertices", function() {
                return it('returns true', function() {
                  var n, res, vertices;
                  vertices = (function() {
                    var _i, _ref, _results;
                    _results = [];
                    for (n = _i = 0, _ref = expected - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; n = 0 <= _ref ? ++_i : --_i) {
                      _results.push(point());
                    }
                    return _results;
                  })();
                  res = this[source].validateVertices(vertices);
                  return expect(res).toBeTruthy();
                });
              });
            });
          }
        };
      },
      segmentSize: {
        shouldBe: function(expected) {
          return testSplineMethod('segmentSize', source, expected);
        }
      },
      bias: {
        shouldBe: function(expected) {
          return testSplineProperty('bias', source, expected);
        }
      }
    };
  };

  global.acreageOf = function(source) {
    return {
      shouldBe: function(acreage) {
        return it("has an acreage of " + acreage, function() {
          return expect(this[source].acreage()).toBe(acreage);
        });
      }
    };
  };

  pt = point(1, 0);

  v = point(4, 0);

  v2 = v.rotate(Math.PI * 2 / 6);

  global.triangleFactories = {
    "default": function() {
      return [new agt.geom.Point(1, 2), new agt.geom.Point(3, 4), new agt.geom.Point(1, 5)];
    },
    isosceles: function() {
      return [new agt.geom.Point(1, 1), new agt.geom.Point(3, 1), new agt.geom.Point(2, 4)];
    },
    rectangle: function() {
      return [new agt.geom.Point(1, 1), new agt.geom.Point(3, 1), new agt.geom.Point(3, 4)];
    },
    equilateral: function() {
      return [pt, pt.add(v), pt.add(v2)];
    }
  };

  global.triangle = function(a, b, c) {
    if (a == null) {
      a = triangleFactories["default"]()[0];
    }
    if (c == null) {
      c = triangleFactories["default"]()[2];
    }
    if (b == null) {
      b = triangleFactories["default"]()[1];
    }
    return new agt.geom.Triangle(a, b, c);
  };

  global.triangleData = function(a, b, c) {
    var data;
    if (a == null) {
      a = triangleFactories["default"]()[0];
    }
    if (c == null) {
      c = triangleFactories["default"]()[2];
    }
    if (b == null) {
      b = triangleFactories["default"]()[1];
    }
    data = {
      a: a,
      b: b,
      c: c
    };
    merge(data, {
      ab: b.subtract(a),
      ac: c.subtract(a),
      ba: a.subtract(b),
      bc: c.subtract(b),
      ca: a.subtract(c),
      cb: b.subtract(c)
    });
    merge(data, {
      top: Math.min(a.y, b.y, c.y),
      bottom: Math.max(a.y, b.y, c.y),
      left: Math.min(a.x, b.x, c.x),
      right: Math.max(a.x, b.x, c.x)
    });
    merge(data, {
      abc: data.ba.angleWith(data.bc),
      bac: data.ab.angleWith(data.ac),
      acb: data.ca.angleWith(data.cb)
    });
    merge(data, {
      bounds: {
        top: data.top,
        bottom: data.bottom,
        left: data.left,
        right: data.right
      }
    });
    merge(data, {
      center: {
        x: (a.x + b.x + c.x) / 3,
        y: (a.y + b.y + c.y) / 3
      },
      abCenter: a.add(data.ab.scale(0.5)),
      acCenter: a.add(data.ac.scale(0.5)),
      bcCenter: b.add(data.bc.scale(0.5))
    });
    merge(data, {
      length: data.ab.length() + data.bc.length() + data.ca.length(),
      acreage: data.ab.length() * data.bc.length() * Math.abs(Math.sin(data.abc)) / 2
    });
    return data;
  };

  ['isosceles', 'rectangle', 'equilateral'].forEach(function(k) {
    triangle[k] = function() {
      return triangle.apply(global, triangleFactories[k]());
    };
    return triangleData[k] = function() {
      return triangleData.apply(global, triangleFactories[k]());
    };
  });

  triangle.withPointLike = function(a, b, c) {
    if (a == null) {
      a = {
        x: 1,
        y: 2
      };
    }
    if (b == null) {
      b = {
        x: 3,
        y: 4
      };
    }
    if (c == null) {
      c = {
        x: 1,
        y: 5
      };
    }
    return triangle(a, b, c);
  };

  global.byRateCounter = function(source) {
    return {
      rate: testProperty(source, 'rate'),
      rest: testProperty(source, 'rest')
    };
  };

  global.counter = function(source) {
    return {
      count: testProperty(source, 'count')
    };
  };

  global.emission = function(source) {
    return {
      system: {
        shouldBe: function(system) {
          return it("should have its system define with " + system, function() {
            return expect(this[source].system).toBe(this[system]);
          });
        }
      },
      shouldBe: {
        iterable: function(times, max) {
          if (max == null) {
            max = 100;
          }
          return it("should behave as an iterator with " + times + " iterations", function() {
            var n, target;
            n = 0;
            target = this[source];
            while (target.hasNext()) {
              target.next();
              n++;
              if (n > max) {
                break;
              }
            }
            return expect(n).toBe(times);
          });
        }
      }
    };
  };

  global.particle = function(source) {
    return {
      life: testProperty(source, 'life'),
      maxLife: testProperty(source, 'maxLife'),
      dead: testProperty(source, 'dead')
    };
  };

  global.testPoolable = function(klass) {
    return {
      "with": function(parameters) {
        return describe('get method', function() {
          return describe('called with parameters', function() {
            beforeEach(function() {
              return this.instance = klass.get(parameters);
            });
            afterEach(function() {
              return klass.resetPools();
            });
            it('should return a parameterized instance', function() {
              var k, _results;
              expect(this.instance).toBeDefined();
              _results = [];
              for (k in parameters) {
                v = parameters[k];
                _results.push(expect(this.instance[k]).toBe(v));
              }
              return _results;
            });
            it('should have added one instance in the usedInstances pool', function() {
              return expect(klass.usedInstances.length).toBe(1);
            });
            return describe('when an instance is released', function() {
              beforeEach(function() {
                return klass.release(this.instance);
              });
              it('should have removed that instance from the usedInstances pool', function() {
                return expect(klass.usedInstances.length).toBe(0);
              });
              it('should have added that instance in the waiting pool', function() {
                return expect(klass.unusedInstances.length).toBe(1);
              });
              return describe('requesting a new instance', function() {
                return it('should return the previously unusedInstances instance', function() {
                  return expect(klass.get()).toBe(this.instance);
                });
              });
            });
          });
        });
      }
    };
  };

  mockListener = function(signal) {
    return function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return global.currentResults[signal] = args;
    };
  };

  SIGNALS = ['particlesCreated', 'particlesDied', 'emissionStarted', 'emissionFinished'];

  global.createListener = function() {
    beforeEach(function() {
      global.currentResults = {};
      return SIGNALS.forEach((function(_this) {
        return function(m) {
          return _this.system[m].add(mockListener(m));
        };
      })(this));
    });
    return afterEach(function() {
      return SIGNALS.forEach((function(_this) {
        return function(m) {
          return _this.system[m].removeAll();
        };
      })(this));
    });
  };

  global.system = function(source) {
    return {
      should: {
        emitting: function() {
          return it("" + source + " should emitting", function() {
            return expect(this[source].emitting()).toBeTruthy();
          });
        },
        not: {
          emitting: function() {
            return it("" + source + " should not emitting", function() {
              return expect(this[source].emitting()).toBeFalsy();
            });
          }
        }
      },
      shouldHave: function(value) {
        return {
          particles: function() {
            return it("" + source + " should have " + value + " particles", function() {
              return expect(this[source].particles.length).toBe(value);
            });
          },
          emissions: function() {
            return it("" + source + " should have " + value + " emissions", function() {
              return expect(this[source].emissions.length).toBe(value);
            });
          },
          signal: function(signal) {
            return it("" + source + " should have a " + signal + " signal", function() {
              var listener, listenersCount, signalCalled, target, targetSignal;
              target = this[source];
              targetSignal = target[signal];
              signalCalled = false;
              listener = function() {
                return signalCalled = true;
              };
              listenersCount = targetSignal.listeners.length;
              targetSignal.add(listener);
              expect(targetSignal.listeners.length).toBe(listenersCount + 1);
              targetSignal.dispatch();
              expect(signalCalled).toBeTruthy();
              targetSignal.remove(listener);
              return expect(targetSignal.listeners.length).toBe(listenersCount);
            });
          },
          dispatched: function(signal) {
            return it("" + source + " should have dispatched signal " + signal, function() {
              return expect(global.currentResults[signal]).toBeDefined();
            });
          },
          started: function() {
            return it("" + source + " should have started", function() {
              return expect(this[source].running).toBeTruthy();
            });
          }
        };
      }
    };
  };

  global.timer = function(source) {
    return {
      duration: testProperty(source, 'duration'),
      since: testProperty(source, 'since'),
      time: testProperty(source, 'time'),
      nextTime: testProperty(source, 'nextTime'),
      should: {
        not: {
          beFinished: function() {
            return it('should not be finished yet', function() {
              return expect(this[source].finished()).toBeFalsy();
            });
          }
        },
        beFinished: function() {
          return it('should be finished', function() {
            return expect(this[source].finished()).toBeTruthy();
          });
        }
      }
    };
  };

  describe('a class without parent', function() {
    return describe('with many mixin included', function() {
      beforeEach(function() {
        var Dummy, MixinA, MixinB;
        MixinA = (function() {
          function MixinA() {}

          MixinA.prototype.get = function() {
            return 'mixin A get';
          };

          return MixinA;

        })();
        MixinB = (function() {
          function MixinB() {}

          MixinB.prototype.get = function() {
            return this["super"]() + ', mixin B get';
          };

          return MixinB;

        })();
        Dummy = (function() {
          function Dummy() {}

          Dummy.include(MixinA);

          Dummy.include(MixinB);

          Dummy.prototype.get = function() {
            return this["super"]() + ', dummy get';
          };

          return Dummy;

        })();
        return this.instance = new Dummy;
      });
      return it('calls the mixins super method in order', function() {
        return expect(this.instance.get()).toEqual('mixin A get, mixin B get, dummy get');
      });
    });
  });

  describe('a class with a parent', function() {
    describe('with no mixins', function() {
      beforeEach(function() {
        var AncestorClass, Dummy;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.prototype.get = function() {
            return 'ancestor get';
          };

          return AncestorClass;

        })();
        Dummy = (function(_super) {
          __extends(Dummy, _super);

          function Dummy() {
            return Dummy.__super__.constructor.apply(this, arguments);
          }

          Dummy.prototype.get = function() {
            return this["super"]() + ', child get';
          };

          return Dummy;

        })(AncestorClass);
        return this.instance = new Dummy;
      });
      return it('calls the ancestor method', function() {
        return expect(this.instance.get()).toEqual('ancestor get, child get');
      });
    });
    describe('with several mixins', function() {
      beforeEach(function() {
        var AncestorClass, ChildClassA, ChildClassB, MixinA, MixinB;
        this.ancestorClass = AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.prototype.get = function() {
            return 'ancestor get';
          };

          return AncestorClass;

        })();
        this.mixinA = MixinA = (function() {
          function MixinA() {}

          MixinA.prototype.get = function() {
            return this["super"]() + ', mixin A get';
          };

          return MixinA;

        })();
        this.mixinB = MixinB = (function() {
          function MixinB() {}

          MixinB.prototype.get = function() {
            return this["super"]() + ', mixin B get';
          };

          return MixinB;

        })();
        ChildClassA = (function(_super) {
          __extends(ChildClassA, _super);

          function ChildClassA() {
            return ChildClassA.__super__.constructor.apply(this, arguments);
          }

          ChildClassA.include(MixinA);

          ChildClassA.include(MixinB);

          ChildClassA.prototype.get = function() {
            return this["super"]() + ', child get';
          };

          return ChildClassA;

        })(AncestorClass);
        ChildClassB = (function(_super) {
          __extends(ChildClassB, _super);

          function ChildClassB() {
            return ChildClassB.__super__.constructor.apply(this, arguments);
          }

          ChildClassB.include(MixinB);

          ChildClassB.include(MixinA);

          return ChildClassB;

        })(AncestorClass);
        this.instanceA = new ChildClassA;
        return this.instanceB = new ChildClassB;
      });
      describe('that overrides the mixin method', function() {
        return it('calls the child and mixins methods up to the ancestor', function() {
          return expect(this.instanceA.get()).toEqual('ancestor get, mixin A get, mixin B get, child get');
        });
      });
      describe('that do not overrides the mixin method', function() {
        return it('calls the last mixin method and up to the ancestor class', function() {
          return expect(this.instanceB.get()).toEqual('ancestor get, mixin B get, mixin A get');
        });
      });
      describe('when a mixin was included more than once', function() {
        return it('does not mix up the mixin hierarchy', function() {
          expect(this.instanceA.get()).toEqual('ancestor get, mixin A get, mixin B get, child get');
          return expect(this.instanceB.get()).toEqual('ancestor get, mixin B get, mixin A get');
        });
      });
      return describe('calling this.super in a child method without super', function() {
        beforeEach(function() {
          var ChildClass, ancestor, mixinA;
          ancestor = this.ancestorClass;
          mixinA = this.mixinA;
          ChildClass = (function(_super) {
            __extends(ChildClass, _super);

            function ChildClass() {
              return ChildClass.__super__.constructor.apply(this, arguments);
            }

            ChildClass.include(mixinA);

            ChildClass.prototype.foo = function() {
              return this["super"]();
            };

            return ChildClass;

          })(ancestor);
          return this.instance = new ChildClass;
        });
        return it('raises an exception', function() {
          return expect(function() {
            return this.instance.foo();
          }).toThrow();
        });
      });
    });
    describe('that have a virtual property', function() {
      beforeEach(function() {
        var AncestorClass, Mixin, TestClass;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.accessor('foo', {
            get: function() {
              return this.__foo;
            },
            set: function(value) {
              return this.__foo = value;
            }
          });

          return AncestorClass;

        })();
        Mixin = (function() {
          function Mixin() {}

          Mixin.accessor('foo', {
            get: function() {
              return this["super"]() + ', in mixin';
            },
            set: function(value) {
              return this["super"](value);
            }
          });

          return Mixin;

        })();
        TestClass = (function(_super) {
          __extends(TestClass, _super);

          function TestClass() {
            return TestClass.__super__.constructor.apply(this, arguments);
          }

          TestClass.include(Mixin);

          TestClass.accessor('foo', {
            get: function() {
              return this["super"]() + ', in child class';
            },
            set: function(value) {
              return this["super"](value);
            }
          });

          return TestClass;

        })(AncestorClass);
        this.instance = new TestClass;
        return this.instance.foo = 'bar';
      });
      return it('calls the corresponding super accessor method', function() {
        return expect(this.instance.foo).toEqual('bar, in mixin, in child class');
      });
    });
    describe('that have a partially defined virtual property', function() {
      beforeEach(function() {
        var AncestorClass, Mixin, TestClass;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.accessor('foo', {
            set: function(value) {
              return this.__foo = value;
            }
          });

          return AncestorClass;

        })();
        Mixin = (function() {
          function Mixin() {}

          Mixin.accessor('foo', {
            get: function() {
              return this.__foo + ', in mixin';
            }
          });

          return Mixin;

        })();
        TestClass = (function(_super) {
          __extends(TestClass, _super);

          function TestClass() {
            return TestClass.__super__.constructor.apply(this, arguments);
          }

          TestClass.include(Mixin);

          TestClass.accessor('foo', {
            get: function() {
              return this["super"]() + ', in child class';
            },
            set: function(value) {
              return this["super"](value);
            }
          });

          return TestClass;

        })(AncestorClass);
        this.instance = new TestClass;
        return this.instance.foo = 'bar';
      });
      return it('creates a new accessor mixing the parent setter and the mixed getter', function() {
        return expect(this.instance.foo).toEqual('bar, in mixin, in child class');
      });
    });
    return describe('and a mixin with a class method override', function() {
      beforeEach(function() {
        var AncestorClass, MixinA, MixinB;
        AncestorClass = (function() {
          function AncestorClass() {}

          AncestorClass.get = function() {
            return 'bar';
          };

          return AncestorClass;

        })();
        MixinA = (function() {
          function MixinA() {}

          MixinA.get = function() {
            return this["super"]() + ', in mixin A get';
          };

          return MixinA;

        })();
        MixinB = (function() {
          function MixinB() {}

          MixinB.get = function() {
            return this["super"]() + ', in mixin B get';
          };

          return MixinB;

        })();
        return this.TestClass = (function(_super) {
          __extends(TestClass, _super);

          function TestClass() {
            return TestClass.__super__.constructor.apply(this, arguments);
          }

          TestClass.extend(MixinA);

          TestClass.extend(MixinB);

          TestClass.get = function() {
            return this["super"]() + ', in child get';
          };

          return TestClass;

        })(AncestorClass);
      });
      return it('calls the super class method from mixins up to the ancestor class', function() {
        return expect(this.TestClass.get()).toEqual('bar, in mixin A get, in mixin B get, in child get');
      });
    });
  });

  describe('Circle', function() {
    beforeEach(function() {
      addPointMatchers(this);
      addRectangleMatchers(this);
      return addCircleMatchers(this);
    });
    return eachPair(circleFactories, function(k, v) {
      var args, data, radius, segments, source, test, x, y;
      args = v.args, test = v.test;
      radius = test[0], x = test[1], y = test[2], segments = test[3];
      source = 'circle';
      data = circleData.apply(global, test);
      return describe("when instanciated with " + k + " " + args, function() {
        beforeEach(function() {
          return this.circle = circle.apply(null, args);
        });
        it('exists', function() {
          return expect(this.circle).toBeDefined();
        });
        it('has defined the ad hoc properties', function() {
          return expect(this.circle).toBeCircle(radius, x, y, segments);
        });
        describe('its center method', function() {
          return it('returns the circle coordinates', function() {
            return expect(this.circle.center()).toBePoint(this.circle.x, this.circle.y);
          });
        });
        lengthOf(source).shouldBe(data.length);
        describe('its pathPointAt method', function() {
          describe('called with 0', function() {
            return it("returns " + data.right + "," + data.y, function() {
              return expect(this.circle.pathPointAt(0)).toBePoint(data.right, data.y);
            });
          });
          describe('called with 1', function() {
            return it("returns " + data.right + "," + data.y, function() {
              return expect(this.circle.pathPointAt(1)).toBePoint(data.right, data.y);
            });
          });
          describe('called with 0.25', function() {
            return it("returns " + data.x + "," + data.bottom, function() {
              return expect(this.circle.pathPointAt(0.25)).toBePoint(data.x, data.bottom);
            });
          });
          describe('called with 0.5', function() {
            return it("returns " + data.left + "," + data.y, function() {
              return expect(this.circle.pathPointAt(0.5)).toBePoint(data.left, data.y);
            });
          });
          return describe('called with 0.75', function() {
            return it("returns " + data.x + "," + data.top, function() {
              return expect(this.circle.pathPointAt(0.75)).toBePoint(data.x, data.top);
            });
          });
        });
        describe('its pathOrientationAt method', function() {
          describe('called with 0', function() {
            return it('returns Math.PI / 2', function() {
              return expect(this.circle.pathOrientationAt(0)).toBeClose(Math.PI / 2);
            });
          });
          describe('called with 1', function() {
            return it('returns Math.PI / 2', function() {
              return expect(this.circle.pathOrientationAt(1)).toBeClose(Math.PI / 2);
            });
          });
          describe('called with 0.25', function() {
            return it('returns Math.PI', function() {
              return expect(this.circle.pathOrientationAt(0.25)).toBeClose(Math.PI);
            });
          });
          describe('called with 0.5', function() {
            return it('returns -Math.PI / 2', function() {
              return expect(this.circle.pathOrientationAt(0.5)).toBeClose(-Math.PI / 2);
            });
          });
          return describe('called with 0.75', function() {
            return it('returns 0', function() {
              return expect(this.circle.pathOrientationAt(0.75)).toBe(0);
            });
          });
        });
        acreageOf(source).shouldBe(data.acreage);
        describe('its contains method', function() {
          calledWithPoints(data.x, data.y).where({
            source: source,
            method: 'contains'
          }).should('returns true', function(res) {
            return expect(res).toBeTruthy();
          });
          return calledWithPoints(-100, -100).where({
            source: source,
            method: 'contains'
          }).should('returns false', function(res) {
            return expect(res).toBeFalsy();
          });
        });
        describe('its top method', function() {
          return it('returnss the circle top', function() {
            return expect(this.circle.top()).toEqual(data.top);
          });
        });
        describe('its bottom method', function() {
          return it('returnss the circle bottom', function() {
            return expect(this.circle.bottom()).toEqual(data.bottom);
          });
        });
        describe('its left method', function() {
          return it('returnss the circle left', function() {
            return expect(this.circle.left()).toEqual(data.left);
          });
        });
        describe('its right method', function() {
          return it('returnss the circle right', function() {
            return expect(this.circle.right()).toEqual(data.right);
          });
        });
        describe('its bounds method', function() {
          return it('returnss the circle bounds', function() {
            return expect(this.circle.bounds()).toEqual(data.bounds);
          });
        });
        geometry(source).shouldBe.closedGeometry();
        geometry(source).shouldBe.translatable();
        geometry(source).shouldBe.scalable();
        testDrawingOf(source);
        describe('its equals method', function() {
          describe('when called with an object equal to the current circle', function() {
            return it('returns true', function() {
              var target;
              target = circle.apply(global, args);
              return expect(this.circle.equals(target)).toBeTruthy();
            });
          });
          return describe('when called with an object different than the circle', function() {
            return it('returns false', function() {
              var target;
              target = circle(5, 1, 3);
              return expect(this.circle.equals(target)).toBeFalsy();
            });
          });
        });
        return describe('its clone method', function() {
          return it('returns a copy of this circle', function() {
            return expect(this.circle.clone()).toBeCircle(this.circle.radius, this.circle.x, this.circle.y, this.circle.segments);
          });
        });
      });
    });
  });

  describe('CubicBezier', function() {
    describe('when called with four vertices', function() {
      var source;
      source = 'curve';
      beforeEach(function() {
        addPointMatchers(this);
        return this.curve = new agt.geom.CubicBezier([point(0, 0), point(4, 0), point(4, 4), point(0, 4)], 20);
      });
      spline(source).shouldBe.cloneable();
      spline(source).shouldBe.formattable('CubicBezier');
      spline(source).shouldBe.sourcable('agt.geom.CubicBezier');
      spline(source).shouldHave(4).vertices();
      spline(source).shouldHave(1).segments();
      spline(source).shouldHave(21).points();
      spline(source).segmentSize.shouldBe(3);
      spline(source).bias.shouldBe(20);
      spline(source).shouldValidateWith(4).vertices();
      geometry(source).shouldBe.openGeometry();
      geometry(source).shouldBe.translatable();
      geometry(source).shouldBe.rotatable();
      return geometry(source).shouldBe.scalable();
    });
    testPathMethodsOf(agt.geom.CubicBezier);
    return testIntersectionsMethodsOf(agt.geom.CubicBezier);
  });

  describe('Diamond', function() {
    beforeEach(function() {
      return addDiamondMatchers(this);
    });
    return eachPair(diamondFactories, function(k, v) {
      var args, bottomLength, data, leftLength, rightLength, rotation, source, test, topLength, x, y;
      args = v.args, test = v.test;
      topLength = test[0], rightLength = test[1], bottomLength = test[2], leftLength = test[3], x = test[4], y = test[5], rotation = test[6];
      data = diamondData.apply(global, test);
      source = 'diamond';
      return describe("when instanciated " + k + " " + args, function() {
        beforeEach(function() {
          return this.diamond = diamond.apply(global, args);
        });
        it('has set the ad hoc properties', function() {
          return expect(this.diamond).toBeDiamond(topLength, rightLength, bottomLength, leftLength, x, y, rotation);
        });
        describe('its clone method', function() {
          return it('returns a copy of the diamond', function() {
            return expect(this.diamond.clone()).toEqual(this.diamond);
          });
        });
        describe('its equals method', function() {
          describe('with an object equals to the diamond', function() {
            return it('returns true', function() {
              return expect(this.diamond.clone().equals(this.diamond)).toBeTruthy();
            });
          });
          return describe('with an object not equals to the diamond', function() {
            return it('returns false', function() {
              return expect(diamond(0, 0, 0, 0, 0, 0, 0).equals(this.diamond)).toBeFalsy();
            });
          });
        });
        pointOf(source, 'center').shouldBe(data.center);
        pointOf(source, 'topCorner').shouldBe(data.topCorner);
        pointOf(source, 'bottomCorner').shouldBe(data.bottomCorner);
        pointOf(source, 'leftCorner').shouldBe(data.leftCorner);
        pointOf(source, 'rightCorner').shouldBe(data.rightCorner);
        pointOf(source, 'topLeftEdge').shouldBe(data.topLeftEdge);
        pointOf(source, 'topRightEdge').shouldBe(data.topRightEdge);
        pointOf(source, 'bottomRightEdge').shouldBe(data.bottomRightEdge);
        pointOf(source, 'bottomLeftEdge').shouldBe(data.bottomLeftEdge);
        describe('its topLeftQuadrant method', function() {
          return it('returns a triangle', function() {
            var quad;
            quad = this.diamond.topLeftQuadrant();
            expect(quad.a).toBeSamePoint(data.topLeftQuadrant.a);
            expect(quad.b).toBeSamePoint(data.topLeftQuadrant.b);
            return expect(quad.c).toBeSamePoint(data.topLeftQuadrant.c);
          });
        });
        describe('its topRightQuadrant method', function() {
          return it('returns a triangle', function() {
            var quad;
            quad = this.diamond.topRightQuadrant();
            expect(quad.a).toBeSamePoint(data.topRightQuadrant.a);
            expect(quad.b).toBeSamePoint(data.topRightQuadrant.b);
            return expect(quad.c).toBeSamePoint(data.topRightQuadrant.c);
          });
        });
        describe('its bottomLeftQuadrant method', function() {
          return it('returns a triangle', function() {
            var quad;
            quad = this.diamond.bottomLeftQuadrant();
            expect(quad.a).toBeSamePoint(data.bottomLeftQuadrant.a);
            expect(quad.b).toBeSamePoint(data.bottomLeftQuadrant.b);
            return expect(quad.c).toBeSamePoint(data.bottomLeftQuadrant.c);
          });
        });
        describe('its bottomRightQuadrant method', function() {
          return it('returns a triangle', function() {
            var quad;
            quad = this.diamond.bottomRightQuadrant();
            expect(quad.a).toBeSamePoint(data.bottomRightQuadrant.a);
            expect(quad.b).toBeSamePoint(data.bottomRightQuadrant.b);
            return expect(quad.c).toBeSamePoint(data.bottomRightQuadrant.c);
          });
        });
        lengthOf(source).shouldBe(data.length);
        acreageOf(source).shouldBe(data.acreage);
        describe('its contains method', function() {
          describe('with a point inside', function() {
            return it('returns true', function() {
              return expect(this.diamond.contains(this.diamond.center())).toBeTruthy();
            });
          });
          return describe('with a point outside', function() {
            return it('returns false', function() {
              return expect(this.diamond.contains(-10, -10)).toBeFalsy();
            });
          });
        });
        geometry(source).shouldBe.closedGeometry();
        geometry(source).shouldBe.translatable();
        geometry(source).shouldBe.rotatable();
        geometry(source).shouldBe.scalable();
        describe('its top method', function() {
          return it('returnss the diamond top', function() {
            return expect(this.diamond.top()).toBeClose(data.top);
          });
        });
        describe('its bottom method', function() {
          return it('returnss the diamond bottom', function() {
            return expect(this.diamond.bottom()).toBeClose(data.bottom);
          });
        });
        describe('its left method', function() {
          return it('returnss the diamond left', function() {
            return expect(this.diamond.left()).toBeClose(data.left);
          });
        });
        describe('its right method', function() {
          return it('returnss the diamond right', function() {
            return expect(this.diamond.right()).toBeClose(data.right);
          });
        });
        describe('its bounds method', function() {
          return it('returnss the diamond bounds', function() {
            return expect(this.diamond.bounds()).toEqual(data.bounds);
          });
        });
        return testDrawingOf(source);
      });
    });
  });

  describe('Ellipsis', function() {
    beforeEach(function() {
      addPointMatchers(this);
      addRectangleMatchers(this);
      return addEllipsisMatchers(this);
    });
    return eachPair(ellipsisFactories, function(k, v) {
      var args, data, radius1, radius2, rotation, segments, source, test, x, y;
      args = v.args, test = v.test;
      radius1 = test[0], radius2 = test[1], x = test[2], y = test[3], rotation = test[4], segments = test[5];
      source = 'ellipsis';
      data = ellipsisData.apply(global, test);
      return describe("when instanciated with " + k + " " + args, function() {
        beforeEach(function() {
          return this.ellipsis = ellipsis.apply(global, args);
        });
        it('exists', function() {
          return expect(this.ellipsis).toBeDefined();
        });
        it('has defined the ad hoc properties', function() {
          return expect(this.ellipsis).toBeEllipsis(radius1, radius2, x, y, rotation, segments);
        });
        describe('its center method', function() {
          return it('returns the ellipsis coordinates', function() {
            return expect(this.ellipsis.center()).toBePoint(this.ellipsis.x, this.ellipsis.y);
          });
        });
        lengthOf(source).shouldBe(data.length);
        acreageOf(source).shouldBe(data.acreage);
        describe('its contains method', function() {
          calledWithPoints(data.x, data.y).where({
            source: 'ellipsis',
            method: 'contains'
          }).should('returns true', function(res) {
            return expect(res).toBeTruthy();
          });
          return calledWithPoints(-100, -100).where({
            source: 'ellipsis',
            method: 'contains'
          }).should('returns false', function(res) {
            return expect(res).toBeFalsy();
          });
        });
        geometry(source).shouldBe.closedGeometry();
        geometry(source).shouldBe.translatable();
        geometry(source).shouldBe.rotatable();
        geometry(source).shouldBe.scalable();
        describe('its top method', function() {
          return it('returnss the ellipsis top', function() {
            return expect(this.ellipsis.top()).toBeClose(data.top);
          });
        });
        describe('its bottom method', function() {
          return it('returnss the ellipsis bottom', function() {
            return expect(this.ellipsis.bottom()).toBeClose(data.bottom);
          });
        });
        describe('its left method', function() {
          return it('returnss the ellipsis left', function() {
            return expect(this.ellipsis.left()).toBeClose(data.left);
          });
        });
        describe('its right method', function() {
          return it('returnss the ellipsis right', function() {
            return expect(this.ellipsis.right()).toBeClose(data.right);
          });
        });
        describe('its bounds method', function() {
          return it('returnss the ellipsis bounds', function() {
            return expect(this.ellipsis.bounds()).toEqual(data.bounds);
          });
        });
        testDrawingOf(source);
        describe('its equals method', function() {
          describe('when called with an object equal to the current ellipsis', function() {
            return it('returns true', function() {
              var target;
              target = ellipsis.apply(global, args);
              return expect(this.ellipsis.equals(target)).toBeTruthy();
            });
          });
          return describe('when called with an object different than the ellipsis', function() {
            return it('returns false', function() {
              var target;
              target = ellipsis(4, 5, 1, 3);
              return expect(this.ellipsis.equals(target)).toBeFalsy();
            });
          });
        });
        return describe('its clone method', function() {
          return it('returns a copy of this ellipsis', function() {
            return expect(this.ellipsis.clone()).toBeEllipsis(this.ellipsis.radius1, this.ellipsis.radius2, this.ellipsis.x, this.ellipsis.y, this.ellipsis.rotation, this.ellipsis.segments);
          });
        });
      });
    });
  });

  describe('Intersections between', function() {
    beforeEach(function() {
      return addPointMatchers(this);
    });
    describe('Rectangle and Rectangle', function() {
      describe('that overlap', function() {
        return it('returns two points', function() {
          var intersections, rect1, rect2;
          rect1 = rectangle(0, 0, 4, 4);
          rect2 = rectangle(2, 2, 4, 4);
          intersections = rect1.intersections(rect2);
          expect(intersections.length).toBe(2);
          expect(intersections[0]).toBePoint(4, 2);
          return expect(intersections[1]).toBePoint(2, 4);
        });
      });
      return describe('that are equals', function() {
        return it('returns 4 points', function() {
          var intersections, rect1, rect2;
          rect1 = rectangle(0, 0, 4, 4);
          rect2 = rectangle(0, 0, 4, 4);
          intersections = rect1.intersections(rect2);
          return expect(intersections).toEqual(rect1.points());
        });
      });
    });
    describe('Rectangle and Circle', function() {
      beforeEach(function() {
        this.rect = rectangle(0, 0, 4, 4);
        return this.circ = circle(2, 0, 0);
      });
      it('returns two points', function() {
        var intersections;
        intersections = this.rect.intersections(this.circ);
        expect(intersections.length).toBe(2);
        expect(intersections[0]).toBePoint(2, 0);
        return expect(intersections[1]).toBePoint(0, 2);
      });
      return it('returns two points', function() {
        var intersections;
        intersections = this.circ.intersections(this.rect);
        expect(intersections.length).toBe(2);
        expect(intersections[0]).toBePoint(2, 0);
        return expect(intersections[1]).toBePoint(0, 2);
      });
    });
    return describe('Circle and Circle', function() {
      describe('that are spaced by the sum of their radii', function() {
        return it('returns one point', function() {
          var circ1, circ2, intersections;
          circ1 = circle(4, 0, 0);
          circ2 = circle(6, 10, 0);
          intersections = circ1.intersections(circ2);
          expect(intersections.length).toBe(1);
          return expect(intersections[0]).toBePoint(4, 0);
        });
      });
      describe('that are spaced by less than the sum of their radii', function() {
        return it('returns two points', function() {
          var circ1, circ2, h, intersections;
          circ1 = circle(4, 0, 0);
          circ2 = circle(6, 8, 0);
          intersections = circ1.intersections(circ2);
          expect(intersections.length).toBe(2);
          h = 2.9047375096555625;
          expect(intersections[0]).toBePoint(2.75, -h);
          return expect(intersections[1]).toBePoint(2.75, h);
        });
      });
      describe('that are equals', function() {
        return it('returns the geometry points', function() {
          var circ1, circ2, intersections;
          circ1 = circle(4, 0, 0);
          circ2 = circle(4, 0, 0);
          intersections = circ1.intersections(circ2);
          expect(intersections.length).toBe(circ1.points().length);
          return expect(intersections).toEqual(circ1.points());
        });
      });
      return describe('that does not intersects', function() {
        return it('returns null', function() {
          var circ1, circ2, intersections;
          circ1 = circle(4, 0, 0);
          circ2 = circle(4, 10, 0);
          intersections = circ1.intersections(circ2);
          return expect(intersections).toBeNull();
        });
      });
    });
  });

  describe('LinearSpline', function() {
    describe('when instanciated with one point', function() {
      return it('throws an error', function() {
        return expect(function() {
          return new agt.geom.LinearSpline([point()]);
        }).toThrow();
      });
    });
    describe('when instanciated with four points', function() {
      var source;
      source = 'spline';
      beforeEach(function() {
        addPointMatchers(this);
        return this.spline = new agt.geom.LinearSpline([point(0, 3), point(3, 3), point(3, 0), point(6, 0)]);
      });
      it('has registered the points as its vertices', function() {
        expect(this.spline.vertices[0]).toBePoint(0, 3);
        expect(this.spline.vertices[1]).toBePoint(3, 3);
        expect(this.spline.vertices[2]).toBePoint(3, 0);
        return expect(this.spline.vertices[3]).toBePoint(6, 0);
      });
      spline(source).shouldBe.cloneable();
      spline(source).shouldBe.formattable('LinearSpline');
      spline(source).shouldBe.sourcable('agt.geom.LinearSpline');
      spline(source).shouldHave(4).vertices();
      spline(source).shouldHave(3).segments();
      spline(source).shouldHave(4).points();
      spline(source).segmentSize.shouldBe(1);
      spline(source).bias.shouldBe(20);
      spline(source).shouldValidateWith(2).vertices();
      lengthOf(source).shouldBe(9);
      geometry(source).shouldBe.openGeometry();
      geometry(source).shouldBe.translatable();
      geometry(source).shouldBe.rotatable();
      return geometry(source).shouldBe.scalable();
    });
    testPathMethodsOf(agt.geom.LinearSpline);
    return testIntersectionsMethodsOf(agt.geom.LinearSpline);
  });

  describe('Matrix', function() {
    beforeEach(function() {
      addMatrixMatchers(this);
      return addPointMatchers(this);
    });
    describe('when instanciated', function() {
      describe('without arguments', function() {
        return it('initializes an identity matrix', function() {
          return expect(matrix.identity()).toBeIdentity();
        });
      });
      describe('with another matrix', function() {
        return it('initializes the matrix in the same state as the arguments', function() {
          var m1, m2;
          m1 = matrix.transformed();
          m2 = matrix(m1);
          return expect(m2).toBeSameMatrix(m1);
        });
      });
      describe('with an object that is not a matrix', function() {
        return it('throws an error', function() {
          return expect(function() {
            return matrix({});
          }).toThrow();
        });
      });
      return describe('with null', function() {
        return it('initializes an identity matrix', function() {
          return expect(matrix(null)).toBeIdentity();
        });
      });
    });
    describe('::clone called', function() {
      return it('returns a copy of the matrix', function() {
        return expect(matrix.transformed().clone()).toBeSameMatrix(matrix.transformed());
      });
    });
    describe('::equals called', function() {
      return describe('with a matrix', function() {
        describe('equal to the current matrix', function() {
          return it('returns true', function() {
            return expect(matrix().equals(matrix())).toBeTruthy();
          });
        });
        return describe('not equal to the current matrix', function() {
          return it('returns false', function() {
            return expect(matrix().equals(matrix.transformed())).toBeFalsy();
          });
        });
      });
    });
    describe('::inverse called', function() {
      beforeEach(function() {
        this.m1 = matrix.transformed();
        this.m2 = this.m1.inverse();
        return this.m3 = matrix.inverted();
      });
      it('inverses the matrix transformation', function() {
        return expect(this.m1).toBeSameMatrix(this.m3);
      });
      return it('returns this instance', function() {
        return expect(this.m1).toBe(this.m2);
      });
    });
    describe('::identity called', function() {
      beforeEach(function() {
        this.m1 = matrix.transformed();
        return this.m2 = this.m1.identity();
      });
      it('resets the matrix to an identity matrix', function() {
        return expect(this.m1).toBeIdentity();
      });
      return it('returns this instance', function() {
        return expect(this.m1).toBe(this.m2);
      });
    });
    describe('::translate', function() {
      beforeEach(function() {
        this.matrix = matrix.transformed();
        return this.translated = matrix.translated();
      });
      calledWithPoints(-2, 2).where({
        source: 'matrix',
        method: 'translate'
      }).should('translates the matrix', function(result) {
        return expect(result).toBeSameMatrix(this.translated);
      });
      return describe('without arguments', function() {
        return it('does not modify the matrix', function() {
          return expect(matrix.identity().translate()).toBeIdentity();
        });
      });
    });
    describe('::scale called', function() {
      beforeEach(function() {
        this.matrix = matrix.transformed();
        return this.scaled = matrix.scaled();
      });
      calledWithPoints(0.5, 2).where({
        source: 'matrix',
        method: 'scale'
      }).should('scales the matrix', function(result) {
        return expect(result).toBeSameMatrix(this.scaled);
      });
      return describe('without arguments', function() {
        return it('does not modify the matrix', function() {
          return expect(matrix.identity().scale()).toBeIdentity();
        });
      });
    });
    describe('::rotate called', function() {
      beforeEach(function() {
        this.m1 = matrix.transformed();
        this.m2 = this.m1.rotate(72);
        return this.m3 = matrix.rotated();
      });
      it('rotates the matrix', function() {
        return expect(this.m1).toBeSameMatrix(this.m3);
      });
      it('returns this instance', function() {
        return expect(this.m1).toBe(this.m2);
      });
      return describe('without arguments', function() {
        return it('does not modify the matrix', function() {
          return expect(matrix.identity().rotate()).toBeIdentity();
        });
      });
    });
    describe('::append called', function() {
      beforeEach(function() {
        this.m1 = matrix.transformed();
        this.m2 = this.m1.append(6, 5, 4, 3, 2, 1);
        return this.m3 = matrix.appended();
      });
      it('appends the matrix', function() {
        return expect(this.m1).toBeSameMatrix(this.m3);
      });
      it('returns this instance', function() {
        return expect(this.m1).toBe(this.m2);
      });
      describe('without arguments', function() {
        return it('does not modify the matrix', function() {
          return expect(matrix.identity().append()).toBeIdentity();
        });
      });
      return describe('with a matrix', function() {
        return it('appends the matrix', function() {
          return expect(matrix.transformed().append(matrix(6, 5, 4, 3, 2, 1))).toBeSameMatrix(matrix.appended());
        });
      });
    });
    describe('::prepend called', function() {
      beforeEach(function() {
        this.m1 = matrix.transformed();
        this.m2 = this.m1.prepend(6, 5, 4, 3, 2, 1);
        return this.m3 = matrix.prepended();
      });
      it('prepends the matrix', function() {
        return expect(this.m1).toBeSameMatrix(this.m3);
      });
      it('returns this instance', function() {
        return expect(this.m1).toBe(this.m2);
      });
      describe('without arguments', function() {
        return it('does not modify the matrix', function() {
          return expect(matrix.identity().prepend()).toBeIdentity();
        });
      });
      describe('with a matrix', function() {
        return it('prepends the matrix', function() {
          return expect(matrix.transformed().prepend(matrix(6, 5, 4, 3, 2, 1))).toBeSameMatrix(matrix.prepended());
        });
      });
      return describe('with an identity matrix', function() {
        return it('does not modify the matrix', function() {
          return expect(matrix.transformed().prepend(matrix.identity())).toBeSameMatrix(matrix.transformed());
        });
      });
    });
    describe('::skew called', function() {
      beforeEach(function() {
        this.matrix = matrix.transformed();
        return this.skewed = matrix.skewed();
      });
      calledWithPoints(-2, 2).where({
        source: 'matrix',
        method: 'skew'
      }).should('skews the matrix', function(result) {
        return expect(result).toBeSameMatrix(this.skewed);
      });
      return describe('without arguments', function() {
        return it('does not modify the matrix', function() {
          return expect(matrix.transformed().skew()).toBeSameMatrix(matrix.transformed());
        });
      });
    });
    return describe('::transformPoint called', function() {
      beforeEach(function() {
        this.matrix = matrix();
        this.matrix.scale(2, 2);
        return this.matrix.rotate(Math.PI / 2);
      });
      describe('with a point', function() {
        return it('returns a new point resulting of the matrix transformations', function() {
          var origin, transformed;
          origin = point(10, 0);
          transformed = this.matrix.transformPoint(origin);
          return expect(transformed).toBePoint(0, 20);
        });
      });
      describe('with two numbers', function() {
        return it('returns a new point resulting of the matrix transformations', function() {
          var transformed;
          transformed = this.matrix.transformPoint(10, 0);
          return expect(transformed).toBePoint(0, 20);
        });
      });
      describe('with one number', function() {
        return it('throws an error', function() {
          return expect((function(_this) {
            return function() {
              return _this.matrix.transformPoint(10);
            };
          })(this)).toThrow();
        });
      });
      describe('without arguments', function() {
        return it('throws an error', function() {
          return expect((function(_this) {
            return function() {
              return _this.matrix.transformPoint();
            };
          })(this)).toThrow();
        });
      });
      return describe('with an incomplete point', function() {
        return it('throws an error', function() {
          return expect((function(_this) {
            return function() {
              return _this.matrix.transformPoint({
                x: 0
              });
            };
          })(this)).toThrow();
        });
      });
    });
  });

  Point = agt.geom.Point;

  describe('Point', function() {
    var leftUnchanged;
    beforeEach(function() {
      return addPointMatchers(this);
    });
    describe('after being instanciated', function() {
      describe('with two numbers as arguments', function() {
        return it('creates the new instance', function() {
          return expect(point(3, 8)).toBePoint(3, 8);
        });
      });
      describe('with two strings as arguments', function() {
        return it('creates the new instance', function() {
          return expect(point('3', '8')).toBePoint(3, 8);
        });
      });
      describe('with no arguments', function() {
        return it('creates the new instance with default coordinates of 0', function() {
          return expect(point()).toBePoint();
        });
      });
      describe('with another point-like object as argument', function() {
        return it('creates the new instance with the values of the object', function() {
          return expect(point({
            x: 10,
            y: 23
          })).toBePoint(10, 23);
        });
      });
      return describe('with an incomplete point-like object as argument', function() {
        return it('creates the new instance with the value of the object', function() {
          return expect(point({
            x: 10
          })).toBePoint(10, 0);
        });
      });
    });
    describe('::toSource called', function() {
      return it('returns the source code of the point', function() {
        return expect(point(2, 2).toSource()).toBe('new agt.geom.Point(2,2)');
      });
    });
    describe('::length called', function() {
      var length;
      describe('with a zero length point', function() {
        return it('returns 0', function() {
          return expect(point().length()).toBeClose(0);
        });
      });
      describe('with a point such (0,5)', function() {
        return it('returns 5', function() {
          return expect(point(0, 5).length()).toBeClose(5);
        });
      });
      length = Math.sqrt(7 * 7 + 5 * 5);
      describe('with a point such (7,5)', function() {
        return it("returns " + length, function() {
          return expect(point(7, 5).length()).toBeClose(length);
        });
      });
      return describe('with a point such (-7,-5)', function() {
        return it("returns " + length, function() {
          return expect(point(-7, -5).length()).toBeClose(length);
        });
      });
    });
    describe('::angle called', function() {
      describe('for a point with coordinates (10,0)', function() {
        return it('returns the angle in degrees of the current vector', function() {
          return expect(point(10, 0).angle()).toBe(0);
        });
      });
      describe('for a point with coordinates (5,5)', function() {
        return it('returns the angle in degrees of the current vector', function() {
          return expect(point(5, 5).angle()).toBeClose(Math.PI / 4);
        });
      });
      return describe('for a point with coordinates (0,10)', function() {
        return it('returns the angle in degrees of the current vector', function() {
          return expect(point(0, 10).angle()).toBeClose(Math.PI / 2);
        });
      });
    });
    describe('::equals called', function() {
      return describe('with a point-like object', function() {
        describe('that is equal to the current point', function() {
          return it('returns true', function() {
            return expect(point().equals(pointLike(0, 0))).toBeTruthy();
          });
        });
        return describe('that is not equal to the current point', function() {
          return it('returns false', function() {
            return expect(point().equals(pointLike(1, 1))).toBeFalsy();
          });
        });
      });
    });
    pointOperator('add')["with"](2, 3).and(4, 5).where({
      emptyArguments: 'copy',
      emptyObject: 'copy',
      partialObject: function(result) {
        return expect(result).toBePoint(6, 3);
      },
      nullArgument: 'copy',
      singleNumber: function(result) {
        return expect(result).toBePoint(6, 3);
      }
    }).should('returns a new point corresponding to the addition product', function(result) {
      return expect(result).toBePoint(6, 8);
    });
    pointOperator('subtract')["with"](6, 8).and(4, 5).where({
      emptyArguments: 'copy',
      emptyObject: 'copy',
      partialObject: function(result) {
        return expect(result).toBePoint(2, 8);
      },
      nullArgument: 'copy',
      singleNumber: function(result) {
        return expect(result).toBePoint(2, 8);
      }
    }).should('returns a new point corresponding to the subtract product', function(result) {
      return expect(result).toBePoint(2, 3);
    });
    pointOperator('dot')["with"](7, 3).and(4, 2).where({
      emptyArguments: 'throws',
      emptyObject: 'throws',
      partialObject: 'throws',
      nullArgument: 'throws',
      singleNumber: 'throws'
    }).should('returns the dot product of the current point and the point argument', function(result) {
      return expect(result).toBeClose(7 * 4 + 3 * 2);
    });
    pointOperator('distance')["with"](7, 3).and(4, 2).where({
      emptyArguments: 'throws',
      emptyObject: 'throws',
      partialObject: 'throws',
      nullArgument: 'throws',
      singleNumber: 'throws'
    }).should('returns the distance between the two points', function(result) {
      return expect(result).toBeClose(point(3, 1).length());
    });
    pointOperator('angleWith')["with"](10, 0).and(0, 10).where({
      emptyArguments: 'throws',
      emptyObject: 'throws',
      partialObject: 'throws',
      nullArgument: 'throws',
      singleNumber: 'throws'
    }).should('returns the angle formed by the two points', function(result) {
      return expect(result).toBeClose(Math.PI / 2);
    });
    leftUnchanged = function(result) {
      expect(result).toBePoint(7, 3);
      return expect(result).toBe(this.point);
    };
    pointOperator('paste')["with"](7, 3).and(4, 2).where({
      emptyArguments: leftUnchanged,
      emptyObject: leftUnchanged,
      partialObject: function(result) {
        return expect(result).toBePoint(4, 3);
      },
      nullArgument: leftUnchanged,
      singleNumber: function(result) {
        return expect(result).toBePoint(4, 3);
      }
    }).should('copy the data into this point', function(result) {
      expect(result).toBePoint(4, 2);
      return expect(result).toBeSamePoint(this.point);
    });
    describe('::rotate called', function() {
      describe('with a number', function() {
        it('returns a new point rotated around the origin', function() {
          var pt2;
          pt = point(10, 0);
          pt2 = pt.rotate(Math.PI / 2);
          return expect(pt2).toBePoint(0, 10);
        });
        return describe('not containing a number', function() {
          return it('throws an error', function() {
            return expect(function() {
              return point(10, 0).rotate('foo');
            }).toThrow();
          });
        });
      });
      describe('without argument', function() {
        return it('throws an error', function() {
          return expect(function() {
            return point(10, 0).rotate();
          }).toThrow();
        });
      });
      return describe('with null', function() {
        return it('throws an error', function() {
          return expect(function() {
            return point(10, 0).rotate(null);
          }).toThrow();
        });
      });
    });
    describe('::rotateAround called', function() {
      describe('with a point and a number', function() {
        return it('returns a new point rotated around the given point', function() {
          var pt1, pt2, pt3;
          pt1 = point(10, 0);
          pt2 = point(20, 0);
          pt3 = pt1.rotateAround(pt2, Math.PI / 2);
          return expect(pt3).toBePoint(20, -10);
        });
      });
      describe('with three numbers', function() {
        return it('returns a new point rotated around the given coordinates', function() {
          var pt1, pt2;
          pt1 = point(10, 0);
          pt2 = pt1.rotateAround(20, 0, Math.PI / 2);
          return expect(pt2).toBePoint(20, -10);
        });
      });
      describe('with two numbers', function() {
        return it('throws an error', function() {
          return expect(function() {
            return point(1, 2).rotateAround(10, 1);
          }).toThrow();
        });
      });
      return describe('with only a point', function() {
        return it('throws an error', function() {
          return expect(function() {
            return point(1, 2).rotateAround(point());
          }).toThrow();
        });
      });
    });
    describe('::scale called', function() {
      describe('with a number', function() {
        describe('that is positive', function() {
          return it('returns a new scaled point', function() {
            return expect(point(1, 2).scale(2)).toBePoint(2, 4);
          });
        });
        return describe('that is negative', function() {
          return it('returns a new scaled point with negative coordinates', function() {
            return expect(point(1, 2).scale(-2)).toBePoint(-2, -4);
          });
        });
      });
      return describe('without arguments', function() {
        return it('throws an error', function() {
          return expect(function() {
            return point(1, 2).scale();
          }).toThrow();
        });
      });
    });
    describe('::normalize called', function() {
      describe('on a point with a length of 0', function() {
        return it('returns a new point of length 0', function() {
          return expect(point(0, 0).normalize().length()).toBeClose(0);
        });
      });
      describe('without arguments', function() {
        beforeEach(function() {
          this.point1 = point(5, 6);
          return this.point2 = this.point1.normalize();
        });
        it('returns a new point of length 1', function() {
          return expect(this.point2.length()).toBeClose(1);
        });
        return it('returns a new point with the same direction', function() {
          return expect(this.point2.x / this.point2.y).toBeClose(this.point1.x / this.point1.y);
        });
      });
      describe('with null', function() {
        return it('returns a new point of length 1', function() {
          return expect(point(5, 6).normalize(null).length()).toBeClose(1);
        });
      });
      describe('with a number', function() {
        describe('that is positive', function() {
          beforeEach(function() {
            this.normalizedLength = 10.5;
            this.point1 = point(5, 6);
            return this.point2 = this.point1.normalize(this.normalizedLength);
          });
          it('returns a new point with length equal to the number', function() {
            return expect(this.point2.length()).toBeClose(this.normalizedLength);
          });
          return it('returns a new point with the same direction', function() {
            return expect(this.point2.x / this.point2.y).toBeClose(this.point1.x / this.point1.y);
          });
        });
        describe('that is negative', function() {
          beforeEach(function() {
            this.normalizedLength = -10.5;
            this.point1 = point(5, 6);
            return this.point2 = this.point1.normalize(this.normalizedLength);
          });
          it('returns a new point with length equal to the number', function() {
            return expect(this.point2.length()).toBeClose(Math.abs(this.normalizedLength));
          });
          return it('returns a new point with the same direction', function() {
            return expect(this.point2.x / this.point2.y).toBeClose(this.point1.x / this.point1.y);
          });
        });
        return describe('that is 0', function() {
          return it('returns a new point with length equal to 0', function() {
            return expect(point(5, 6).normalize(0).length()).toBeClose(0);
          });
        });
      });
      return describe('with an object', function() {
        return it('throws an error', function() {
          return expect(function() {
            return point(5, 6).normalize({});
          }).toThrow();
        });
      });
    });
    describe('::clone called', function() {
      return it('returns a copy of the point', function() {
        return expect(point(4.56, 0.1).clone()).toBePoint(4.56, 0.1);
      });
    });
    describe('.polar called', function() {
      describe('with an angle and a length', function() {
        return it('returns a point corresponding to the cartesian projection', function() {
          var angle, length, x, y;
          angle = 32;
          length = 10;
          pt = Point.polar(angle, length);
          x = length * Math.sin(angle);
          y = length * Math.cos(angle);
          return expect(pt).toBePoint(x, y);
        });
      });
      return describe('with only an angle', function() {
        return it('returns a point corresponding to the cartesian projection with a length of 1', function() {
          var angle, length, x, y;
          angle = 32;
          length = 1;
          pt = Point.polar(angle);
          x = length * Math.sin(angle);
          y = length * Math.cos(angle);
          return expect(pt).toBePoint(x, y);
        });
      });
    });
    return describe('.interpolate called', function() {
      describe('with two points and a float', function() {
        return it('returns a point between the two point arguments', function() {
          var p1, p2, p3, pos, xdif, ydif;
          p1 = point(4.5, 3.0);
          p2 = point(6.2, 0.1);
          pos = 0.7;
          p3 = Point.interpolate(p1, p2, pos);
          xdif = p2.x - p1.x;
          ydif = p2.y - p1.y;
          expect(p3.x).toBeClose(p1.x + xdif * pos);
          return expect(p3.y).toBeClose(p1.y + ydif * pos);
        });
      });
      describe('with five floats', function() {
        return it('returns a point between the two coordinates defined by the first four floats', function() {
          var pos, x1, x2, xdif, y1, y2, ydif;
          x1 = 4.5;
          y1 = 3.0;
          x2 = 6.2;
          y2 = 0.1;
          pos = 0.7;
          pt = Point.interpolate(x1, y1, x2, y2, pos);
          xdif = x2 - x1;
          ydif = y2 - y1;
          expect(pt.x).toBeClose(x1 + xdif * pos);
          return expect(pt.y).toBeClose(y1 + ydif * pos);
        });
      });
      return describe('with a point and three floats', function() {
        describe('with the point as first argument', function() {
          return it('returns a point between the point argument and the coordinates defined by the two first floats', function() {
            var p1, pos, x2, xdif, y2, ydif;
            p1 = point(4.5, 3.0);
            x2 = 6.2;
            y2 = 0.1;
            pos = 0.7;
            pt = Point.interpolate(p1, x2, y2, pos);
            xdif = x2 - p1.x;
            ydif = y2 - p1.y;
            expect(pt.x).toBeClose(p1.x + xdif * pos);
            return expect(pt.y).toBeClose(p1.y + ydif * pos);
          });
        });
        describe('with the point as third argument', function() {
          return it('returns a point between the point argument and the coordinates defined by the two first floats', function() {
            var p2, pos, x1, xdif, y1, ydif;
            x1 = 6.2;
            y1 = 0.1;
            p2 = point(4.5, 3.0);
            pos = 0.7;
            pt = Point.interpolate(x1, y1, p2, pos);
            xdif = p2.x - x1;
            ydif = p2.y - y1;
            expect(pt.x).toBeClose(x1 + xdif * pos);
            return expect(pt.y).toBeClose(y1 + ydif * pos);
          });
        });
        describe('with a float followed by a point', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate(1.1, point(), 2);
            }).toThrow();
          });
        });
        describe('with a point followed by only two floats', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate(point(), 2, 4);
            }).toThrow();
          });
        });
        describe('with a point followed by only one float', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate(point(), 2);
            }).toThrow();
          });
        });
        describe('with an invalid position', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate(point(), 2, 4, 'foo');
            }).toThrow();
          });
        });
        describe('with an invalid first point', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate('foo', 1, 2, 3, 0.7);
            }).toThrow();
          });
        });
        describe('with an invalid second point', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate(0, 1, 'foo', 3, 0.7);
            }).toThrow();
          });
        });
        describe('with a partial first point', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate({
                x: 10
              }, 2, 3, 0.7);
            }).toThrow();
          });
        });
        describe('with a partial second point', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate(0, 1, {
                x: 10
              }, 0.7);
            }).toThrow();
          });
        });
        return describe('with no arguments', function() {
          return it('throws an error', function() {
            return expect(function() {
              return Point.interpolate();
            }).toThrow();
          });
        });
      });
    });
  });

  describe('Polygon', function() {
    beforeEach(function() {
      return addPointMatchers(this);
    });
    describe('called without argument', function() {
      return it('throws an error', function() {
        return expect(function() {
          return polygon();
        }).toThrow();
      });
    });
    describe('with less than three points', function() {
      return it('throws an error', function() {
        return expect(function() {
          return polygon([point(), point()]);
        }).toThrow();
      });
    });
    return eachPair(polygonFactories, function(k, v) {
      var args, data, source, test;
      args = v.args, test = v.test;
      data = polygonData.call(global, test());
      source = 'polygon';
      return describe("called " + k, function() {
        beforeEach(function() {
          return this.polygon = polygon.apply(global, args());
        });
        it('exists', function() {
          return expect(this.polygon).toBeDefined();
        });
        it('has its vertices defined', function() {
          return expect(this.polygon.vertices).toEqual(test());
        });
        describe('its clone method', function() {
          return it('returns a copy of the polygon', function() {
            return expect(this.polygon.clone()).toEqual(this.polygon);
          });
        });
        describe('its toSource method', function() {
          return it('returns the code source of the polygon', function() {
            return expect(this.polygon.toSource()).toBe(data.source);
          });
        });
        describe('its points method', function() {
          return it('returns the vertices with the first being copy at last', function() {
            return expect(this.polygon.points()).toEqual(this.polygon.vertices.concat(this.polygon.vertices[0]));
          });
        });
        describe('its triangles method', function() {
          return it('returns two triangles', function() {
            return expect(this.polygon.triangles().length).toBe(2);
          });
        });
        describe('its contains method', function() {
          describe('with a point in the geometry', function() {
            return it('returns true', function() {
              return expect(this.polygon.contains(1, 2)).toBeTruthy();
            });
          });
          return describe('with a point off the geometry', function() {
            return it('returns false', function() {
              return expect(this.polygon.contains(-10, -10)).toBeFalsy();
            });
          });
        });
        describe('its rotateAroundCenter method', function() {
          return it('rotates the polygon', function() {
            var center, vertex, _i, _len, _ref, _results;
            center = this.polygon.center();
            this.polygon.rotateAroundCenter(10);
            _ref = this.polygon.vertices;
            _results = [];
            for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
              vertex = _ref[i];
              _results.push(expect(vertex).toBeSamePoint(data.vertices[i].rotateAround(center, 10)));
            }
            return _results;
          });
        });
        describe('its scaleAroundCenter method', function() {
          return it('scales the polygon', function() {
            var center, vertex, _i, _len, _ref, _results;
            center = this.polygon.center();
            this.polygon.scaleAroundCenter(2);
            _ref = this.polygon.vertices;
            _results = [];
            for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
              vertex = _ref[i];
              pt = center.add(data.vertices[i].subtract(center).scale(2));
              _results.push(expect(vertex).toBeSamePoint(pt));
            }
            return _results;
          });
        });
        acreageOf(source).shouldBe(16);
        lengthOf(source).shouldBe(16);
        geometry(source).shouldBe.closedGeometry();
        geometry(source).shouldBe.translatable();
        geometry(source).shouldBe.rotatable();
        geometry(source).shouldBe.scalable();
        return testDrawingOf(source);
      });
    });
  });

  describe('QuadBezier', function() {
    describe('when called with four vertices', function() {
      var source;
      source = 'curve';
      beforeEach(function() {
        addPointMatchers(this);
        return this.curve = new agt.geom.QuadBezier([point(0, 0), point(2, 2), point(4, 0)], 20);
      });
      spline(source).shouldBe.cloneable();
      spline(source).shouldBe.formattable('QuadBezier');
      spline(source).shouldBe.sourcable('agt.geom.QuadBezier');
      spline(source).shouldHave(3).vertices();
      spline(source).shouldHave(1).segments();
      spline(source).shouldHave(21).points();
      spline(source).segmentSize.shouldBe(2);
      spline(source).bias.shouldBe(20);
      spline(source).shouldValidateWith(3).vertices();
      geometry(source).shouldBe.openGeometry();
      geometry(source).shouldBe.translatable();
      geometry(source).shouldBe.rotatable();
      return geometry(source).shouldBe.scalable();
    });
    testPathMethodsOf(agt.geom.QuadBezier);
    return testIntersectionsMethodsOf(agt.geom.QuadBezier);
  });

  describe('QuintBezier', function() {
    describe('when called with four vertices', function() {
      var source;
      source = 'curve';
      beforeEach(function() {
        addPointMatchers(this);
        return this.curve = new agt.geom.QuintBezier([point(0, 0), point(2, 2), point(4, 0), point(6, 2), point(8, 0)], 20);
      });
      spline(source).shouldBe.cloneable();
      spline(source).shouldBe.formattable('QuintBezier');
      spline(source).shouldBe.sourcable('agt.geom.QuintBezier');
      spline(source).shouldHave(5).vertices();
      spline(source).shouldHave(1).segments();
      spline(source).shouldHave(21).points();
      spline(source).segmentSize.shouldBe(4);
      spline(source).bias.shouldBe(20);
      spline(source).shouldValidateWith(5).vertices();
      geometry(source).shouldBe.openGeometry();
      geometry(source).shouldBe.translatable();
      geometry(source).shouldBe.rotatable();
      return geometry(source).shouldBe.scalable();
    });
    testPathMethodsOf(agt.geom.QuintBezier);
    return testIntersectionsMethodsOf(agt.geom.QuintBezier);
  });

  Rectangle = agt.geom;

  describe('Rectangle', function() {
    var tests;
    beforeEach(function() {
      addRectangleMatchers(this);
      return addPointMatchers(this);
    });
    tests = {
      'with four numbers': {
        args: [1, 2, 3, 4],
        acreage: 12,
        length: 14,
        test: [1, 2, 3, 4, 0]
      },
      'with five numbers': {
        args: [4, 5, 6, 7, 8],
        acreage: 42,
        length: 26,
        test: [4, 5, 6, 7, 8]
      },
      'without arguments': {
        args: [],
        acreage: 0,
        length: 0,
        test: [0, 0, 0, 0, 0]
      },
      'with another rectangle': {
        args: [rectangle(1, 2, 3, 4, 5)],
        acreage: 12,
        length: 14,
        test: [1, 2, 3, 4, 5]
      },
      'with a partial rectangle like object': {
        args: [
          {
            x: 1,
            width: 3,
            height: 4
          }
        ],
        acreage: 12,
        length: 14,
        test: [1, 0, 3, 4, 0]
      }
    };
    describe('when instanciated', function() {
      eachPair(tests, function(msg, o) {
        var acreage, args, height, length, rotation, test, width, x, y;
        args = o.args, acreage = o.acreage, test = o.test, length = o.length;
        x = test[0], y = test[1], width = test[2], height = test[3], rotation = test[4];
        return describe("" + msg + " " + args, function() {
          var source;
          beforeEach(function() {
            this.rectangle = rectangle.apply(null, args);
            return this.data = rectangleData.apply(null, test);
          });
          source = 'rectangle';
          it('has been set with the provided values', function() {
            return expect(this.rectangle).toBeRectangle(x, y, width, height, rotation);
          });
          describe('its toSource method', function() {
            return it('returns the code source of the Rectangle', function() {
              return expect(this.rectangle.toSource()).toBe(this.data.source);
            });
          });
          testRotatedRectangle(source, x, y, width, height, rotation);
          proxyable(source).shouldDefine({
            corners: 'PointList',
            topLeft: 'Point',
            topRight: 'Point',
            bottomLeft: 'Point',
            bottomRight: 'Point',
            center: 'Point',
            topEdgeCenter: 'Point',
            bottomEdgeCenter: 'Point',
            leftEdgeCenter: 'Point',
            rightEdgeCenter: 'Point',
            edges: 'PointList',
            topEdge: 'Point',
            leftEdge: 'Point',
            bottomEdge: 'Point',
            rightEdge: 'Point',
            diagonal: 'Point',
            points: 'PointList',
            pathPointAt: 'Point',
            pathOrientationAt: 'Angle'
          }).asProxyable();
          describe('its setCenter method', function() {
            return calledWithPoints(1, 3, -5, 2, 5, -8, 0, 0).where({
              source: source,
              method: 'setCenter'
            }).should('has moved the rectangle and returned it', function(res, tx, ty) {
              var cx, cy, _ref, _ref1, _ref2;
              _ref = this.data.topLeft, x = _ref.x, y = _ref.y;
              _ref1 = this.data.center, cx = _ref1.x, cy = _ref1.y;
              _ref2 = [x + (tx - cx), y + (ty - cy)], x = _ref2[0], y = _ref2[1];
              expect(this.rectangle.topLeft()).toBePoint(x, y);
              return expect(res).toBe(this.rectangle);
            });
          });
          describe('its rotateAroundCenter method', function() {
            beforeEach(function() {
              this.rotation = 10;
              return this.result = this.rectangle.rotateAroundCenter(this.rotation);
            });
            it('rotates the rectangle around its center', function() {
              var target;
              target = point(this.data.topLeft).rotateAround(this.data.center, this.rotation);
              return expect(this.rectangle.topLeft()).toBeSamePoint(target);
            });
            it('should preserve the rectangle center', function() {
              return expect(this.rectangle.center()).toBeSamePoint(this.data.center);
            });
            return it('returns the rectangle', function() {
              return expect(this.result).toBe(this.rectangle);
            });
          });
          describe('its scaleAroundCenter method', function() {
            beforeEach(function() {
              this.scale = 2;
              return this.result = this.rectangle.scaleAroundCenter(this.scale);
            });
            it('scales the rectangle around its center', function() {
              var dif, target;
              dif = point(this.data.topLeft).subtract(this.data.center);
              dif = dif.scale(this.scale);
              target = point(this.data.topLeft).add(dif.scale(0.5));
              expect(this.rectangle.topLeft()).toBeSamePoint(target);
              expect(this.rectangle.width).toBe(width * this.scale);
              return expect(this.rectangle.height).toBe(height * this.scale);
            });
            it('should preserve the rectangle center', function() {
              return expect(this.rectangle.center()).toBeSamePoint(this.data.center);
            });
            return it('returns the rectangle', function() {
              return expect(this.result).toBe(this.rectangle);
            });
          });
          describe('its inflateAroundCenter method', function() {
            return calledWithPoints(1, 3, -5, 2, 5, -8, 0, 0).where({
              source: source,
              method: 'inflateAroundCenter'
            }).should('has inflate the rectangle and returned it', function(res, x, y) {
              expect(this.rectangle.width).toBe(width + x);
              expect(this.rectangle.height).toBe(height + y);
              expect(this.rectangle.center()).toBeSamePoint(this.data.center);
              return expect(res).toBe(this.rectangle);
            });
          });
          describe('its inflate method', function() {
            return calledWithPoints(1, 3, -5, 2, 5, -8, 0, 0).where({
              source: source,
              method: 'inflate'
            }).should('has inflate the rectangle and returned it', function(res, x, y) {
              expect(this.rectangle.width).toBe(width + x);
              expect(this.rectangle.height).toBe(height + y);
              expect(this.rectangle.topLeft()).toBeSamePoint(this.data.topLeft);
              return expect(res).toBe(this.rectangle);
            });
          });
          describe('its inflateTopLeft method', function() {
            return calledWithPoints(1, 3, -5, 2, 5, -8, 0, 0).where({
              source: source,
              method: 'inflateTopLeft'
            }).should('has inflate the rectangle and returned it', function(res, x, y) {
              var leftEdge, topEdge;
              topEdge = point(this.rectangle.topEdge()).normalize(-x);
              leftEdge = point(this.rectangle.leftEdge()).normalize(-y);
              expect(this.rectangle.width).toBe(width + x);
              expect(this.rectangle.height).toBe(height + y);
              expect(this.rectangle.topLeft()).toBeSamePoint(point(this.data.topLeft).add(topEdge).add(leftEdge));
              return expect(res).toBe(this.rectangle);
            });
          });
          describe('its inflateTopRight method', function() {
            return calledWithPoints(1, 3, -5, 2, 5, -8, 0, 0).where({
              source: source,
              method: 'inflateTopRight'
            }).should('has inflate the rectangle and returned it', function(res, x, y) {
              var leftEdge;
              leftEdge = point(this.rectangle.leftEdge()).normalize(-y);
              expect(this.rectangle.width).toBe(width + x);
              expect(this.rectangle.height).toBe(height + y);
              expect(this.rectangle.topLeft()).toBeSamePoint(point(this.data.topLeft).add(leftEdge));
              return expect(res).toBe(this.rectangle);
            });
          });
          describe('its inflateBottomLeft method', function() {
            return calledWithPoints(1, 3, -5, 2, 5, -8, 0, 0).where({
              source: source,
              method: 'inflateBottomLeft'
            }).should('has inflate the rectangle and returned it', function(res, x, y) {
              var topEdge;
              topEdge = point(this.rectangle.topEdge()).normalize(-x);
              expect(this.rectangle.width).toBe(width + x);
              expect(this.rectangle.height).toBe(height + y);
              expect(this.rectangle.topLeft()).toBeSamePoint(point(this.data.topLeft).add(topEdge));
              return expect(res).toBe(this.rectangle);
            });
          });
          describe('its inflateBottomRight method', function() {
            return calledWithPoints(1, 3, -5, 2, 5, -8, 0, 0).where({
              source: source,
              method: 'inflateBottomRight'
            }).should('has inflate the rectangle and returned it', function(res, x, y) {
              expect(this.rectangle.width).toBe(width + x);
              expect(this.rectangle.height).toBe(height + y);
              expect(this.rectangle.topLeft()).toBeSamePoint(this.data.topLeft);
              return expect(res).toBe(this.rectangle);
            });
          });
          describe('its inflateLeft method called', function() {
            beforeEach(function() {
              this.inflate = 2;
              return this.result = this.rectangle.inflateLeft(this.inflate);
            });
            it('should inflate the rectangle to the left', function() {
              var topEdge;
              expect(this.rectangle.width).toBe(width + this.inflate);
              expect(this.rectangle.height).toBe(height);
              topEdge = point(this.rectangle.topEdge()).normalize(-this.inflate);
              return expect(this.rectangle.topLeft()).toBeSamePoint(point(this.data.topLeft).add(topEdge));
            });
            return it('returns the rectangle', function() {
              return expect(this.result).toBe(this.rectangle);
            });
          });
          describe('its inflateRight method called', function() {
            beforeEach(function() {
              this.inflate = 2;
              return this.result = this.rectangle.inflateRight(this.inflate);
            });
            it('should inflate the rectangle to the right', function() {
              expect(this.rectangle.width).toBe(width + this.inflate);
              expect(this.rectangle.height).toBe(height);
              return expect(this.rectangle.topLeft()).toBeSamePoint(this.data.topLeft);
            });
            return it('returns the rectangle', function() {
              return expect(this.result).toBe(this.rectangle);
            });
          });
          describe('its inflateTop method called', function() {
            beforeEach(function() {
              this.inflate = 2;
              return this.result = this.rectangle.inflateTop(this.inflate);
            });
            it('should inflate the rectangle to the top', function() {
              var leftEdge;
              expect(this.rectangle.width).toBe(width);
              expect(this.rectangle.height).toBe(height + this.inflate);
              leftEdge = point(this.rectangle.leftEdge()).normalize(-this.inflate);
              return expect(this.rectangle.topLeft()).toBeSamePoint(point(this.data.topLeft).add(leftEdge));
            });
            return it('returns the rectangle', function() {
              return expect(this.result).toBe(this.rectangle);
            });
          });
          describe('its inflateBottom method called', function() {
            beforeEach(function() {
              this.inflate = 2;
              return this.result = this.rectangle.inflateBottom(this.inflate);
            });
            it('should inflate the rectangle to the bottom', function() {
              expect(this.rectangle.width).toBe(width);
              expect(this.rectangle.height).toBe(height + this.inflate);
              return expect(this.rectangle.topLeft()).toBeSamePoint(this.data.topLeft);
            });
            return it('returns the rectangle', function() {
              return expect(this.result).toBe(this.rectangle);
            });
          });
          acreageOf(source).shouldBe(acreage);
          describe('its contains method', function() {
            var a, data;
            data = rectangleData.apply(global, test);
            a = [];
            [0, 1, 2, 3, 4].forEach(function(n) {
              a.push(data.topLeft.x + (n / 5) * data.topEdge.x + (n / 5) * data.leftEdge.x);
              return a.push(data.topLeft.y + (n / 5) * data.topEdge.y + (n / 5) * data.leftEdge.y);
            });
            calledWithPoints.apply(global, a).where({
              source: source,
              method: 'contains'
            }).should('returns true for points inside the rectangle', function(res) {
              return expect(res).toBeTruthy();
            });
            return calledWithPoints(-10, -10).where({
              source: source,
              method: 'contains'
            }).should('returns false for points outside the rectangle', function(res) {
              return expect(res).toBeFalsy();
            });
          });
          lengthOf(source).shouldBe(length);
          geometry(source).shouldBe.closedGeometry();
          geometry(source).shouldBe.translatable();
          geometry(source).shouldBe.rotatable();
          geometry(source).shouldBe.scalable();
          describe('its bounds method', function() {
            return it('returns the bounds of the rectangle', function() {
              return expect(this.rectangle.bounds()).toEqual({
                top: this.rectangle.top(),
                left: this.rectangle.left(),
                bottom: this.rectangle.bottom(),
                right: this.rectangle.right()
              });
            });
          });
          describe('its boundingBox method', function() {
            return it('returns a rectangle representing its bounds', function() {
              return expect(this.rectangle.boundingBox()).toBeRectangle(this.rectangle.left(), this.rectangle.top(), this.rectangle.right() - this.rectangle.left(), this.rectangle.bottom() - this.rectangle.top());
            });
          });
          return testDrawingOf(source);
        });
      });
      return eachPair(tests, function(msg, o) {
        var args, height, rotation, test, width, x, y;
        args = o.args, test = o.test;
        x = test[0], y = test[1], width = test[2], height = test[3], rotation = test[4];
        describe("::paste called with " + msg + " " + args, function() {
          return it('should copy the passed-in data in the rectangle', function() {
            var rect;
            rect = rectangle();
            rect.paste.apply(rect, args);
            return expect(rect).toBeRectangle(x, y, width, height, rotation);
          });
        });
        describe("::equals called", function() {
          it('returns true when rectangles are equals', function() {
            var rect1, rect2;
            rect1 = rectangle.apply(global, args);
            rect2 = rectangle.apply(global, args);
            return expect(rect1.equals(rect2)).toBeTruthy();
          });
          it('returns false when rectangles are different', function() {
            var rect1, rect2;
            rect1 = rectangle.apply(global, args);
            rect2 = rectangle(-1, -1, 10, 10, 100);
            return expect(rect1.equals(rect2)).toBeFalsy();
          });
          return it('returns false when passed null', function() {
            var rect;
            rect = rectangle.apply(global, args);
            return expect(rect.equals(null)).toBeFalsy();
          });
        });
        return describe('::points called', function() {
          return it('returnss an array with the corners of the rectangle', function() {
            var data, points, rect, testPoints;
            rect = rectangle.apply(global, args);
            data = rectangleData.apply(global, test);
            points = rect.points();
            testPoints = [data.topLeft, data.topRight, data.bottomRight, data.bottomLeft, data.topLeft];
            expect(points.length).toBe(5);
            return points.forEach(function(pt, i) {
              return expect(pt).toBeSamePoint(testPoints[i]);
            });
          });
        });
      });
    });
    describe('::clone called', function() {
      return it('should the copy of the rectangle', function() {
        return expect(rectangle(4, 5, 6, 7, 8).clone()).toBeRectangle(4, 5, 6, 7, 8);
      });
    });
    return describe('path API', function() {
      beforeEach(function() {
        this.rectangle = rectangle(0, 0, 20, 10);
        return this.data = rectangleData(0, 0, 20, 10);
      });
      describe('::pathPointAt method called', function() {
        describe('with 0', function() {
          return it('returns the top left corner', function() {
            return expect(this.rectangle.pathPointAt(0)).toBeSamePoint(this.data.topLeft);
          });
        });
        describe('with 1', function() {
          return it('returns the top left corner', function() {
            return expect(this.rectangle.pathPointAt(1)).toBeSamePoint(this.data.topLeft);
          });
        });
        describe('with 0.5', function() {
          return it('returns the bottom right corner', function() {
            return expect(this.rectangle.pathPointAt(0.5)).toBeSamePoint(this.data.bottomRight);
          });
        });
        describe('with 0 and false', function() {
          return it('returns the top left corner', function() {
            return expect(this.rectangle.pathPointAt(0, false)).toBeSamePoint(this.data.topLeft);
          });
        });
        describe('with 1 and false', function() {
          return it('returns the top left corner', function() {
            return expect(this.rectangle.pathPointAt(1, false)).toBeSamePoint(this.data.topLeft);
          });
        });
        return describe('with 0.5 and false', function() {
          return it('returns the bottom right corner', function() {
            return expect(this.rectangle.pathPointAt(0.5, false)).toBeSamePoint(this.data.bottomRight);
          });
        });
      });
      describe('::pathOrientationAt method called', function() {
        describe('with 0', function() {
          return it('returns 0', function() {
            return expect(this.rectangle.pathOrientationAt(0)).toBeClose(0);
          });
        });
        describe('with 1', function() {
          return it('returns -Math.PI/2', function() {
            return expect(this.rectangle.pathOrientationAt(1)).toBeClose(-Math.PI / 2);
          });
        });
        describe('with 0.5', function() {
          return it('returns Math.PI', function() {
            return expect(this.rectangle.pathOrientationAt(0.5)).toBeClose(-Math.PI);
          });
        });
        describe('with 0 and false', function() {
          return it('returns 0', function() {
            return expect(this.rectangle.pathOrientationAt(0, false)).toBeClose(0);
          });
        });
        describe('with 1 and false', function() {
          return it('returns -Math.PI/2', function() {
            return expect(this.rectangle.pathOrientationAt(1, false)).toBeClose(-Math.PI / 2);
          });
        });
        return describe('with 0.5 and false', function() {
          return it('returns Math.PI', function() {
            return expect(this.rectangle.pathOrientationAt(0.5, false)).toBeClose(-Math.PI);
          });
        });
      });
      describe('::containsGeometry called', function() {
        describe('with a geometry inside the rectangle', function() {
          return it('returns true', function() {
            var rect1, rect2;
            rect1 = rectangle(0, 0, 10, 10);
            rect2 = rectangle(2, 2, 2, 2);
            return expect(rect1.containsGeometry(rect2)).toBeTruthy();
          });
        });
        describe('with a geometry overlapping the rectangle', function() {
          return it('returns false', function() {
            var rect1, rect2;
            rect1 = rectangle(0, 0, 10, 10);
            rect2 = rectangle(-2, -2, 4, 4);
            return expect(rect1.containsGeometry(rect2)).toBeFalsy();
          });
        });
        return describe('with a geometry outside the rectangle', function() {
          return it('returns false', function() {
            var rect1, rect2;
            rect1 = rectangle(0, 0, 10, 10);
            rect2 = rectangle(-2, -2, 1, 1);
            return expect(rect1.containsGeometry(rect2)).toBeFalsy();
          });
        });
      });
      describe('::intersects called', function() {
        describe('with a geometry that intersects the rectagle', function() {
          return it('returns true', function() {
            var rect1, rect2;
            rect1 = rectangle(0, 0, 10, 10);
            rect2 = rectangle(-2, -2, 4, 4);
            return expect(rect1.intersects(rect2)).toBeTruthy();
          });
        });
        return describe('with a geometry that does not intersects the rectagle', function() {
          return it('returns false', function() {
            var rect1, rect2;
            rect1 = rectangle(0, 0, 10, 10);
            rect2 = rectangle(-2, -2, 1, 1);
            return expect(rect1.intersects(rect2)).toBeFalsy();
          });
        });
      });
      return describe('::intersections called', function() {
        describe('with a geometry that intersects the rectagle', function() {
          return it('returns an array with the 2 intersections', function() {
            var rect1, rect2, res;
            rect1 = rectangle(0, 0, 10, 10);
            rect2 = rectangle(-2, -2, 4, 4);
            res = rect1.intersections(rect2);
            expect(res.length).toBe(2);
            expect(res[0]).toBePoint(2, 0);
            return expect(res[1]).toBePoint(0, 2);
          });
        });
        return describe('with a geometry that does not intersects the rectagle', function() {
          return it('returns null', function() {
            var rect1, rect2, res;
            rect1 = rectangle(0, 0, 10, 10);
            rect2 = rectangle(-2, -2, 1, 1);
            res = rect1.intersections(rect2);
            return expect(res).toBeNull();
          });
        });
      });
    });
  });

  describe('Spiral', function() {
    return eachPair(spiralFactories, function(k, v) {
      var args, data, radius1, radius2, rotation, segments, source, test, twirl, x, y;
      args = v.args, test = v.test;
      radius1 = test[0], radius2 = test[1], twirl = test[2], x = test[3], y = test[4], rotation = test[5], segments = test[6];
      data = spiralData(radius1, radius2, twirl, x, y, rotation, segments);
      source = 'spiral';
      return describe("when instanciated " + k, function() {
        beforeEach(function() {
          addSpiralMatchers(this);
          addPointMatchers(this);
          return this.spiral = spiral.apply(global, args);
        });
        it('exists', function() {
          return expect(this.spiral).toBeDefined();
        });
        describe('its toSource method', function() {
          return it('returns the source code of the spiral', function() {
            return expect(this.spiral.toSource()).toBe(data.source);
          });
        });
        it('has been filled with the passed-in arguments', function() {
          return expect(this.spiral).toBeSpiral(radius1, radius2, twirl, x, y, rotation, segments);
        });
        describe('its points method', function() {
          return it('returns a array', function() {
            var points;
            points = this.spiral.points();
            return expect(points.length).toBe(segments + 1);
          });
        });
        describe('its equals method', function() {
          describe('when called with an object equal to the current spiral', function() {
            return it('returns true', function() {
              var target;
              target = spiral.apply(global, args);
              return expect(this.spiral.equals(target)).toBeTruthy();
            });
          });
          return describe('when called with an object different than the spiral', function() {
            return it('returns false', function() {
              var target;
              target = spiral(4, 5, 1, 3);
              return expect(this.spiral.equals(target)).toBeFalsy();
            });
          });
        });
        describe('its clone method', function() {
          return it('returns a copy of this spiral', function() {
            return expect(this.spiral.clone()).toBeSpiral(this.spiral.radius1, this.spiral.radius2, this.spiral.twirl, this.spiral.x, this.spiral.y, this.spiral.rotation, this.spiral.segments);
          });
        });
        geometry(source).shouldBe.openGeometry();
        geometry(source).shouldBe.translatable();
        geometry(source).shouldBe.rotatable();
        return geometry(source).shouldBe.scalable();
      });
    });
  });

  describe('TransformationProxy', function() {
    return describe('instanciated with a target geometry', function() {
      beforeEach(function() {
        addPointMatchers(this);
        this.proxy = new agt.geom.TransformationProxy(rectangle(0, 0, 10, 10));
        return this.proxyableMethods = ['points', 'pathPointAt', 'pathOrientationAt'];
      });
      it('has detected the proxyable methods', function() {
        var proxied, _i, _len, _ref, _results;
        _ref = this.proxyableMethods;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          proxied = _ref[_i];
          _results.push(expect(this.proxy.proxied().indexOf(proxied)).not.toBe(-1));
        }
        return _results;
      });
      it('is able to proxy the found methods', function() {
        return expect(this.proxy.points()).toEqual(this.proxy.geometry.points());
      });
      return describe('when provided with a matrix', function() {
        beforeEach(function() {
          var m;
          m = matrix();
          m.scale(2, 2);
          return this.proxy.matrix = m;
        });
        describe('the proxied method points', function() {
          return it('transforms points in the array', function() {
            var geomPoints, p, proxyPoints, _i, _len, _results;
            geomPoints = this.proxy.geometry.points();
            proxyPoints = this.proxy.points();
            _results = [];
            for (i = _i = 0, _len = proxyPoints.length; _i < _len; i = ++_i) {
              p = proxyPoints[i];
              _results.push(expect(p).toBeSamePoint(geomPoints[i].scale(2)));
            }
            return _results;
          });
        });
        describe('the proxied method pathPointAt', function() {
          return it('transforms the resulting point', function() {
            return expect(this.proxy.pathPointAt(0.5)).toBePoint(20, 20);
          });
        });
        return describe('the proxied method pathOrientationAt', function() {
          return it('transforms the resulting angle', function() {
            var m;
            m = matrix();
            m.rotate(Math.PI);
            this.proxy.matrix = m;
            return expect(this.proxy.pathOrientationAt(0.5)).toBe(this.proxy.geometry.pathOrientationAt(0.5) + Math.PI);
          });
        });
      });
    });
  });

  describe('Triangle', function() {
    var dataFactories, factories;
    beforeEach(function() {
      addPointMatchers(this);
      return addRectangleMatchers(this);
    });
    factories = [triangle];
    dataFactories = [triangleData, triangleData.equilateral, triangleData.isosceles, triangleData.rectangle, triangleData];
    factories.forEach(function(factory, i) {
      var data, source;
      data = dataFactories[i]();
      source = 'triangle';
      return describe('when instanciated with three valid points', function() {
        beforeEach(function() {
          return this.triangle = factory();
        });
        it('creates a valid triangle instance', function() {
          return expect(this.triangle).toBeDefined();
        });
        ['a', 'b', 'c'].forEach(function(k) {
          return describe("its '" + k + "' property", function() {
            return it("has been filled with " + data[k], function() {
              return expect(this.triangle[k]).toBeSamePoint(data[k]);
            });
          });
        });
        ['ab', 'ac', 'ba', 'bc', 'ca', 'cb', 'abCenter', 'acCenter', 'bcCenter'].forEach(function(k) {
          return describe("its '" + k + "' method", function() {
            return it("returns " + data[k], function() {
              return expect(this.triangle[k]()).toBeSamePoint(data[k]);
            });
          });
        });
        ['abc', 'bac', 'acb'].forEach(function(k) {
          return describe("its '" + k + "' method", function() {
            return it("returns " + data[k], function() {
              return expect(this.triangle[k]()).toBeClose(data[k]);
            });
          });
        });
        describe('its center method', function() {
          return it('returns the triangle center', function() {
            return expect(this.triangle.center()).toBeSamePoint(data.center);
          });
        });
        describe('its translate method', function() {
          beforeEach(function() {
            this.x = 3;
            this.y = 4;
            return this.result = this.triangle.translate(this.x, this.y);
          });
          it('translates the triangle', function() {
            expect(this.triangle.a).toBePoint(data.a.x + this.x, data.a.y + this.y);
            expect(this.triangle.b).toBePoint(data.b.x + this.x, data.b.y + this.y);
            return expect(this.triangle.c).toBePoint(data.c.x + this.x, data.c.y + this.y);
          });
          return it('returns the triangle', function() {
            return expect(this.result).toBe(this.triangle);
          });
        });
        describe('its rotateAroundCenter method', function() {
          beforeEach(function() {
            this.rotation = 10;
            return this.result = this.triangle.rotateAroundCenter(this.rotation);
          });
          it('rotates the triangle around its center', function() {
            var a, b, c;
            a = data.a.rotateAround(data.center, this.rotation);
            b = data.b.rotateAround(data.center, this.rotation);
            c = data.c.rotateAround(data.center, this.rotation);
            expect(this.triangle.a).toBeSamePoint(a);
            expect(this.triangle.b).toBeSamePoint(b);
            return expect(this.triangle.c).toBeSamePoint(c);
          });
          it('preserves the triangle center', function() {
            return expect(this.triangle.center()).toBeSamePoint(data.center);
          });
          return it('returns the triangle', function() {
            return expect(this.result).toBe(this.triangle);
          });
        });
        describe('its scaleAroundCenter method', function() {
          beforeEach(function() {
            this.scale = 2;
            return this.result = this.triangle.scaleAroundCenter(this.scale);
          });
          it('scales the triangle around its center', function() {
            var a, b, c, center;
            center = point(data.center);
            a = center.add(data.a.subtract(center).scale(this.scale));
            b = center.add(data.b.subtract(center).scale(this.scale));
            c = center.add(data.c.subtract(center).scale(this.scale));
            expect(this.triangle.a).toBeSamePoint(a);
            expect(this.triangle.b).toBeSamePoint(b);
            return expect(this.triangle.c).toBeSamePoint(c);
          });
          it('preserves the triangle center', function() {
            return expect(this.triangle.center()).toBeSamePoint(data.center);
          });
          return it('returns the triangle', function() {
            return expect(this.result).toBe(this.triangle);
          });
        });
        testDrawingOf(source);
        acreageOf(source).shouldBe(data.acreage);
        describe('::acreage memoization', function() {
          return it('does not break the behavior of the function', function() {
            var a1, a2, a3, a4;
            a1 = this.triangle.acreage();
            a2 = this.triangle.acreage();
            expect(a2).toBe(a1);
            this.triangle.a.x = 100;
            a3 = this.triangle.acreage();
            a4 = this.triangle.acreage();
            expect(a3).not.toBe(a1);
            return expect(a4).toBe(a3);
          });
        });
        calledWithPoints(data.center.x, data.center.y).where({
          source: source,
          method: 'contains'
        }).should('returns true for points inside the triangle', function(res) {
          return expect(res).toBeTruthy();
        });
        calledWithPoints(100, 100).where({
          source: source,
          method: 'contains'
        }).should('returns false for points outside the triangle', function(res) {
          return expect(res).toBeFalsy();
        });
        lengthOf(source).shouldBe(data.length);
        describe('its pathPointAt method', function() {
          describe('called with 0', function() {
            return it('returns a', function() {
              return expect(this.triangle.pathPointAt(0)).toBeSamePoint(this.triangle.a);
            });
          });
          describe('called with 1', function() {
            return it('returns a', function() {
              return expect(this.triangle.pathPointAt(1)).toBeSamePoint(this.triangle.a);
            });
          });
          describe('called with 1/3 and false', function() {
            return it('returns b', function() {
              return expect(this.triangle.pathPointAt(1 / 3, false)).toBeSamePoint(this.triangle.b);
            });
          });
          return describe('called with 2/3 and false', function() {
            return it('returns c', function() {
              return expect(this.triangle.pathPointAt(2 / 3, false)).toBeSamePoint(this.triangle.c);
            });
          });
        });
        describe('its pathOrientationAt method', function() {
          describe('called with 0', function() {
            return it('returns ab angle', function() {
              return expect(this.triangle.pathOrientationAt(0)).toBeClose(data.ab.angle());
            });
          });
          describe('called with 1', function() {
            return it('returns ca angle', function() {
              return expect(this.triangle.pathOrientationAt(1)).toBeClose(data.ca.angle());
            });
          });
          describe('called with 1/3 and false', function() {
            return it('returns bc angle', function() {
              return expect(this.triangle.pathOrientationAt(1 / 3, false)).toBeClose(data.bc.angle());
            });
          });
          return describe('called with 2/3 and false', function() {
            return it('returns ca angle', function() {
              return expect(this.triangle.pathOrientationAt(2 / 3, false)).toBeClose(data.ca.angle());
            });
          });
        });
        describe('its points method', function() {
          return it('returns four points', function() {
            var points;
            points = this.triangle.points();
            expect(points.length).toBe(4);
            expect(points[0]).toBeSamePoint(data.a);
            expect(points[1]).toBeSamePoint(data.b);
            expect(points[2]).toBeSamePoint(data.c);
            return expect(points[3]).toBeSamePoint(data.a);
          });
        });
        geometry(source).shouldBe.closedGeometry();
        geometry(source).shouldBe.translatable();
        geometry(source).shouldBe.rotatable();
        geometry(source).shouldBe.scalable();
        ['top', 'left', 'bottom', 'right'].forEach(function(k) {
          return describe("its " + k + " method", function() {
            return it("returns " + data[k], function() {
              return expect(this.triangle[k]()).toBe(data[k]);
            });
          });
        });
        describe('its bounds method', function() {
          return it('returns the bounds of the triangle', function() {
            return expect(this.triangle.bounds()).toEqual(data.bounds);
          });
        });
        return describe('its boundingBox method', function() {
          return it('returns the bounds of the triangle', function() {
            return expect(this.triangle.boundingBox()).toBeRectangle(data.left, data.top, data.right - data.left, data.bottom - data.top);
          });
        });
      });
    });
    describe('when instanciated with at least an invalid point', function() {
      return it('throws an error', function() {
        return expect(function() {
          return triangle(point(4, 5), point(5, 7), 'notAPoint');
        }).toThrow();
      });
    });
    describe('::equilateral called', function() {
      describe('on a triangle which is equilateral', function() {
        return it('returns true', function() {
          return expect(triangle.equilateral().equilateral()).toBeTruthy();
        });
      });
      return describe('on a triangle which is not equilateral', function() {
        return it('returns false', function() {
          return expect(triangle().equilateral()).toBeFalsy();
        });
      });
    });
    describe('::isosceles called', function() {
      describe('on a triangle which is isosceles', function() {
        return it('returns true', function() {
          return expect(triangle.isosceles().isosceles()).toBeTruthy();
        });
      });
      return describe('on a triangle which is not isosceles', function() {
        return it('returns false', function() {
          return expect(triangle().isosceles()).toBeFalsy();
        });
      });
    });
    describe('::rectangle called', function() {
      describe('on a triangle which is rectangle', function() {
        return it('returns true', function() {
          return expect(triangle.rectangle().rectangle()).toBeTruthy();
        });
      });
      return describe('on a triangle which is not rectangle', function() {
        return it('returns false', function() {
          return expect(triangle().rectangle()).toBeFalsy();
        });
      });
    });
    describe('::clone called', function() {
      return it('returns a copy of the object', function() {
        var clone, original;
        original = triangle();
        clone = original.clone();
        expect(clone.a).toBeSamePoint(original.a);
        expect(clone.b).toBeSamePoint(original.b);
        return expect(clone.c).toBeSamePoint(original.c);
      });
    });
    return describe('::equals called', function() {
      beforeEach(function() {
        return this.triangle = triangle();
      });
      describe('with a point that is equal', function() {
        return it('returns true', function() {
          return expect(this.triangle.equals(triangle())).toBeTruthy();
        });
      });
      return describe('with a point that is not equal', function() {
        return it('returns false', function() {
          return expect(this.triangle.equals(triangle.isosceles())).toBeFalsy();
        });
      });
    });
  });

  describe('agt.Impulse', function() {
    beforeEach(function() {
      this.impulse = new agt.Impulse;
      return this.listener = jasmine.createSpy('listener');
    });
    describe('when adding a listener', function() {
      beforeEach(function() {
        return this.impulse.add(this.listener);
      });
      it('adds the listener in the listeners array', function() {
        return expect(this.impulse.listeners.length).toEqual(1);
      });
      it('starts itself', function() {
        return expect(this.impulse.running).toBeTruthy();
      });
      it('does not add twice the same listener', function() {
        this.impulse.add(this.listener);
        return expect(this.impulse.listeners.length).toEqual(1);
      });
      describe('with a message passed in dispatch', function() {
        beforeEach(function() {
          return this.impulse.dispatch('foo');
        });
        return it('sends the message to the listener', function() {
          return expect(this.listener).toHaveBeenCalled();
        });
      });
      return describe('removing a listener', function() {
        beforeEach(function() {
          return this.impulse.remove(this.listener);
        });
        it('removes the listener from the listeners array', function() {
          return expect(this.impulse.listeners.length).toEqual(0);
        });
        return it('stop itself', function() {
          return expect(this.impulse.running).toBeFalsy();
        });
      });
    });
    describe('when adding a listener with a context', function() {
      beforeEach(function() {
        this.scope = {};
        this.listener = function() {
          return this.foo = 'bar';
        };
        return this.impulse.add(this.listener, this.scope);
      });
      it('calls the listener in the given context', function() {
        this.impulse.dispatch();
        return expect(this.scope.foo).toEqual('bar');
      });
      it('accepts twice the same listener with different scope', function() {
        this.impulse.add(this.listener, {});
        return expect(this.impulse.listeners.length).toEqual(2);
      });
      return it('removes the listener only with its context', function() {
        this.impulse.remove(this.listener);
        expect(this.impulse.listeners.length).toEqual(1);
        this.impulse.remove(this.listener, this.scope);
        return expect(this.impulse.listeners.length).toEqual(0);
      });
    });
    describe('::addOnce', function() {
      return describe('called with a listener', function() {
        beforeEach(function() {
          return this.impulse.addOnce(this.listener);
        });
        it('adds the listener in the listeners array', function() {
          return expect(this.impulse.listeners.length).toEqual(1);
        });
        return it('removes the listener after the first dispatch', function() {
          this.impulse.dispatch();
          return expect(this.impulse.listeners.length).toEqual(0);
        });
      });
    });
    describe('adding listeners with priority', function() {
      beforeEach(function() {
        this.listenersCalls = [];
        this.listener1 = (function(_this) {
          return function() {
            return _this.listenersCalls.push('listener1');
          };
        })(this);
        this.listener2 = (function(_this) {
          return function() {
            return _this.listenersCalls.push('listener2');
          };
        })(this);
        this.impulse.add(this.listener1);
        return this.impulse.add(this.listener2, null, 1);
      });
      return it('calls the listeners in order', function() {
        this.impulse.dispatch();
        return expect(this.listenersCalls).toEqual(['listener2', 'listener1']);
      });
    });
    describe('adding listeners with priority once', function() {
      beforeEach(function() {
        this.listenersCalls = [];
        this.listener1 = (function(_this) {
          return function() {
            return _this.listenersCalls.push('listener1');
          };
        })(this);
        this.listener2 = (function(_this) {
          return function() {
            return _this.listenersCalls.push('listener2');
          };
        })(this);
        this.impulse.addOnce(this.listener1);
        return this.impulse.addOnce(this.listener2, null, 1);
      });
      return it('calls the listeners in order', function() {
        this.impulse.dispatch();
        expect(this.listenersCalls).toEqual(['listener2', 'listener1']);
        return expect(this.impulse.listeners.length).toEqual(0);
      });
    });
    return it('removes all listeners at once', function() {
      var listener1, listener2, signal;
      signal = new agt.Signal;
      listener1 = function() {};
      listener2 = function() {};
      signal.add(listener1);
      signal.add(listener2);
      signal.removeAll();
      return expect(signal.listeners.length).toBe(0);
    });
  });

  describe('agt.mixins.Activable', function() {
    return describe('when included in a class', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.include(agt.mixins.Activable);

          TestClass.prototype.activated = function() {};

          TestClass.prototype.deactivated = function() {};

          return TestClass;

        })();
        this.instance = new TestClass;
        spyOn(this.instance, 'activated');
        return spyOn(this.instance, 'deactivated');
      });
      it('creates deactivated instances', function() {
        return expect(this.instance.active).toBeFalsy();
      });
      return describe('calling the activate method', function() {
        beforeEach(function() {
          return this.instance.activate();
        });
        it('activates the instance', function() {
          return expect(this.instance.active).toBeTruthy();
        });
        it('calls the activated hook', function() {
          return expect(this.instance.activated).toHaveBeenCalled();
        });
        describe('activated a second time', function() {
          beforeEach(function() {
            return this.instance.activate();
          });
          return it('does not calls twice the activated hook', function() {
            return expect(this.instance.activated.calls.count()).toEqual(1);
          });
        });
        return describe('then deactivated', function() {
          beforeEach(function() {
            return this.instance.deactivate();
          });
          it('deactivates the instance', function() {
            return expect(this.instance.active).toBeFalsy();
          });
          it('calls the deactivated hook', function() {
            return expect(this.instance.deactivated).toHaveBeenCalled();
          });
          return describe('deactivated a second time', function() {
            beforeEach(function() {
              return this.instance.deactivate();
            });
            return it('does not calls twice the deactivated hook', function() {
              return expect(this.instance.deactivated.calls.count()).toEqual(1);
            });
          });
        });
      });
    });
  });

  describe('agt.mixins.Aliasable', function() {
    beforeEach(function() {
      var TestClass;
      TestClass = (function() {
        function TestClass() {}

        TestClass.extend(agt.mixins.Aliasable);

        TestClass.prototype.foo = function() {
          return 'foo';
        };

        TestClass.getter('bar', function() {
          return 'bar';
        });

        TestClass.alias('foo', 'oof', 'ofo');

        TestClass.alias('bar', 'rab', 'bra');

        return TestClass;

      })();
      return this.instance = new TestClass;
    });
    return it('creates aliases for object properties', function() {
      expect(this.instance.oof).toEqual(this.instance.foo);
      expect(this.instance.ofo).toEqual(this.instance.foo);
      expect(this.instance.rab).toEqual(this.instance.bar);
      return expect(this.instance.bra).toEqual(this.instance.bar);
    });
  });

  describe('agt.mixins.AlternateCase', function() {
    describe('mixed in a class using camelCase', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.extend(agt.mixins.AlternateCase);

          TestClass.prototype.someProperty = true;

          TestClass.prototype.someMethod = function() {};

          TestClass.snakify();

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('creates properties with snake case', function() {
        expect(this.instance.some_property).toBeDefined();
        return expect(this.instance.some_method).toBeDefined();
      });
    });
    return describe('mixed in a class using snake_case', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.extend(agt.mixins.AlternateCase);

          TestClass.prototype.some_property = true;

          TestClass.prototype.some_method = function() {};

          TestClass.camelize();

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('creates properties with camel case', function() {
        expect(this.instance.some_property).toBeDefined();
        return expect(this.instance.someMethod).toBeDefined();
      });
    });
  });

  describe('agt.mixins.Cloneable', function() {
    describe('when called without arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(agt.mixins.Cloneable());

          function TestClass(self) {
            this.self = self;
          }

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('creates a copy by passing the reference in the copy constructor', function() {
        var clone;
        clone = this.instance.clone();
        expect(clone).toBeDefined();
        return expect(clone.self).toBe(this.instance);
      });
    });
    return describe('when called with arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(agt.mixins.Cloneable('a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
        return this.instance = new TestClass(10, 'foo');
      });
      return it('creates a copy of the object', function() {
        var clone;
        clone = this.instance.clone();
        expect(clone).toBeDefined();
        expect(clone).toEqual(this.instance);
        return expect(clone).not.toBe(this.instance);
      });
    });
  });

  describe('agt.mixins.Delegation', function() {
    return describe('included in a class with delegated properties', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.extend(agt.mixins.Delegation);

          TestClass.delegate('foo', 'bar', 'func', {
            to: 'subObject'
          });

          TestClass.delegate('baz', {
            to: 'subObject',
            prefix: true
          });

          TestClass.delegate('baz', {
            to: 'subObject',
            prefix: true,
            "case": 'snake'
          });

          function TestClass() {
            this.subObject = {
              foo: 'foo',
              bar: 'bar',
              baz: 'baz',
              func: function() {
                return this.foo;
              }
            };
          }

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      describe('when accessing a delegated property', function() {
        it('returns the composed instance value', function() {
          expect(this.instance.foo).toEqual('foo');
          return expect(this.instance.bar).toEqual('bar');
        });
        describe('that hold a function', function() {
          return describe('calling the function', function() {
            return it('binds the methods to the delegated object', function() {
              return expect(this.instance.func()).toEqual('foo');
            });
          });
        });
        return describe('with prefix', function() {
          it('returns the composed instance value', function() {
            return expect(this.instance.subObjectBaz).toEqual('baz');
          });
          return describe('and snake case', function() {
            return it('returns the composed instance value', function() {
              return expect(this.instance.subObject_baz).toEqual('baz');
            });
          });
        });
      });
      return describe('writing on a delegated property', function() {
        beforeEach(function() {
          this.instance.foo = 'oof';
          return this.instance.bar = 'rab';
        });
        it('writes in the composed instance properties', function() {
          expect(this.instance.foo).toEqual('oof');
          return expect(this.instance.bar).toEqual('rab');
        });
        return describe('with prefix', function() {
          beforeEach(function() {
            return this.instance.subObjectBaz = 'zab';
          });
          it('writes in the composed instance properties', function() {
            return expect(this.instance.subObjectBaz).toEqual('zab');
          });
          return describe('and snake case', function() {
            beforeEach(function() {
              return this.instance.subObject_baz = 'zab';
            });
            return it('writes in the composed instance properties', function() {
              return expect(this.instance.subObject_baz).toEqual('zab');
            });
          });
        });
      });
    });
  });

  describe('agt.mixins.Equatable', function() {
    return describe('when called with a list of properties name', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(agt.mixins.Equatable('a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
        this.instance1 = new TestClass(1, 2);
        this.instance2 = new TestClass(1, 2);
        return this.instance3 = new TestClass(2, 2);
      });
      it('returns true with two similar instancew', function() {
        return expect(this.instance1.equals(this.instance2)).toBeTruthy();
      });
      return it('returns false with tow different instances', function() {
        return expect(this.instance1.equals(this.instance3)).toBeFalsy();
      });
    });
  });

  describe('agt.mixins.Formattable', function() {
    describe('when called with extra arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          TestClass.include(agt.mixins.Formattable('TestClass', 'a', 'b'));

          function TestClass(a, b) {
            this.a = a;
            this.b = b;
          }

          return TestClass;

        })();
        return this.instance = new TestClass(5, 'foo');
      });
      return it('returns a formatted string with extra details', function() {
        return expect(this.instance.toString()).toEqual('[TestClass(a=5, b=foo)]');
      });
    });
    return describe('when called without extra arguments', function() {
      beforeEach(function() {
        var TestClass;
        TestClass = (function() {
          function TestClass() {}

          TestClass.include(agt.mixins.Formattable('TestClass'));

          return TestClass;

        })();
        return this.instance = new TestClass;
      });
      return it('returns a formatted string without any details', function() {
        return expect(this.instance.toString()).toEqual('[TestClass]');
      });
    });
  });

  describe('agt.mixins.Globalizable', function() {
    beforeEach(function() {
      var TestClass;
      TestClass = (function() {
        function TestClass() {}

        TestClass.include(agt.mixins.Globalizable(typeof global !== "undefined" && global !== null ? global : window));

        TestClass.prototype.globalizable = ['method'];

        TestClass.prototype.property = 'foo';

        TestClass.prototype.method = function() {
          return this.property;
        };

        return TestClass;

      })();
      return this.instance = new TestClass;
    });
    return describe('when globalized', function() {
      beforeEach(function() {
        return this.instance.globalize();
      });
      afterEach(function() {
        return this.instance.unglobalize();
      });
      it('creates methods on the global object', function() {
        return expect(method()).toEqual('foo');
      });
      return describe('and then unglobalized', function() {
        beforeEach(function() {
          return this.instance.unglobalize();
        });
        return it('removes the methods from the global object', function() {
          return expect(typeof method).toEqual('undefined');
        });
      });
    });
  });

  describe('agt.mixins.HasAncestors', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
        TestClass.concern(agt.mixins.HasAncestors({
          through: 'customParent'
        }));

        function TestClass(name, customParent) {
          this.name = name;
          this.customParent = customParent;
        }

        TestClass.prototype.toString = function() {
          return 'instance ' + this.name;
        };

        return TestClass;

      })();
      this.instanceA = new TestClass('a');
      this.instanceB = new TestClass('b', this.instanceA);
      return this.instanceC = new TestClass('c', this.instanceB);
    });
    describe('#ancestors', function() {
      return it('returns an array of the object ancestors', function() {
        return expect(this.instanceC.ancestors).toEqual([this.instanceB, this.instanceA]);
      });
    });
    describe('#selfAndAncestors', function() {
      return it('returns an array of the object and its ancestors', function() {
        return expect(this.instanceC.selfAndAncestors).toEqual([this.instanceC, this.instanceB, this.instanceA]);
      });
    });
    return describe('.ancestorsScope', function() {
      beforeEach(function() {
        return this.testClass.ancestorsScope('isB', function(p) {
          return p.name === 'b';
        });
      });
      return it('createss a scope filtering the ancestors', function() {
        return expect(this.instanceC.isB).toEqual([this.instanceB]);
      });
    });
  });

  describe('agt.mixins.HasCollection', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
        TestClass.concern(agt.mixins.HasCollection('customChildren', 'customChild'));

        function TestClass(name, customChildren) {
          this.name = name;
          this.customChildren = customChildren != null ? customChildren : [];
        }

        return TestClass;

      })();
      this.instanceRoot = new TestClass('root');
      this.instanceA = new TestClass('a');
      this.instanceB = new TestClass('b');
      this.instanceRoot.customChildren.push(this.instanceA);
      return this.instanceRoot.customChildren.push(this.instanceB);
    });
    return describe('included in class TestClass', function() {
      it('provides properties to count children', function() {
        expect(this.instanceRoot.customChildrenSize).toEqual(2);
        expect(this.instanceRoot.customChildrenLength).toEqual(2);
        return expect(this.instanceRoot.customChildrenCount).toEqual(2);
      });
      describe('using the generated customChildrenScope method', function() {
        beforeEach(function() {
          return this.testClass.customChildrenScope('childrenNamedB', function(child) {
            return child.name === 'b';
          });
        });
        return it('creates a property returning a filtered array of children', function() {
          return expect(this.instanceRoot.childrenNamedB).toEqual([this.instanceB]);
        });
      });
      describe('adding a child using addCustomChild', function() {
        beforeEach(function() {
          this.instanceC = new this.testClass('c');
          return this.instanceRoot.addCustomChild(this.instanceC);
        });
        it('updates the children count', function() {
          return expect(this.instanceRoot.customChildrenSize).toEqual(3);
        });
        return describe('a second time', function() {
          beforeEach(function() {
            return this.instanceRoot.addCustomChild(this.instanceC);
          });
          return it('does not add the instance', function() {
            return expect(this.instanceRoot.customChildrenSize).toEqual(3);
          });
        });
      });
      describe('removing a child with removeCustomChild', function() {
        beforeEach(function() {
          return this.instanceRoot.removeCustomChild(this.instanceB);
        });
        return it('removes the child', function() {
          return expect(this.instanceRoot.customChildrenSize).toEqual(1);
        });
      });
      return describe('finding a child with findCustomChild', function() {
        it('returns the index of the child', function() {
          return expect(this.instanceRoot.findCustomChild(this.instanceB)).toEqual(1);
        });
        return describe('that is not present', function() {
          beforeEach(function() {
            return this.instanceC = new this.testClass('c');
          });
          return it('returns -1', function() {
            return expect(this.instanceRoot.findCustomChild(this.instanceC)).toEqual(-1);
          });
        });
      });
    });
  });

  describe('agt.mixins.HasNestedCollection', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
        TestClass.concern(agt.mixins.HasCollection('children', 'child'));

        TestClass.concern(agt.mixins.HasNestedCollection('descendants', {
          through: 'children'
        }));

        function TestClass(name, children) {
          this.name = name;
          this.children = children != null ? children : [];
        }

        return TestClass;

      })();
      this.instanceRoot = new this.testClass('root');
      this.instanceA = new this.testClass('a');
      this.instanceB = new this.testClass('b');
      this.instanceC = new this.testClass('c');
      this.instanceRoot.addChild(this.instanceA);
      this.instanceRoot.addChild(this.instanceB);
      return this.instanceA.addChild(this.instanceC);
    });
    it('returns all its descendants in a single array', function() {
      return expect(this.instanceRoot.descendants).toEqual([this.instanceA, this.instanceC, this.instanceB]);
    });
    return describe('using the descendantsScope method', function() {
      beforeEach(function() {
        return this.testClass.descendantsScope('descendantsNamedB', function(item) {
          return item.name === 'b';
        });
      });
      return it('creates a method returning a filtered array of descendants', function() {
        return expect(this.instanceRoot.descendantsNamedB).toEqual([this.instanceB]);
      });
    });
  });

  describe('agt.mixins.Memoizable', function() {
    beforeEach(function() {
      var TestClass;
      this.testClass = TestClass = (function() {
        TestClass.include(agt.mixins.Memoizable);

        function TestClass(a, b) {
          this.a = a != null ? a : 10;
          this.b = b != null ? b : 20;
        }

        TestClass.prototype.getObject = function() {
          var object;
          if (this.memoized('getObject')) {
            return this.memoFor('getObject');
          }
          object = {
            a: this.a,
            b: this.b,
            c: this.a + this.b
          };
          return this.memoize('getObject', object);
        };

        TestClass.prototype.memoizationKey = function() {
          return "" + this.a + ";" + this.b;
        };

        return TestClass;

      })();
      this.instance = new this.testClass;
      this.initial = this.instance.getObject();
      return this.secondCall = this.instance.getObject();
    });
    it('stores the result of the first call and return it in the second', function() {
      return expect(this.secondCall).toBe(this.initial);
    });
    return describe('when changing a property of the objet', function() {
      beforeEach(function() {
        return this.instance.a = 20;
      });
      return it('clears the memoized value', function() {
        return expect(this.instance.getObject()).not.toEqual(this.initial);
      });
    });
  });

  describe('agt.mixins.Parameterizable', function() {
    beforeEach(function() {
      var PartialTestClass, TestClass;
      TestClass = (function() {
        TestClass.include(agt.mixins.Parameterizable('instanceFrom', {
          x: 0,
          y: 0,
          name: 'Untitled'
        }));

        function TestClass(x, y, name) {
          this.x = x;
          this.y = y;
          this.name = name;
        }

        return TestClass;

      })();
      PartialTestClass = (function() {
        PartialTestClass.include(agt.mixins.Parameterizable('instanceFrom', {
          x: 0,
          y: 0,
          name: 'Untitled'
        }, true));

        function PartialTestClass(x, y, name) {
          this.x = x;
          this.y = y;
          this.name = name;
        }

        return PartialTestClass;

      })();
      this.testClass = TestClass;
      return this.partialTestClass = PartialTestClass;
    });
    it('creates a class method for instance creation', function() {
      expect(this.testClass.instanceFrom).toBeDefined();
      expect(this.partialTestClass.instanceFrom).toBeDefined();
      expect(this.testClass.instanceFrom(1, 1, 'foo')).toEqual({
        x: 1,
        y: 1,
        name: 'foo'
      });
      return expect(this.testClass.instanceFrom({
        x: 1,
        y: 1,
        name: 'foo'
      })).toEqual({
        x: 1,
        y: 1,
        name: 'foo'
      });
    });
    describe('with a non-partial class', function() {
      return it('falls back to the default values', function() {
        var instance;
        instance = this.testClass.instanceFrom(1);
        return expect(instance).toEqual({
          x: 1,
          y: 0,
          name: 'Untitled'
        });
      });
    });
    describe('with a partial class', function() {
      return it('does not fall back to the default values', function() {
        var instance;
        instance = this.partialTestClass.instanceFrom(1);
        return expect(instance).toEqual({
          x: 1
        });
      });
    });
    return describe('when the strict argument is true', function() {
      return it('raises an exception if one argument type mismatch', function() {
        return expect(function() {
          return this.testClass.instanceFrom(1, true);
        }).toThrow();
      });
    });
  });

  describe('agt.mixins.Poolable', function() {
    beforeEach(function() {
      var PoolableClass;
      return this.testClass = PoolableClass = (function() {
        function PoolableClass() {}

        PoolableClass.concern(agt.mixins.Poolable);

        return PoolableClass;

      })();
    });
    return describe('requesting two instances', function() {
      beforeEach(function() {
        this.instance1 = this.testClass.get({
          x: 10,
          y: 20
        });
        return this.instance2 = this.testClass.get({
          x: 20,
          y: 10
        });
      });
      it('creates two instances and returns them', function() {
        return expect(this.testClass.usedInstances.length).toEqual(2);
      });
      return describe('then disposing an instance', function() {
        beforeEach(function() {
          return this.instance2.dispose();
        });
        it('removes the instance from the used list', function() {
          return expect(this.testClass.usedInstances.length).toEqual(1);
        });
        it('adds the disposed instance in the unused list', function() {
          return expect(this.testClass.unusedInstances.length).toEqual(1);
        });
        return describe('then requesting another instance', function() {
          beforeEach(function() {
            return this.instance3 = this.testClass.get({
              x: 200,
              y: 100
            });
          });
          it('reuses a previously created instance', function() {
            expect(this.testClass.usedInstances.length).toEqual(2);
            expect(this.testClass.unusedInstances.length).toEqual(0);
            return expect(this.instance3).toBe(this.instance2);
          });
          return describe('then disposing all the instances', function() {
            beforeEach(function() {
              this.instance1.dispose();
              return this.instance3.dispose();
            });
            it('removes all the instances from the used list', function() {
              return expect(this.testClass.usedInstances.length).toEqual(0);
            });
            return it('adds these instances in the unused list', function() {
              return expect(this.testClass.unusedInstances.length).toEqual(2);
            });
          });
        });
      });
    });
  });

  describe('agt.mixins.Sourcable', function() {
    beforeEach(function() {
      var TestClass1, TestClass2;
      this.testClass1 = TestClass1 = (function() {
        TestClass1.include(agt.mixins.Sourcable('TestClass1', 'a', 'b'));

        function TestClass1(a, b) {
          this.a = a;
          this.b = b;
        }

        return TestClass1;

      })();
      this.testClass2 = TestClass2 = (function() {
        TestClass2.include(agt.mixins.Sourcable('TestClass2', 'a', 'b'));

        function TestClass2(a, b) {
          this.a = a;
          this.b = b;
        }

        return TestClass2;

      })();
      return this.instance = new this.testClass2([10, "o'foo"], new this.testClass1(10, 5));
    });
    return it('returns the source of the object', function() {
      return expect(this.instance.toSource()).toEqual("new TestClass2([10,'o\\'foo'],new TestClass1(10,5))");
    });
  });

  Rectangle = agt.geom.Rectangle;

  DieOnSurface = agt.particles.actions.DieOnSurface;

  Particle = agt.particles.Particle;

  describe('DieOnSurface', function() {
    return describe('when instanciated with a surface', function() {
      return it('should kill the particle on contact', function() {
        var action, particle;
        particle = new Particle;
        particle.init();
        action = new DieOnSurface(new Rectangle(1, 1, 10, 10));
        action.process(particle);
        expect(particle.dead).not.toBeTruthy();
        particle.position.x = 5;
        particle.position.y = 5;
        action.process(particle);
        return expect(particle.dead).toBeTruthy();
      });
    });
  });

  Point = agt.geom.Point;

  Particle = agt.particles.Particle;

  Force = agt.particles.actions.Force;

  describe('Force', function() {
    return describe('Created with a vector', function() {
      return it('should modify the particle velocity based on the vector', function() {
        var force, particle;
        particle = new Particle;
        particle.init();
        force = new Force(new Point(10, 10));
        force.prepare(500, 0.5, 500);
        force.process(particle);
        expect(particle.velocity.x).toBe(5);
        return expect(particle.velocity.y).toBe(5);
      });
    });
  });

  Particle = agt.particles.Particle;

  Friction = agt.particles.actions.Friction;

  describe('Friction', function() {
    return describe('when called with an amount', function() {
      return it('should apply friction to the particle velocity', function() {
        var friction, particle;
        particle = new Particle;
        particle.init();
        particle.velocity.x = 10;
        particle.velocity.y = 10;
        friction = new Friction(0.5);
        friction.prepare(500, 0.5, 500);
        friction.process(particle);
        expect(particle.velocity.x).toBe(7.5);
        return expect(particle.velocity.y).toBe(7.5);
      });
    });
  });

  Particle = agt.particles.Particle;

  Live = agt.particles.actions.Live;

  describe('Live::process', function() {
    return it('should increment the particle life by the amount of time spent', function() {
      var live, particle;
      live = new Live;
      particle = new Particle;
      particle.init();
      particle.maxLife = 100;
      live.prepare(500, 0.5, 500);
      live.process(particle);
      expect(particle.life).toBe(100);
      return expect(particle.dead).toBeTruthy();
    });
  });

  MacroAction = agt.particles.actions.MacroAction;

  Move = agt.particles.actions.Move;

  Live = agt.particles.actions.Live;

  Particle = agt.particles.Particle;

  describe('MacroAction', function() {
    return describe('when instanciated with several actions', function() {
      return it('should call these actions recursively', function() {
        var macro, particle;
        particle = new Particle;
        particle.init();
        particle.maxLife = 1000;
        particle.velocity.x = 100;
        particle.velocity.y = 100;
        macro = new MacroAction([new Move(), new Live()]);
        macro.prepare(100, 0.1, 100);
        macro.process(particle);
        expect(particle.position.x).toBe(10);
        expect(particle.position.y).toBe(10);
        return expect(particle.life).toBe(100);
      });
    });
  });

  Particle = agt.particles.Particle;

  Move = agt.particles.actions.Move;

  describe('Move', function() {
    return describe('when passed a particle', function() {
      return it('should update its position based on time and velocity', function() {
        var move, oldPos, particle;
        particle = new Particle;
        particle.init();
        particle.position.x = -100;
        particle.position.y = -100;
        oldPos = particle.position.clone();
        particle.velocity.x = 100;
        particle.velocity.y = 100;
        move = new Move;
        move.prepare(100, 0.1, 100);
        move.process(particle);
        expect(particle.position.x).toBe(-90);
        expect(particle.position.y).toBe(-90);
        expect(particle.lastPosition.x).toBe(oldPos.x);
        return expect(particle.lastPosition.y).toBe(oldPos.y);
      });
    });
  });

  ByRate = agt.particles.counters.ByRate;

  describe('ByRate', function() {
    var source;
    source = 'counter';
    return describe('when instanciated with a rate', function() {
      beforeEach(function() {
        return this.counter = new ByRate(10);
      });
      counter(source).count.shouldBe(0);
      byRateCounter(source).rate.shouldBe(10);
      byRateCounter(source).rest.shouldBe(0);
      return describe('when its prepare method is called', function() {
        beforeEach(function() {
          return this.counter.prepare(510, 0.51, 510);
        });
        counter(source).count.shouldBe(6);
        return byRateCounter(source).rest.shouldBe(0.1);
      });
    });
  });

  Fixed = agt.particles.counters.Fixed;

  describe('Fixed', function() {
    return describe('when instanciated with a value', function() {
      return it('should always return the same value', function() {
        var counter, value;
        value = 15;
        counter = new Fixed(value);
        counter.prepare(100, 0.1, 100);
        expect(counter.count).toBe(value);
        counter.prepare(400, 0.4, 500);
        return expect(counter.count).toBe(value);
      });
    });
  });

  Point = agt.geom.Point;

  Particle = agt.particles.Particle;

  Emission = agt.particles.Emission;

  Limited = agt.particles.timers.Limited;

  ByRate = agt.particles.counters.ByRate;

  Ponctual = agt.particles.emitters.Ponctual;

  Life = agt.particles.initializers.Life;

  describe('Emission', function() {
    return describe('when instanciated with all components', function() {
      beforeEach(function() {
        var counter, emitter, initializer, timer;
        this.emitter = emitter = new Ponctual(new Point);
        this.timer = timer = new Limited(1000);
        this.counter = counter = new ByRate(10);
        this.initializer = initializer = new Life(100);
        return this.emission = new Emission(Particle,  emitter, timer, counter, initializer);
      });
      it('should have stored the passed-in arguments', function() {
        expect(this.emission.particleType).toBe(Particle);
        expect(this.emission.emitter).toBe(this.emitter);
        expect(this.emission.timer).toBe(this.timer);
        expect(this.emission.counter).toBe(this.counter);
        return expect(this.emission.initializer).toBe(this.initializer);
      });
      return describe('when its prepare method is called', function() {
        beforeEach(function() {
          return this.emission.prepare(500, 0.5, 500);
        });
        it('should have setup the emission based on its components', function() {
          expect(this.emission.currentCount).toBe(6);
          return expect(this.emission.currentTime).toBe(500);
        });
        emission('emission').shouldBe.iterable(6);
        it('should not have finished', function() {
          return expect(this.emission.finished()).toBeFalsy();
        });
        describe('with a step that lead to the end of its time', function() {
          beforeEach(function() {
            return this.emission.prepare(500, 0.5, 500);
          });
          return it('should have finished', function() {
            return expect(this.emission.finished()).toBeTruthy();
          });
        });
        describe('its next method called in a loop', function() {
          return it('should return particles that have been initialized', function() {
            var e, max, n, particle, _results;
            e = this.emission;
            n = 0;
            max = 100;
            _results = [];
            while (e.hasNext()) {
              particle = e.next();
              expect(particle.maxLife).toBe(100);
              expect(particle.position.x).toBe(this.emitter.point.x);
              expect(particle.position.y).toBe(this.emitter.point.y);
              n++;
              if (n > max) {
                break;
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          });
        });
        return describe('its nextTime method called in a loop', function() {
          return it('should provides stepped time', function() {
            var e, max, n, _results;
            e = this.emission;
            n = 0;
            max = 100;
            _results = [];
            while (e.hasNext()) {
              time = e.nextTime();
              expect(time).toBe(e.currentTime - e.iterator / e.currentCount * e.currentTime);
              e.next();
              n++;
              if (n > max) {
                break;
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          });
        });
      });
    });
  });

  _ref = agt.geom, LinearSpline = _ref.LinearSpline, Point = _ref.Point;

  _ref1 = agt.random, Random = _ref1.Random, NoRandom = _ref1.NoRandom;

  Path = agt.particles.emitters.Path;

  describe('Path', function() {
    describe('when instanciated with a path and a randomizer', function() {
      beforeEach(function() {
        return this.emitter = new Path(new LinearSpline([new Point(0, 0), new Point(10, 0)]), new Random(new NoRandom(0.5)));
      });
      return it('should return a point of the path', function() {
        pt = this.emitter.get();
        expect(pt.x).toBe(5);
        return expect(pt.y).toBe(0);
      });
    });
    return describe('when instanciated without random', function() {
      return it('should set a default random object', function() {
        return expect(new Path().random).toBeDefined();
      });
    });
  });

  Point = agt.geom.Point;

  Ponctual = agt.particles.emitters.Ponctual;

  describe('Ponctual', function() {
    return describe('when instanciated with a point', function() {
      beforeEach(function() {
        return this.emitter = new Ponctual(new Point);
      });
      return describe('its get method', function() {
        return it('should return a copy of the specified point', function() {
          pt = this.emitter.get();
          expect(pt.x).toEqual(this.emitter.point.x);
          expect(pt.y).toEqual(this.emitter.point.y);
          return expect(pt).not.toBe(this.emitter.point);
        });
      });
    });
  });

  _ref2 = agt.random, Random = _ref2.Random, NoRandom = _ref2.NoRandom;

  Rectangle = agt.geom.Rectangle;

  Surface = agt.particles.emitters.Surface;

  describe('Surface', function() {
    describe('when instanciated with a surface and a randomizer', function() {
      beforeEach(function() {
        return this.emitter = new Surface(new Rectangle(0, 0, 10, 10), new Random(new NoRandom(0.5)));
      });
      return it('should return a point within the surface', function() {
        pt = this.emitter.get();
        expect(pt.x).toBe(5);
        return expect(pt.y).toBe(5);
      });
    });
    return describe('when instanciated without random', function() {
      return it('should set a default random object', function() {
        return expect(new Surface().random).toBeDefined();
      });
    });
  });

  _ref3 = agt.random, Random = _ref3.Random, NoRandom = _ref3.NoRandom;

  Explosion = agt.particles.initializers.Explosion;

  Particle = agt.particles.Particle;

  describe('Explosion', function() {
    describe('when instanciated with radii, full angle and random', function() {
      beforeEach(function() {
        this.initializer = new Explosion(0, 10, 0, 1, new Random(new NoRandom(0.5)));
        this.particle = new Particle;
        this.particle.init();
        return this.initializer.initialize(this.particle);
      });
      return it('should define the particle velocity', function() {
        expect(this.particle.velocity.x).toBe(Math.cos(0.5) * 5);
        return expect(this.particle.velocity.y).toBe(Math.sin(0.5) * 5);
      });
    });
    return describe('when instanciated without random', function() {
      return it('should set a default one', function() {
        return expect(new Explosion().random).toBeDefined();
      });
    });
  });

  _ref4 = agt.random, Random = _ref4.Random, NoRandom = _ref4.NoRandom;

  Particle = agt.particles.Particle;

  Life = agt.particles.initializers.Life;

  describe('Life', function() {
    describe('when instanciated with a life amount', function() {
      beforeEach(function() {
        return this.initializer = new Life(100);
      });
      return describe('and its initialize method is called with a particle', function() {
        beforeEach(function() {
          this.particle = new Particle();
          return this.initializer.initialize(this.particle);
        });
        return it('should have set the max life of the particle', function() {
          return expect(this.particle.maxLife).toBe(100);
        });
      });
    });
    return describe('when instanciated with a life range', function() {
      beforeEach(function() {
        return this.initializer = new Life(100, 200, new Random(new NoRandom(0.5)));
      });
      describe('and its initialize method is called with a particle', function() {
        beforeEach(function() {
          this.particle = new Particle();
          return this.initializer.initialize(this.particle);
        });
        return it('should have set the max life of the particle within the range', function() {
          return expect(this.particle.maxLife).toBe(150);
        });
      });
      return describe('when instanciated with nothing', function() {
        return it('should have set a default random object', function() {
          return expect(new Life().random).toBeDefined();
        });
      });
    });
  });

  _ref5 = agt.random, Random = _ref5.Random, NoRandom = _ref5.NoRandom;

  Particle = agt.particles.Particle;

  MacroInitializer = agt.particles.initializers.MacroInitializer;

  Life = agt.particles.initializers.Life;

  Explosion = agt.particles.initializers.Explosion;

  describe('MacroInitializer', function() {
    return describe('when instanciated with several initializers', function() {
      return it('should call them', function() {
        var initializer, particle;
        particle = new Particle;
        initializer = new MacroInitializer([new Life(100), new Explosion(0, 10, 0, 1, new Random(new NoRandom(0.5)))]);
        particle.init();
        initializer.initialize(particle);
        expect(particle.maxLife).toBe(100);
        expect(particle.velocity.x).toBe(Math.cos(0.5) * 5);
        return expect(particle.velocity.y).toBe(Math.sin(0.5) * 5);
      });
    });
  });

  Point = agt.geom.Point;

  Particle = agt.particles.Particle;

  Limited = agt.particles.timers.Limited;

  ByRate = agt.particles.counters.ByRate;

  Ponctual = agt.particles.emitters.Ponctual;

  Life = agt.particles.initializers.Life;

  Live = agt.particles.actions.Live;

  Emission = agt.particles.Emission;

  SubSystem = agt.particles.SubSystem;

  ParticleSubSystem = agt.particles.initializers.ParticleSubSystem;

  describe('ParticleSubSystem', function() {
    return describe('when instanciated with system components', function() {
      beforeEach(function() {
        var action, initializer;
        this.initializer = initializer = new Life(1000);
        this.action = action = new Live;
        return this.initializer = new ParticleSubSystem(initializer, action, function(p) {
          return new Emission(Particle, new Ponctual(p.position), new Limited(1000, 100), new ByRate(10));
        });
      });
      it('should have created a new sub system', function() {
        return expect(this.initializer.subSystem).toBeDefined();
      });
      return describe('when its initialize method is called', function() {
        beforeEach(function() {
          this.particle = new Particle;
          this.particle.init();
          this.particle.position.x = 10;
          this.particle.position.y = 10;
          return this.initializer.initialize(this.particle);
        });
        return it('should create a new emission for the given particle', function() {
          return expect(this.initializer.subSystem.emissions.length).toBe(1);
        });
      });
    });
  });

  Point = agt.geom.Point;

  Particle = agt.particles.Particle;

  describe('Particle', function() {
    beforeEach(function() {
      return this.particle = new Particle;
    });
    describe('when created', function() {
      it('should exist', function() {
        return expect(this.particle).toBeDefined();
      });
      return it('should not have any state', function() {
        expect(this.particle.life).toBeUndefined();
        expect(this.particle.dead).toBeUndefined();
        expect(this.particle.maxLife).toBeUndefined();
        expect(this.particle.velocity).toBeUndefined();
        expect(this.particle.position).toBeUndefined();
        expect(this.particle.lastPosition).toBeUndefined();
        return expect(this.particle.parasite).toBeUndefined();
      });
    });
    describe('when initialized', function() {
      beforeEach(function() {
        return this.particle.init();
      });
      return it('should have defined its default state', function() {
        expect(this.particle.dead).toBeFalsy();
        expect(this.particle.life).toBe(0);
        expect(this.particle.maxLife).toBe(0);
        expect(this.particle.velocity).toBeDefined();
        expect(this.particle.position).toBeDefined();
        expect(this.particle.lastPosition).toBeDefined();
        return expect(this.particle.parasite).toBeDefined();
      });
    });
    describe('when disposed', function() {
      beforeEach(function() {
        this.particle.init();
        return this.particle.dispose();
      });
      return it('should have nullified all its reference', function() {
        expect(this.particle.velocity).toBeNull();
        expect(this.particle.position).toBeNull();
        expect(this.particle.lastPosition).toBeNull();
        return expect(this.particle.parasite).toBeNull();
      });
    });
    describe('with a maxLife defined', function() {
      beforeEach(function() {
        return this.particle.maxLife = 1000;
      });
      describe('its die method', function() {
        beforeEach(function() {
          return this.particle.die();
        });
        it('should set the particle life to maxLife', function() {
          return expect(this.particle.life).toBe(this.particle.maxLife);
        });
        return it('should have set the dead flag to true', function() {
          return expect(this.particle.dead).toBeTruthy();
        });
      });
      return describe('when particle is dead', function() {
        beforeEach(function() {
          return this.particle.die();
        });
        return describe('its revive method', function() {
          beforeEach(function() {
            return this.particle.revive();
          });
          it('should reset the life of the particle', function() {
            return expect(this.particle.life).toBe(0);
          });
          return it('should have unset the dead flag', function() {
            return expect(this.particle.dead).toBeFalsy();
          });
        });
      });
    });
    return testPoolable(Particle)["with"]({
      life: 10,
      maxFile: 100,
      position: new Point(5, 6),
      lastPosition: new Point(7, 8),
      velocity: new Point(10, 11)
    });
  });

  Point = agt.geom.Point;

  Particle = agt.particles.Particle;

  Limited = agt.particles.timers.Limited;

  ByRate = agt.particles.counters.ByRate;

  Ponctual = agt.particles.emitters.Ponctual;

  Life = agt.particles.initializers.Life;

  Live = agt.particles.actions.Live;

  Emission = agt.particles.Emission;

  SubSystem = agt.particles.SubSystem;

  describe('SubSystem,', function() {
    var source;
    source = 'system';
    return describe('when instanciated with all its components,', function() {
      beforeEach(function() {
        var action, initializer;
        this.initializer = initializer = new Life(1000);
        this.action = action = new Live;
        return this.system = new SubSystem(initializer, action, function(particle) {
          return new Emission(Particle, new Ponctual(particle.position.clone()), new Limited(1000, 100), new ByRate(10));
        });
      });
      createListener();
      it('should exist', function() {
        expect(this.system).toBeDefined();
        expect(this.system.initializer).toBe(this.initializer);
        return expect(this.system.action).toBe(this.action);
      });
      system(source).shouldHave().signal('particlesCreated');
      system(source).shouldHave().signal('particlesDied');
      system(source).shouldHave().signal('emissionStarted');
      system(source).shouldHave().signal('emissionFinished');
      system(source).shouldHave(0).particles();
      system(source).shouldHave(0).emissions();
      return describe('when its emitFor method is called', function() {
        return describe('with a particle', function() {
          beforeEach(function() {
            this.source = new Particle;
            this.source.init();
            this.source.position.x = 10;
            this.source.position.y = 10;
            this.system.emitFor(this.source);
            return this.particle = this.system.particles[0];
          });
          afterEach(function() {
            return this.system.stop();
          });
          system(source).shouldHave(2).particles();
          system(source).shouldHave(1).emissions();
          system(source).shouldHave().dispatched('emissionStarted');
          system(source).shouldHave().dispatched('particlesCreated');
          system(source).shouldHave().started();
          system(source).should.emitting();
          particle('particle').maxLife.shouldBe(1000);
          particle('particle').life.shouldBe(100);
          describe('when animating the system until the emission end,', function() {
            beforeEach(function() {
              return animate(1000);
            });
            system(source).should.not.emitting();
            system(source).shouldHave(9).particles();
            system(source).shouldHave(0).emissions();
            system(source).shouldHave().dispatched('emissionFinished');
            return system(source).shouldHave().dispatched('particlesDied');
          });
          return describe('when adding a second emission after some time,', function() {
            return beforeEach(function() {
              animate(500);
              this.system.emit(new Emission(Particle));
              system(source).shouldHave(2).emissions();
              return describe('when animating past the life of the first emission,', function() {
                beforeEach(function() {
                  return animate(600);
                });
                return system(source).shouldHave(1).emissions();
              });
            });
          });
        });
      });
    });
  });

  Point = agt.geom.Point;

  Particle = agt.particles.Particle;

  Limited = agt.particles.timers.Limited;

  ByRate = agt.particles.counters.ByRate;

  Ponctual = agt.particles.emitters.Ponctual;

  Life = agt.particles.initializers.Life;

  Live = agt.particles.actions.Live;

  Emission = agt.particles.Emission;

  System = agt.particles.System;

  SubSystem = agt.particles.SubSystem;

  describe('System,', function() {
    var source, subSource;
    source = 'system';
    subSource = 'subSystem';
    return describe('when instanciated with all its components,', function() {
      beforeEach(function() {
        var action, initializer, subSystem;
        this.initializer = initializer = new Life(1000);
        this.action = action = new Live;
        this.subSystem = subSystem = new SubSystem(initializer, action, function(p) {
          return new Emission(Particle, new Ponctual(p.position), new Limited(1000, 100), new ByRate(10));
        });
        return this.system = new System(initializer, action, subSystem);
      });
      createListener();
      it('should exist', function() {
        expect(this.system).toBeDefined();
        expect(this.system.initializer).toBe(this.initializer);
        return expect(this.system.action).toBe(this.action);
      });
      system(source).shouldHave().signal('particlesCreated');
      system(source).shouldHave().signal('particlesDied');
      system(source).shouldHave().signal('emissionStarted');
      system(source).shouldHave().signal('emissionFinished');
      system(source).shouldHave(0).particles();
      system(source).shouldHave(0).emissions();
      return describe('when its emit method is called', function() {
        return describe('with an emission whose timer have since defined,', function() {
          beforeEach(function() {
            this.emission = new Emission(Particle, new Ponctual(new Point), new Limited(1000, 100), new ByRate(10));
            this.system.emit(this.emission);
            return this.particle = this.system.particles[0];
          });
          afterEach(function() {
            return this.system.stop();
          });
          system(source).shouldHave(2).particles();
          system(source).shouldHave(1).emissions();
          system(source).shouldHave().dispatched('emissionStarted');
          system(source).shouldHave().dispatched('particlesCreated');
          system(source).shouldHave().started();
          system(source).should.emitting();
          emission('emission').system.shouldBe(source);
          particle('particle').maxLife.shouldBe(1000);
          particle('particle').life.shouldBe(100);
          describe('when animating the system until the emission end,', function() {
            beforeEach(function() {
              return animate(1000);
            });
            system(source).should.not.emitting();
            system(source).shouldHave(10).particles();
            system(source).shouldHave(0).emissions();
            system(source).shouldHave().dispatched('emissionFinished');
            system(source).shouldHave().dispatched('particlesDied');
            system(subSource).shouldHave(4).particles();
            return system(subSource).shouldHave(2).emissions();
          });
          return describe('when adding a second emission after some time,', function() {
            return beforeEach(function() {
              animate(500);
              this.system.emit(new Emission(Particle));
              system(source).shouldHave(2).emissions();
              return describe('when animating past the life of the first emission,', function() {
                beforeEach(function() {
                  return animate(600);
                });
                return system(source).shouldHave(1).emissions();
              });
            });
          });
        });
      });
    });
  });

  Instant = agt.particles.timers.Instant;

  describe('Instant', function() {
    return describe('when instanciated', function() {
      return it('should already been finished', function() {
        var timer;
        timer = new Instant;
        expect(timer.nextTime()).toBe(0);
        return expect(timer.finished()).toBeTruthy();
      });
    });
  });

  Limited = agt.particles.timers.Limited;

  describe('Limited', function() {
    return describe('when instanciated with a duration of 1000', function() {
      var source;
      source = 'timer';
      beforeEach(function() {
        return this.timer = new Limited(1000);
      });
      timer(source).duration.shouldBe(1000);
      timer(source).since.shouldBe(0);
      timer(source).should.not.beFinished();
      timer(source).time.shouldBe(0);
      timer(source).nextTime.shouldBe(0);
      describe('its prepare method called', function() {
        describe('with a step that does not lead the timer to its end', function() {
          beforeEach(function() {
            return this.timer.prepare(500, 0.05, 500);
          });
          timer(source).should.not.beFinished();
          timer(source).time.shouldBe(500);
          return timer(source).nextTime.shouldBe(500);
        });
        return describe('with a step that lead to the timer end', function() {
          beforeEach(function() {
            return this.timer.prepare(1000, 1, 1000);
          });
          timer(source).should.beFinished();
          timer(source).time.shouldBe(1000);
          return timer(source).nextTime.shouldBe(1000);
        });
      });
      return describe('and a since value of 100', function() {
        beforeEach(function() {
          return this.timer = new Limited(1000, 100);
        });
        timer(source).duration.shouldBe(1000);
        timer(source).since.shouldBe(100);
        timer(source).should.not.beFinished();
        timer(source).time.shouldBe(0);
        timer(source).nextTime.shouldBe(0);
        return describe('its prepare method called', function() {
          describe('with a step that does not lead the timer to its end', function() {
            beforeEach(function() {
              return this.timer.prepare(500, 0.05, 500);
            });
            timer(source).should.not.beFinished();
            timer(source).time.shouldBe(500);
            return timer(source).nextTime.shouldBe(600);
          });
          return describe('with a step that lead to the timer end', function() {
            beforeEach(function() {
              return this.timer.prepare(1000, 1, 1000);
            });
            timer(source).should.beFinished();
            timer(source).time.shouldBe(1000);
            return timer(source).nextTime.shouldBe(1100);
          });
        });
      });
    });
  });

  UntilDeath = agt.particles.timers.UntilDeath;

  Particle = agt.particles.Particle;

  describe('UntilDeath', function() {
    return describe('when instanciated with a particle', function() {
      var source;
      source = 'timer';
      beforeEach(function() {
        this.particle = new Particle;
        this.particle.init();
        return this.timer = new UntilDeath(this.particle);
      });
      timer(source).should.not.beFinished();
      return describe('when animated until the particle died', function() {
        beforeEach(function() {
          this.timer.prepare(500, 0.5, 500);
          return this.particle.die();
        });
        return timer(source).should.beFinished();
      });
    });
  });

  round = Math.round, floor = Math.floor;

  describe('with a Random instance', function() {
    beforeEach(function() {
      this.random = new agt.random.Random(new agt.random.Linear(10));
      return this.callMethod = function() {
        var args, block, method, random, _i;
        method = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), block = arguments[_i++];
        random = new agt.random.Random(new agt.random.Linear(10));
        return withLoop.call(this, function(n) {
          return expect(random[method].apply(random, args)).toBe(block.call(this, n));
        });
      };
    });
    describe('calling Random#get', function() {
      return it('returns the generator value unchanged', function() {
        return this.callMethod('get', function(n) {
          return (n % 11) / 10;
        });
      });
    });
    describe('calling Random#random', function() {
      it('returns a value from 0 to the passed-in value', function() {
        return this.callMethod('random', 10, function(n) {
          return n % 11;
        });
      });
      return it('returns the generator value when called without value', function() {
        return this.callMethod('random', function(n) {
          return (n % 11) / 10;
        });
      });
    });
    describe('calling Random#intRandom', function() {
      it('returns an int from 0 to the passed-in value', function() {
        return this.callMethod('intRandom', 5, function(n) {
          return round((n % 11) / 2);
        });
      });
      return it('returns the floored generator value when called without arg', function() {
        return this.callMethod('intRandom', function(n) {
          return round((n % 11) / 10);
        });
      });
    });
    describe('calling Random#pad', function() {
      return it('returns a value around 0', function() {
        return this.callMethod('pad', 10, function(n) {
          return 5 - (n % 11);
        });
      });
    });
    describe('calling Random#intPad', function() {
      return it('returns a value around 0', function() {
        return this.callMethod('intPad', 5, function(n) {
          return round(2.5 - (n % 11) / 2);
        });
      });
    });
    describe('calling Random#boolean', function() {
      describe('with a float between 0 or 1', function() {
        return it('returns a boolean value according to the rate', function() {
          return this.callMethod('boolean', 0.2, function(n) {
            return (n % 11) / 10 < 0.2;
          });
        });
      });
      describe('with no arguments', function() {
        return it('returns a boolean with a default rate of 0.5', function() {
          return this.callMethod('boolean', function(n) {
            return (n % 11) / 10 < 0.5;
          });
        });
      });
      return describe('with values outside of the 0-1 range', function() {
        return it('returns a boolean with a default rate of 0.5', function() {
          this.callMethod('boolean', -1, function(n) {
            return (n % 11) / 10 < 0.5;
          });
          return this.callMethod('boolean', 2, function(n) {
            return (n % 11) / 10 < 0.5;
          });
        });
      });
    });
    describe('calling Random#char', function() {
      describe('with a string as argument', function() {
        return it('returns a char in the range', function() {
          return this.callMethod('char', 'abcdefghijk', function(n) {
            return 'abcdefghijk'.substr(n % 11, 1);
          });
        });
      });
      describe('with two strings as arguments', function() {
        return it('returns a char in the range defined by the first char of each strings', function() {
          return this.callMethod('char', 'a', 'k', function(n) {
            return 'abcdefghijk'.substr(n % 11, 1);
          });
        });
      });
      describe('with a number as argument', function() {
        return it('returns a char in the unicode range from 0 to the argument', function() {
          return this.callMethod('char', 10, function(n) {
            return String.fromCharCode(round(n % 11));
          });
        });
      });
      describe('with two numbers as arguments', function() {
        return it('returns a char in the unicode range from start to the end', function() {
          return this.callMethod('char', 10, 20, function(n) {
            return String.fromCharCode(round(10 + (n % 11)));
          });
        });
      });
      return describe('with no arguments', function() {
        return it('returns a char from the latin alphabet', function() {
          return this.callMethod('char', function(n) {
            return 'abcdefghijklmnopqrstuvwxyz'.substr(round((n % 11) / 10 * 25), 1);
          });
        });
      });
    });
    describe('calling Random#inArray', function() {
      it('returns of the value within the passed-in array', function() {
        return this.callMethod('inArray', [0, 1, 2, 3, 4, 5], function(n) {
          return round((n % 11) / 2);
        });
      });
      it('returns null whe no argument is passed', function() {
        return this.callMethod('inArray', function(n) {
          return null;
        });
      });
      describe('with an array and ratios', function() {
        it('returns a value according to the ratios', function() {
          return this.callMethod('inArray', [0, 1], [1, 3], function(n) {
            var a;
            a = [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1];
            return a[n % 11];
          });
        });
        return it('raises an error if the array and ratios length does not match', function() {
          return expect((function(_this) {
            return function() {
              return _this.random.inArray([0, 1], [0]);
            };
          })(this)).toThrow();
        });
      });
      return describe('with an array and summed ratios', function() {
        it('returns a value according to the ratios', function() {
          return this.callMethod('inArray', [0, 1], [1, 4], true, function(n) {
            var a;
            a = [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1];
            return a[n % 11];
          });
        });
        return it('raises an error if ratios are not ordered', function() {
          return expect((function(_this) {
            return function() {
              return _this.random.inArray([0, 1], [4, 1], true);
            };
          })(this)).toThrow();
        });
      });
    });
    describe('calling Random#in', function() {
      describe('with an array as first argument', function() {
        it('returns of the value within the passed-in array', function() {
          return this.callMethod('in', [0, 1, 2, 3, 4, 5], function(n) {
            return round((n % 11) / 2);
          });
        });
        it('returns null whe no argument is passed', function() {
          return this.callMethod('in', function(n) {
            return null;
          });
        });
        describe('with a ratios array as second argument', function() {
          it('returns a value according to the ratios', function() {
            return this.callMethod('in', [0, 1], [1, 3], function(n) {
              var a;
              a = [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1];
              return a[n % 11];
            });
          });
          return it('raises an error if the array and ratios length does not match', function() {
            return expect((function(_this) {
              return function() {
                return _this.random["in"]([0, 1], [0]);
              };
            })(this)).toThrow();
          });
        });
        return describe('with a summed ratios array as second argument', function() {
          it('returns a value according to the ratios', function() {
            return this.callMethod('in', [0, 1], [1, 4], true, function(n) {
              var a;
              a = [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1];
              return a[n % 11];
            });
          });
          return it('raises an error if ratios are not ordered', function() {
            return expect((function(_this) {
              return function() {
                return _this.random["in"]([0, 1], [4, 1], true);
              };
            })(this)).toThrow();
          });
        });
      });
      describe('with a string as first argument', function() {
        return it('returns a char within the string', function() {
          return this.callMethod('in', 'abcdefghijk', function(n) {
            return 'abcdefghijk'.substr(n % 11, 1);
          });
        });
      });
      describe('with numbers as arguments', function() {
        return it('returns a number within the range defined by the numbers', function() {
          return this.callMethod('in', 10, 20, function(n) {
            return 10 + (n % 11);
          });
        });
      });
      describe('with a list of arguments', function() {
        return it('returns one of the arguments', function() {
          return this.callMethod('in', 0, 1, 2, 3, 4, 5, function(n) {
            return round((n % 11) / 2);
          });
        });
      });
      describe('with a range object', function() {
        return it('returns a number within the range', function() {
          return this.callMethod('in', {
            min: 10,
            max: 20
          }, function(n) {
            return 10 + (n % 11);
          });
        });
      });
      return describe('with a range object and a step', function() {
        return it('returns a number within the range rounded to the step', function() {
          return this.callMethod('in', {
            min: 1,
            max: 2,
            step: 0.2
          }, function(n) {
            var a;
            a = [1, 1, 1.2, 1.2, 1.4, 1.4, 1.6, 1.6, 1.8, 1.8, 2];
            return a[n % 11];
          });
        });
      });
    });
    describe('calling Random#bit', function() {
      describe('with a float between 0 or 1', function() {
        return it('returns a 0 or a 1 value according to the rate', function() {
          return this.callMethod('bit', 0.2, function(n) {
            if ((n % 11) / 10 < 0.2) {
              return 1;
            } else {
              return 0;
            }
          });
        });
      });
      describe('with no arguments', function() {
        return it('returns a 0 or a 1 with a default rate of 0.5', function() {
          return this.callMethod('bit', function(n) {
            if ((n % 11) / 10 < 0.5) {
              return 1;
            } else {
              return 0;
            }
          });
        });
      });
      return describe('with values outside of the 0-1 range', function() {
        return it('returns a 0 or a 1 with a default rate of 0.5', function() {
          this.callMethod('bit', -1, function(n) {
            if ((n % 11) / 10 < 0.5) {
              return 1;
            } else {
              return 0;
            }
          });
          return this.callMethod('bit', 2, function(n) {
            if ((n % 11) / 10 < 0.5) {
              return 1;
            } else {
              return 0;
            }
          });
        });
      });
    });
    describe('calling Random#sign', function() {
      describe('with a float between 0 or 1', function() {
        return it('returns -1 or 1 value according to the rate', function() {
          return this.callMethod('sign', 0.2, function(n) {
            if ((n % 11) / 10 < 0.2) {
              return 1;
            } else {
              return -1;
            }
          });
        });
      });
      describe('with no arguments', function() {
        return it('returns -1 or 1 with a default rate of 0.5', function() {
          return this.callMethod('sign', function(n) {
            if ((n % 11) / 10 < 0.5) {
              return 1;
            } else {
              return -1;
            }
          });
        });
      });
      return describe('with values outside of the 0-1 range', function() {
        return it('returns -1 or 1 with a default rate of 0.5', function() {
          this.callMethod('sign', -1, function(n) {
            if ((n % 11) / 10 < 0.5) {
              return 1;
            } else {
              return -1;
            }
          });
          return this.callMethod('sign', 2, function(n) {
            if ((n % 11) / 10 < 0.5) {
              return 1;
            } else {
              return -1;
            }
          });
        });
      });
    });
    return describe('calling Random::sort', function() {
      return it('returns a function that return either -1, 0 or 1', function() {
        var a, f, n, _i, _results;
        f = this.random.sort();
        a = [1, 1, 1, 0, 0, 0, 0, 0, -1, -1, -1];
        _results = [];
        for (n = _i = 0; _i <= 20; n = ++_i) {
          _results.push(expect(f(n)).toBe(a[n % 11]));
        }
        return _results;
      });
    });
  });

  describe('Signal', function() {
    it('has listeners', function() {
      var listener, signal;
      signal = new agt.Signal;
      listener = function() {};
      signal.add(listener);
      return expect(signal.listeners.length).toBe(1);
    });
    it('dispatchs message to its listeners', function() {
      var listener, message, signal;
      message = null;
      signal = new agt.Signal;
      listener = function() {
        return message = arguments[0];
      };
      signal.add(listener);
      signal.dispatch("hello");
      return expect(message).toBe("hello");
    });
    it('does not add the same listener twice', function() {
      var listener, signal;
      signal = new agt.Signal;
      listener = function() {};
      signal.add(listener);
      signal.add(listener);
      return expect(signal.listeners.length).toBe(1);
    });
    it('allows to remove listeners', function() {
      var listener, signal;
      signal = new agt.Signal;
      listener = function() {};
      signal.add(listener);
      signal.remove(listener);
      return expect(signal.listeners.length).toBe(0);
    });
    it('allows to register a listener with a context', function() {
      var context, listener, listenerScope, signal;
      signal = new agt.Signal;
      context = {};
      listenerScope = null;
      listener = function() {
        return listenerScope = this;
      };
      signal.add(listener, context);
      signal.dispatch("hello");
      return expect(listenerScope).toBe(context);
    });
    it('allows to register a same listener twice with different context', function() {
      var context1, context2, listener, signal;
      signal = new agt.Signal;
      context1 = {};
      context2 = {};
      listener = function() {};
      signal.add(listener, context1);
      signal.add(listener, context2);
      return expect(signal.listeners.length).toBe(2);
    });
    it('allows to remove a listener bind with a context', function() {
      var context1, context2, lastCall, listener, signal;
      signal = new agt.Signal;
      context1 = {
        foo: "Foo"
      };
      context2 = {
        foo: "Bar"
      };
      lastCall = null;
      listener = function() {
        return lastCall = this.foo;
      };
      signal.add(listener, context1);
      signal.add(listener, context2);
      signal.remove(listener, context1);
      signal.dispatch();
      expect(signal.listeners.length).toBe(1);
      return expect(lastCall).toBe("Bar");
    });
    it('allows to register a listener for a single call', function() {
      var callCount, listener, signal;
      signal = new agt.Signal;
      callCount = 0;
      listener = function() {
        return callCount++;
      };
      signal.addOnce(listener);
      signal.dispatch();
      signal.dispatch();
      return expect(callCount).toBe(1);
    });
    it('priorizes listeners', function() {
      var listener1, listener2, listenersCalls, signal;
      signal = new agt.Signal;
      listenersCalls = [];
      listener1 = function() {
        return listenersCalls.push("listener1");
      };
      listener2 = function() {
        return listenersCalls.push("listener2");
      };
      signal.add(listener1);
      signal.add(listener2, null, 1);
      signal.dispatch();
      return expect(listenersCalls).toEqual(["listener2", "listener1"]);
    });
    it('allows listeners registered for a single call to have a priority', function() {
      var listener1, listener2, listenersCalls, signal;
      signal = new agt.Signal;
      listenersCalls = [];
      listener1 = function() {
        return listenersCalls.push("listener1");
      };
      listener2 = function() {
        return listenersCalls.push("listener2");
      };
      signal.add(listener1);
      signal.addOnce(listener2, null, 1);
      signal.dispatch();
      return expect(listenersCalls).toEqual(["listener2", "listener1"]);
    });
    it('removes all listeners at once', function() {
      var listener1, listener2, signal;
      signal = new agt.Signal;
      listener1 = function() {};
      listener2 = function() {};
      signal.add(listener1);
      signal.add(listener2);
      signal.removeAll();
      return expect(signal.listeners.length).toBe(0);
    });
    it('tells when listeners are registered', function() {
      var listener, signal;
      signal = new agt.Signal;
      expect(signal.hasListeners()).toBeFalsy();
      listener = function() {};
      signal.add(listener);
      return expect(signal.hasListeners()).toBeTruthy();
    });
    describe('with an asynchronous listener', function() {
      it('waits until the callback was called before going to the next listener', function(done) {
        var ended, listener1, listener1Args, listener1Called, listener2, listener2Args, signal;
        listener1Called = false;
        listener1Args = null;
        listener2Args = null;
        ended = false;
        listener1 = function(a, b, c, callback) {
          return setTimeout(function() {
            listener1Args = [a, b, c];
            listener1Called = true;
            return typeof callback === "function" ? callback() : void 0;
          }, 100);
        };
        listener2 = function(a, b, c) {
          listener2Args = [a, b, c];
          expect(listener1Called).toBeTruthy();
          expect(listener1Args).toEqual(listener2Args);
          return done();
        };
        signal = new agt.Signal;
        signal.add(listener1);
        signal.add(listener2);
        return signal.dispatch(1, 2, 3);
      });
      return it('calls back the passed-in function at the end of the dispatch', function(done) {
        var ended, listener1, listener2, ms, signal;
        ended = false;
        listener1 = function(a, b, c, callback) {
          return setTimeout(callback, 120);
        };
        listener2 = function(a, b, c, callback) {
          return setTimeout(callback, 120);
        };
        signal = new agt.Signal;
        signal.add(listener1);
        signal.add(listener2);
        ms = new Date().valueOf();
        return signal.dispatch(1, 2, 3, function() {
          return done();
        });
      });
    });
    return describe('when a listener signature have been specified', function() {
      return it('prevents invalid listener to be passed', function() {
        var signal;
        signal = new agt.Signal('a', 'b');
        expect(function() {
          return signal.add(function() {});
        }).toThrow();
        expect(function() {
          return signal.addOnce(function() {});
        }).toThrow();
        expect(function() {
          return signal.add(function(a, b) {});
        }).not.toThrow();
        return expect(function() {
          return signal.add(function(a, b, callback) {});
        }).not.toThrow();
      });
    });
  });

}).call(this);
