(function() {
  var DEFAULT_RANDOM, DEFAULT_UNGLOBALIZABLE, Ellipsis, Geometry, Impulse, Intersections, MathRandom, NullAction, NullCounter, NullEmitter, NullInitializer, NullTimer, Particle, Path, Point, Proxyable, Random, Signal, Spline, Surface, Triangle, Triangulable, agt, build, exports, findCaller, floor, g, geom, isCommonJS, mixins, net, particles, random, registerSuper, requestAnimFrame, round, _ref, _ref1, _ref10, _ref11, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  isCommonJS = typeof module !== "undefined";

  agt = {};

  agt.mixins = mixins = {};

  agt.random = random = {};

  agt.geom = geom = {};

  agt.net = net = {};

  agt.particles = particles = {
    actions: {},
    emitters: {},
    timers: {},
    counters: {},
    initializers: {}
  };

  if (isCommonJS) {
    exports = module.exports = agt;
  } else {
    exports = window.agt = agt;
  }

  agt.CAMEL_CASE = 'camel';

  agt.SNAKE_CASE = 'snake';

  agt.COLORS = {
    STROKE: '#ff0000',
    FILL: 'rgba(255,0,0,0.5)',
    VERTICES: '#0077ff',
    VERTICES_CONNECTIONS: 'rgba(0,127,255,0.5)',
    BOUNDING_BOX: '#69af23'
  };

  agt.deprecated = function(message) {
    var caller, deprecatedMethodCallerFile, deprecatedMethodCallerName, e, parseLine, s, _ref;
    parseLine = function(line) {
      var f, m, o, _ref, _ref1, _ref2, _ref3;
      if (line.indexOf('@') > 0) {
        if (line.indexOf('</') > 0) {
          _ref = /<\/([^@]+)@(.)+$/.exec(line), m = _ref[0], o = _ref[1], f = _ref[2];
        } else {
          _ref1 = /@(.)+$/.exec(line), m = _ref1[0], f = _ref1[1];
        }
      } else {
        if (line.indexOf('(') > 0) {
          _ref2 = /at\s+([^\s]+)\s*\(([^\)])+/.exec(line), m = _ref2[0], o = _ref2[1], f = _ref2[2];
        } else {
          _ref3 = /at\s+([^\s]+)/.exec(line), m = _ref3[0], f = _ref3[1];
        }
      }
      return [o, f];
    };
    e = new Error();
    caller = '';
    if (e.stack != null) {
      s = e.stack.split('\n');
      _ref = parseLine(s[3]), deprecatedMethodCallerName = _ref[0], deprecatedMethodCallerFile = _ref[1];
      caller = deprecatedMethodCallerName ? " (called from " + deprecatedMethodCallerName + " at " + deprecatedMethodCallerFile + ")" : "(called from " + deprecatedMethodCallerFile + ")";
    }
    return console.log("DEPRECATION WARNING: " + message + caller);
  };

  if (Object.getPropertyDescriptor == null) {
    if ((Object.getPrototypeOf != null) && (Object.getOwnPropertyDescriptor != null)) {
      Object.getPropertyDescriptor = function(o, name) {
        var descriptor, proto;
        proto = o;
        descriptor = void 0;
        while (proto && !(descriptor = Object.getOwnPropertyDescriptor(proto, name))) {
          proto = (typeof Object.getPrototypeOf === "function" ? Object.getPrototypeOf(proto) : void 0) || proto.__proto__;
        }
        return descriptor;
      };
    } else {
      Object.getPropertyDescriptor = function() {
        return void 0;
      };
    }
  }


  /* Public */

  Function.prototype.def = function(name, block) {
    Object.defineProperty(this.prototype, name, {
      value: block,
      configurable: true,
      enumerable: false
    });
    return this;
  };

  Function.prototype.accessor = function(name, options) {
    var oldDescriptor;
    oldDescriptor = Object.getPropertyDescriptor(this.prototype, name);
    if (oldDescriptor != null) {
      options.get || (options.get = oldDescriptor.get);
    }
    if (oldDescriptor != null) {
      options.set || (options.set = oldDescriptor.set);
    }
    Object.defineProperty(this.prototype, name, {
      get: options.get,
      set: options.set,
      configurable: true,
      enumerable: true
    });
    return this;
  };

  Function.prototype.getter = function(name, block) {
    return this.accessor(name, {
      get: block
    });
  };

  Function.prototype.setter = function(name, block) {
    return this.accessor(name, {
      set: block
    });
  };

  registerSuper = function(key, value, klass, sup, mixin) {
    if ((value.__included__ != null) && __indexOf.call(value.__included__, klass) >= 0) {
      return;
    }
    value.__super__ || (value.__super__ = []);
    value.__super__.push(sup);
    value.__included__ || (value.__included__ = []);
    value.__included__.push(klass);
    return value.__name__ = "" + mixin.name + "::" + key;
  };

  Function.prototype.include = function() {
    var bothHaveGet, bothHaveSet, bothHaveValue, excl, excluded, k, keys, mixin, mixins, newDescriptor, newHasAccessor, oldDescriptor, oldHasAccessor, _i, _j, _len, _len1;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    excluded = ['constructor', 'excluded', 'super'];
    this.__mixins__ || (this.__mixins__ = []);
    this.__super__ || (this.__super__ = {});
    this.__super__ = Object.create(this.__super__);
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      this.__mixins__.push(mixin);
      excl = excluded.concat();
      if (mixin.prototype.excluded != null) {
        excl = excl.concat(mixin.prototype.excluded);
      }
      keys = Object.keys(mixin.prototype);
      for (_j = 0, _len1 = keys.length; _j < _len1; _j++) {
        k = keys[_j];
        if (__indexOf.call(excl, k) < 0) {
          oldDescriptor = Object.getPropertyDescriptor(this.prototype, k);
          newDescriptor = Object.getPropertyDescriptor(mixin.prototype, k);
          if ((oldDescriptor != null) && (newDescriptor != null)) {
            oldHasAccessor = (oldDescriptor.get != null) || (oldDescriptor.set != null);
            newHasAccessor = (newDescriptor.get != null) || (newDescriptor.set != null);
            bothHaveGet = (oldDescriptor.get != null) && (newDescriptor.get != null);
            bothHaveSet = (oldDescriptor.set != null) && (newDescriptor.set != null);
            bothHaveValue = (oldDescriptor.value != null) && (newDescriptor.value != null);
            if (oldHasAccessor && newHasAccessor) {
              if (bothHaveGet) {
                registerSuper(k, newDescriptor.get, this, oldDescriptor.get, mixin);
              }
              if (bothHaveSet) {
                registerSuper(k, newDescriptor.set, this, oldDescriptor.set, mixin);
              }
              newDescriptor.get || (newDescriptor.get = oldDescriptor.get);
              newDescriptor.set || (newDescriptor.set = oldDescriptor.set);
            } else if (bothHaveValue) {
              registerSuper(k, newDescriptor.value, this, oldDescriptor.value, mixin);
            } else {
              throw new Error("Can't mix accessors and plain values inheritance");
            }
            Object.defineProperty(this.__super__, k, newDescriptor);
          } else if (newDescriptor != null) {
            this.__super__[k] = mixin[k];
          } else if (oldDescriptor != null) {
            Object.defineProperty(this.__super__, k, newDescriptor);
          } else if (this.prototype[k] != null) {
            registerSuper(k, mixin[k], this, this.prototype[k], mixin);
            this.__super__[k] = mixin[k];
          }
          if (newDescriptor != null) {
            Object.defineProperty(this.prototype, k, newDescriptor);
          } else {
            this.prototype[k] = mixin.prototype[k];
          }
        }
      }
      if (typeof mixin.included === "function") {
        mixin.included(this);
      }
    }
    return this;
  };

  Function.prototype.extend = function() {
    var bothHaveGet, bothHaveSet, bothHaveValue, excl, excluded, k, keys, mixin, mixins, newDescriptor, newHasAccessor, oldDescriptor, oldHasAccessor, _i, _j, _len, _len1;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    excluded = ['extended', 'excluded', 'included'];
    this.__mixins__ || (this.__mixins__ = []);
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      this.__mixins__.push(mixin);
      excl = excluded.concat();
      if (mixin.excluded != null) {
        excl = excl.concat(mixin.excluded);
      }
      keys = Object.keys(mixin);
      for (_j = 0, _len1 = keys.length; _j < _len1; _j++) {
        k = keys[_j];
        if (__indexOf.call(excl, k) < 0) {
          oldDescriptor = Object.getPropertyDescriptor(this, k);
          newDescriptor = Object.getPropertyDescriptor(mixin, k);
          if ((oldDescriptor != null) && (newDescriptor != null)) {
            oldHasAccessor = (oldDescriptor.get != null) || (oldDescriptor.set != null);
            newHasAccessor = (newDescriptor.get != null) || (newDescriptor.set != null);
            bothHaveGet = (oldDescriptor.get != null) && (newDescriptor.get != null);
            bothHaveSet = (oldDescriptor.set != null) && (newDescriptor.set != null);
            bothHaveValue = (oldDescriptor.value != null) && (newDescriptor.value != null);
            if (oldHasAccessor && newHasAccessor) {
              if (bothHaveGet) {
                registerSuper(k, newDescriptor.get, this, oldDescriptor.get, mixin);
              }
              if (bothHaveSet) {
                registerSuper(k, newDescriptor.set, this, oldDescriptor.set, mixin);
              }
              newDescriptor.get || (newDescriptor.get = oldDescriptor.get);
              newDescriptor.set || (newDescriptor.set = oldDescriptor.set);
            } else if (bothHaveValue) {
              registerSuper(k, newDescriptor.value, this, oldDescriptor.value, mixin);
            } else {
              throw new Error("Can't mix accessors and plain values inheritance");
            }
          }
          if (newDescriptor != null) {
            Object.defineProperty(this, k, newDescriptor);
          } else {
            this[k] = mixin[k];
          }
        }
      }
      if (typeof mixin.extended === "function") {
        mixin.extended(this);
      }
    }
    return this;
  };

  Function.prototype.concern = function() {
    var mixins;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.include.apply(this, mixins);
    return this.extend.apply(this, mixins);
  };

  findCaller = function(caller, proto) {
    var descriptor, k, keys, _i, _len;
    keys = Object.keys(proto);
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      k = keys[_i];
      descriptor = Object.getPropertyDescriptor(proto, k);
      if (descriptor != null) {
        if (descriptor.value === caller) {
          return {
            key: k,
            descriptor: descriptor,
            kind: 'value'
          };
        }
        if (descriptor.get === caller) {
          return {
            key: k,
            descriptor: descriptor,
            kind: 'get'
          };
        }
        if (descriptor.set === caller) {
          return {
            key: k,
            descriptor: descriptor,
            kind: 'set'
          };
        }
      } else {
        if (proto[k] === caller) {
          return {
            key: k
          };
        }
      }
    }
    return {};
  };

  if (Object.prototype["super"] == null) {
    Object.defineProperty(Object.prototype, 'super', {
      enumerable: false,
      configurable: true,
      value: function() {
        var args, caller, desc, key, kind, value, _ref, _ref1;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        caller = (_ref = arguments.caller) != null ? _ref : this["super"].caller;
        if (caller != null) {
          if (caller.__super__ != null) {
            value = caller.__super__[caller.__included__.indexOf(this.constructor)];
            if (value != null) {
              if (typeof value === 'function') {
                return value.apply(this, args);
              } else {
                throw new Error("The super for " + caller._name + " isn't a function");
              }
            } else {
              throw new Error("No super method for " + caller._name);
            }
          } else {
            _ref1 = findCaller(caller, this.constructor.prototype), key = _ref1.key, kind = _ref1.kind;
            if (key != null) {
              desc = Object.getPropertyDescriptor(this.constructor.__super__, key);
              if (desc != null) {
                value = desc[kind].apply(this, args);
              } else {
                value = this.constructor.__super__[key].apply(this, args);
              }
              return value;
            } else {
              throw new Error("No super method for " + (caller.name || caller._name));
            }
          }
        } else {
          throw new Error("Super called with a caller");
        }
      }
    });
    Object.defineProperty(Function.prototype, 'super', {
      enumerable: false,
      configurable: true,
      value: function() {
        var args, caller, desc, key, kind, m, mixin, reverseMixins, value, _i, _j, _len, _len1, _ref, _ref1;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        caller = arguments.caller || this["super"].caller;
        if (caller != null) {
          if (caller.__super__ != null) {
            value = caller.__super__[caller.__included__.indexOf(this)];
            if (value != null) {
              if (typeof value === 'function') {
                return value.apply(this, args);
              } else {
                throw new Error("The super for " + caller._name + " isn't a function");
              }
            } else {
              throw new Error("No super method for " + caller._name);
            }
          } else {
            _ref = findCaller(caller, this), key = _ref.key, kind = _ref.kind;
            reverseMixins = [];
            _ref1 = this.__mixins__;
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              m = _ref1[_i];
              reverseMixins.unshift(m);
            }
            if (key != null) {
              for (_j = 0, _len1 = reverseMixins.length; _j < _len1; _j++) {
                m = reverseMixins[_j];
                if (m[key] != null) {
                  mixin = m;
                  break;
                }
              }
              desc = Object.getPropertyDescriptor(mixin, key);
              if (desc != null) {
                value = desc[kind].apply(this, args);
              } else {
                value = mixin[key].apply(this, args);
              }
              return value;
            } else {
              throw new Error("No super class method for " + (caller.name || caller._name));
            }
          }
        } else {
          throw new Error("super called without a caller");
        }
      }
    });
  }

  Math.PI2 = Math.PI * 2;

  Math.PI_2 = Math.PI / 2;

  Math.PI_4 = Math.PI / 4;

  Math.PI_8 = Math.PI / 8;


  /* Public */

  Math.degToRad = function(n) {
    return n * Math.PI / 180;
  };

  Math.radToDeg = function(n) {
    return n * 180 / Math.PI;
  };

  Math.normalize = function(value, minimum, maximum) {
    return (value - minimum) / (maximum - minimum);
  };

  Math.interpolate = function(normValue, minimum, maximum) {
    return minimum + (maximum - minimum) * normValue;
  };

  Math.deltaBelowRatio = function(a, b, ratio) {
    if (ratio == null) {
      ratio = 10000000000;
    }
    return Math.abs(a - b) < 1 / ratio;
  };

  Math.map = function(value, min1, max1, min2, max2) {
    return Math.interpolate(Math.normalize(value, min1, max1), min2, max2);
  };

  Math.isFloat = function() {
    var float, floats, _i, _len;
    floats = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (_i = 0, _len = floats.length; _i < _len; _i++) {
      float = floats[_i];
      if (isNaN(parseFloat(float))) {
        return false;
      }
    }
    return true;
  };

  Math.isInt = function() {
    var int, ints, _i, _len;
    ints = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (_i = 0, _len = ints.length; _i < _len; _i++) {
      int = ints[_i];
      if (isNaN(parseInt(int))) {
        return false;
      }
    }
    return true;
  };

  Math.asFloat = function() {
    var floats, i, n, _i, _len;
    floats = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (i = _i = 0, _len = floats.length; _i < _len; i = ++_i) {
      n = floats[i];
      floats[i] = parseFloat(n);
    }
    return floats;
  };

  Math.asInt = function() {
    var i, ints, n, _i, _len;
    ints = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (i = _i = 0, _len = ints.length; _i < _len; i = ++_i) {
      n = ints[i];
      ints[i] = parseInt(n);
    }
    return ints;
  };

  agt.Signal = (function() {

    /* Public */
    function Signal() {
      var signature;
      signature = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.signature = signature;
      this.listeners = [];
      this.asyncListeners = 0;
    }

    Signal.prototype.add = function(listener, context, priority) {
      if (priority == null) {
        priority = 0;
      }
      this.validate(listener);
      if (!this.registered(listener, context)) {
        this.listeners.push([listener, context, false, priority]);
        if (this.isAsync(listener)) {
          this.asyncListeners++;
        }
        return this.sortListeners();
      }
    };

    Signal.prototype.addOnce = function(listener, context, priority) {
      if (priority == null) {
        priority = 0;
      }
      this.validate(listener);
      if (!this.registered(listener, context)) {
        this.listeners.push([listener, context, true, priority]);
        if (this.isAsync(listener)) {
          this.asyncListeners++;
        }
        return this.sortListeners();
      }
    };

    Signal.prototype.remove = function(listener, context) {
      if (this.registered(listener, context)) {
        if (this.isAsync(listener)) {
          this.asyncListeners--;
        }
        return this.listeners.splice(this.indexOf(listener, context), 1);
      }
    };

    Signal.prototype.removeAll = function() {
      this.listeners = [];
      return this.asyncListeners = 0;
    };

    Signal.prototype.indexOf = function(listener, context) {
      var c, i, l, _i, _len, _ref, _ref1;
      _ref = this.listeners;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        _ref1 = _ref[i], l = _ref1[0], c = _ref1[1];
        if (listener === l && context === c) {
          return i;
        }
      }
      return -1;
    };

    Signal.prototype.registered = function(listener, context) {
      return this.indexOf(listener, context) !== -1;
    };

    Signal.prototype.hasListeners = function() {
      return this.listeners.length !== 0;
    };

    Signal.prototype.sortListeners = function() {
      if (this.listeners.length <= 1) {
        return;
      }
      return this.listeners.sort(function(a, b) {
        var pA, pB, _ref;
        _ref = [a[3], b[3]], pA = _ref[0], pB = _ref[1];
        if (pA < pB) {
          return 1;
        } else if (pB < pA) {
          return -1;
        } else {
          return 0;
        }
      });
    };

    Signal.prototype.validate = function(listener) {
      var args, listenerSignature, m, re, s1, s2, signature;
      if (this.signature.length > 0) {
        re = /[^(]+\(([^)]+)\).*$/m;
        listenerSignature = Function.prototype.toString.call(listener).split('\n').shift();
        signature = listenerSignature.replace(re, '$1');
        args = signature.split(/\s*,\s*/g);
        if (args[0] === '') {
          args.shift();
        }
        if (args[args.length - 1] === 'callback') {
          args.pop();
        }
        s1 = this.signature.join();
        s2 = args.join();
        m = "The listener " + listener + " doesn't match the signal's signature " + s1;
        if (s2 !== s1) {
          throw new Error(m);
        }
      }
    };

    Signal.prototype.isAsync = function(listener) {
      return Function.prototype.toString.call(listener).indexOf('callback)') !== -1;
    };

    Signal.prototype.dispatch = function() {
      var args, callback, context, listener, listeners, next, once, priority, _i, _j, _len, _ref;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (typeof callback !== 'function') {
        args.push(callback);
        callback = null;
      }
      listeners = this.listeners.concat();
      if (this.asyncListeners > 0) {
        next = (function(_this) {
          return function(callback) {
            var context, listener, once, priority, _ref;
            if (listeners.length) {
              _ref = listeners.shift(), listener = _ref[0], context = _ref[1], once = _ref[2], priority = _ref[3];
              if (_this.isAsync(listener)) {
                return listener.apply(context, args.concat(function() {
                  if (once) {
                    _this.remove(listener, context);
                  }
                  return next(callback);
                }));
              } else {
                listener.apply(context, args);
                if (once) {
                  _this.remove(listener, context);
                }
                return next(callback);
              }
            } else {
              return typeof callback === "function" ? callback() : void 0;
            }
          };
        })(this);
        return next(callback);
      } else {
        for (_j = 0, _len = listeners.length; _j < _len; _j++) {
          _ref = listeners[_j], listener = _ref[0], context = _ref[1], once = _ref[2], priority = _ref[3];
          listener.apply(context, arguments);
          if (once) {
            this.remove(listener, context);
          }
        }
        return typeof callback === "function" ? callback() : void 0;
      }
    };

    return Signal;

  })();

  g = typeof global !== "undefined" && global !== null ? global : window;

  requestAnimFrame = g.requestAnimationFrame || g.webkitRequestAnimationFrame || g.mozRequestAnimationFrame || g.oRequestAnimationFrame || g.msRequestAnimationFrame || function() {
    return g.setTimeout(callback, 1000 / 60);
  };

  agt.Impulse = (function(_super) {
    __extends(Impulse, _super);


    /* Public */

    Impulse.instance = function() {
      return this.__instance__ || (this.__instance__ = new Impulse);
    };

    function Impulse(timeScale) {
      this.timeScale = timeScale != null ? timeScale : 1;
      Impulse.__super__.constructor.call(this);
      this.running = false;
    }

    Impulse.prototype.add = function(listener, context, priority) {
      if (priority == null) {
        priority = 0;
      }
      Impulse.__super__.add.call(this, listener, context, priority);
      if (this.hasListeners() && !this.running) {
        return this.start();
      }
    };

    Impulse.prototype.remove = function(listener, context) {
      Impulse.__super__.remove.call(this, listener, context);
      if (this.running && !this.hasListeners()) {
        return this.stop();
      }
    };

    Impulse.prototype.hasListeners = function() {
      return this.listeners.length > 0;
    };

    Impulse.prototype.start = function() {
      this.running = true;
      return this.initRun();
    };

    Impulse.prototype.stop = function() {
      return this.running = false;
    };

    Impulse.prototype.initRun = function() {
      this.time = this.getTime();
      return requestAnimFrame((function(_this) {
        return function() {
          return _this.run();
        };
      })(this));
    };

    Impulse.prototype.run = function() {
      var s, t;
      if (this.running) {
        t = this.getTime();
        s = (t - this.time) * this.timeScale;
        this.dispatch(s, s / 1000, t);
        return this.initRun();
      }
    };

    Impulse.prototype.getTime = function() {
      return new Date().getTime();
    };

    return Impulse;

  })(agt.Signal);

  agt.Promise = (function() {
    Promise.unit = function(value) {
      var promise;
      if (value == null) {
        value = 0;
      }
      promise = new agt.Promise;
      promise.resolve(value);
      return promise;
    };

    Promise.all = function(promises) {
      var promise, results, solved;
      promise = new agt.Promise;
      solved = 0;
      results = [];
      promises.forEach(function(p) {
        return p.then(function(value) {
          solved++;
          results[promises.indexOf(p)] = value;
          if (solved === promises.length) {
            return promise.resolve(results);
          }
        }).fail(function(reason) {
          return promise.reject(reason);
        });
      });
      return promise;
    };

    function Promise(factory) {
      this.factory = factory;
      this.pending = true;
      this.started = false;
      this.fulfilled = null;
      this.value = void 0;
      this.timeout = 60000;
      this.message = 'Timed out';
      this.fulfilledHandlers = [];
      this.errorHandlers = [];
      this.progressHandlers = [];
    }

    Promise.prototype.isPending = function() {
      return this.pending;
    };

    Promise.prototype.isResolved = function() {
      return !this.pending;
    };

    Promise.prototype.isFulfilled = function() {
      return !this.pending && this.fulfilled;
    };

    Promise.prototype.isRejected = function() {
      return !this.pending && !this.fulfilled;
    };

    Promise.prototype.then = function(fulfilledHandler, errorHandler, progressHandler) {
      var e, f, promise;
      if (!this.started) {
        this.start();
      }
      promise = new agt.Promise;
      f = function(value) {
        var err, res;
        try {
          res = typeof fulfilledHandler === "function" ? fulfilledHandler(value) : void 0;
        } catch (_error) {
          err = _error;
          promise.reject(err);
          return;
        }
        if ((res != null ? res.then : void 0) != null) {
          return res.then(function(value) {
            return promise.resolve(value);
          }).fail(function(reason) {
            return promise.reject(reason);
          });
        } else {
          return promise.resolve(res);
        }
      };
      e = function(reason) {
        if (typeof errorHandler === "function") {
          errorHandler(reason);
        }
        return promise.reject(reason);
      };
      if (this.pending) {
        this.fulfilledHandlers.push(f);
        this.errorHandlers.push(e);
        if (progressHandler != null) {
          this.progressHandlers.push(progressHandler);
        }
      } else {
        if (this.fulfilled) {
          f(this.value);
        } else {
          e(this.reason);
        }
      }
      return promise;
    };

    Promise.prototype.fail = function(errorHandler) {
      return this.then((function() {}), errorHandler);
    };

    Promise.prototype.bind = function(promise) {
      return this.then((function(res) {
        return promise.resolve(res);
      }), (function(reason) {
        return promise.reject(reason);
      }));
    };

    Promise.prototype.resolve = function(value) {
      this.value = value;
      if (!this.pending) {
        return;
      }
      this.fulfilled = true;
      this.notifyHandlers();
      return this.pending = false;
    };

    Promise.prototype.reject = function(reason) {
      if (!this.pending) {
        return;
      }
      this.reason = reason;
      this.fulfilled = false;
      this.pending = false;
      return this.notifyHandlers();
    };

    Promise.prototype.start = function() {
      var e, f, lastTime;
      if (this.started) {
        return;
      }
      if (this.factory != null) {
        try {
          if (this.signature(this.factory).length === 0) {
            this.resolve(this.factory.call(this));
          } else {
            lastTime = new Date();
            f = (function(_this) {
              return function() {
                if (new Date() - lastTime >= _this.timeout) {
                  _this.reject(new Error(_this.message));
                }
                if (_this.pending) {
                  return setTimeout(f, 10);
                }
              };
            })(this);
            this.factory.call(this, this);
            f();
          }
        } catch (_error) {
          e = _error;
          this.reject(e);
        }
      }
      return this.started = true;
    };

    Promise.prototype.rejectAfter = function(timeout, message) {
      this.timeout = timeout;
      this.message = message;
    };

    Promise.prototype.notifyHandlers = function() {
      var handler, _i, _j, _len, _len1, _ref, _ref1, _results, _results1;
      if (this.fulfilled) {
        _ref = this.fulfilledHandlers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          handler = _ref[_i];
          _results.push(handler(this.value));
        }
        return _results;
      } else {
        _ref1 = this.errorHandlers;
        _results1 = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          handler = _ref1[_j];
          _results1.push(handler(this.reason));
        }
        return _results1;
      }
    };

    Promise.prototype.signature = function(func) {
      var re, _ref;
      re = /^function(\s+[a-zA-Z_][a-zA-Z0-9_]*)*\s*\(([^\)]+)\)/;
      return ((_ref = re.exec(func.toString())) != null ? _ref[2].split(/\s*,\s*/) : void 0) || [];
    };

    return Promise;

  })();

  agt.mixins.Activable = (function() {
    function Activable() {}

    Activable.prototype.active = false;

    Activable.prototype.activate = function() {
      if (this.active) {
        return;
      }
      this.active = true;
      return typeof this.activated === "function" ? this.activated() : void 0;
    };

    Activable.prototype.deactivate = function() {
      if (!this.active) {
        return;
      }
      this.active = false;
      return typeof this.deactivated === "function" ? this.deactivated() : void 0;
    };

    return Activable;

  })();

  agt.mixins.Aliasable = (function() {
    function Aliasable() {}

    Aliasable.alias = function() {
      var alias, aliases, desc, source, _i, _j, _len, _len1, _results, _results1;
      source = arguments[0], aliases = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      desc = Object.getPropertyDescriptor(this.prototype, source);
      if (desc != null) {
        _results = [];
        for (_i = 0, _len = aliases.length; _i < _len; _i++) {
          alias = aliases[_i];
          _results.push(Object.defineProperty(this.prototype, alias, desc));
        }
        return _results;
      } else {
        if (this.prototype[source] != null) {
          _results1 = [];
          for (_j = 0, _len1 = aliases.length; _j < _len1; _j++) {
            alias = aliases[_j];
            _results1.push(this.prototype[alias] = this.prototype[source]);
          }
          return _results1;
        }
      }
    };

    return Aliasable;

  })();

  agt.mixins.AlternateCase = (function() {
    function AlternateCase() {}

    AlternateCase.snakify = function() {
      return this.convert('toSnakeCase');
    };

    AlternateCase.camelize = function() {
      return this.convert('toCamelCase');
    };

    AlternateCase.convert = function(alternateCase) {
      var alternate, descriptor, key, value, _ref, _results;
      _ref = this.prototype;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        alternate = this[alternateCase](key);
        descriptor = Object.getPropertyDescriptor(this.prototype, key);
        if (descriptor != null) {
          _results.push(Object.defineProperty(this.prototype, alternate, descriptor));
        } else {
          _results.push(this.prototype[alternate] = value);
        }
      }
      return _results;
    };

    AlternateCase.toSnakeCase = function(str) {
      return str.replace(/([a-z])([A-Z])/g, "$1_$2").split(/_+/g).join('_').toLowerCase();
    };

    AlternateCase.toCamelCase = function(str) {
      var a, s, w, _i, _len;
      a = str.toLowerCase().split(/[_\s-]/);
      s = a.shift();
      for (_i = 0, _len = a.length; _i < _len; _i++) {
        w = a[_i];
        s = "" + s + (w.replace(/^./, function(s) {
          return s.toUpperCase();
        }));
      }
      return s;
    };

    return AlternateCase;

  })();

  build = function(klass, args) {
    var BUILDS, f, i, j;
    BUILDS = (function() {
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
    f = BUILDS[args != null ? args.length : 0];
    return f(klass, args);
  };

  agt.mixins.Cloneable = function() {
    var ConcreteCloneable, properties;
    properties = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return ConcreteCloneable = (function() {
      function ConcreteCloneable() {}

      ConcreteCloneable.prototype.clone = function() {
        return new this.constructor(this);
      };

      if (properties.length > 0) {
        ConcreteCloneable.prototype.clone = function() {
          return build(this.constructor, properties.map((function(_this) {
            return function(p) {
              return _this[p];
            };
          })(this)));
        };
      }

      return ConcreteCloneable;

    })();
  };

  agt.mixins.Delegation = (function() {
    function Delegation() {}

    Delegation.delegate = function() {
      var delegated, options, prefixed, properties, _case, _i;
      properties = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), options = arguments[_i++];
      if (options == null) {
        options = {};
      }
      delegated = options.to;
      prefixed = options.prefix;
      _case = options["case"] || agt.CAMEL_CASE;
      return properties.forEach((function(_this) {
        return function(property) {
          var localAlias;
          localAlias = property;
          if (prefixed) {
            switch (_case) {
              case agt.SNAKE_CASE:
                localAlias = delegated + '_' + property;
                break;
              case agt.CAMEL_CASE:
                localAlias = delegated + property.replace(/^./, function(m) {
                  return m.toUpperCase();
                });
            }
          }
          return Object.defineProperty(_this.prototype, localAlias, {
            enumerable: true,
            configurable: true,
            get: function() {
              return this[delegated][property];
            },
            set: function(value) {
              return this[delegated][property] = value;
            }
          });
        };
      })(this));
    };

    return Delegation;

  })();

  agt.mixins.Equatable = function() {
    var ConcreteEquatable, properties;
    properties = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return ConcreteEquatable = (function() {
      function ConcreteEquatable() {}

      ConcreteEquatable.prototype.equals = function(o) {
        return (o != null) && properties.every((function(_this) {
          return function(p) {
            if (_this[p].equals != null) {
              return _this[p].equals(o[p]);
            } else {
              return o[p] === _this[p];
            }
          };
        })(this));
      };

      return ConcreteEquatable;

    })();
  };

  agt.mixins.Formattable = function() {
    var ConcreteFormattable, classname, properties;
    classname = arguments[0], properties = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return ConcreteFormattable = (function() {
      function ConcreteFormattable() {}


      /* Public */

      ConcreteFormattable.prototype.toString = function() {
        return "[" + classname + "]";
      };

      if (properties.length > 0) {
        ConcreteFormattable.prototype.toString = function() {
          var formattedProperties, p;
          formattedProperties = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = properties.length; _i < _len; _i++) {
              p = properties[_i];
              _results.push("" + p + "=" + this[p]);
            }
            return _results;
          }).call(this);
          return "[" + classname + "(" + (formattedProperties.join(', ')) + ")]";
        };
      }

      ConcreteFormattable.prototype.classname = function() {
        return classname;
      };

      return ConcreteFormattable;

    })();
  };

  DEFAULT_UNGLOBALIZABLE = ['globalizable', 'unglobalizable', 'globalized', 'globalize', 'unglobalize', 'globalizeMember', 'unglobalizeMember', 'keepContext', 'previousValues', 'previousDescriptors'];

  agt.mixins.Globalizable = function(global, keepContext) {
    var ConcreteGlobalizable;
    if (keepContext == null) {
      keepContext = true;
    }
    return ConcreteGlobalizable = (function() {
      function ConcreteGlobalizable() {}

      ConcreteGlobalizable.unglobalizable = DEFAULT_UNGLOBALIZABLE.concat();

      ConcreteGlobalizable.prototype.keepContext = keepContext;

      ConcreteGlobalizable.prototype.globalize = function() {
        if (this.globalized) {
          return;
        }
        this.previousValues = {};
        this.previousDescriptors = {};
        this.globalizable.forEach((function(_this) {
          return function(k) {
            if (__indexOf.call(_this.constructor.unglobalizable || ConcreteGlobalizable.unglobalizable, k) < 0) {
              return _this.globalizeMember(k);
            }
          };
        })(this));
        return this.globalized = true;
      };

      ConcreteGlobalizable.prototype.unglobalize = function() {
        if (!this.globalized) {
          return;
        }
        this.globalizable.forEach((function(_this) {
          return function(k) {
            if (__indexOf.call(_this.constructor.unglobalizable || ConcreteGlobalizable.unglobalizable, k) < 0) {
              return _this.unglobalizeMember(k);
            }
          };
        })(this));
        this.previousValues = null;
        this.previousDescriptors = null;
        return this.globalized = false;
      };

      ConcreteGlobalizable.prototype.globalizeMember = function(key) {
        var oldDescriptor, selfDescriptor, value, _ref, _ref1;
        oldDescriptor = Object.getPropertyDescriptor(global, key);
        selfDescriptor = Object.getPropertyDescriptor(this, key);
        if (oldDescriptor != null) {
          this.previousDescriptors[key] = oldDescriptor;
        } else if (this[key] != null) {
          if (global[key] != null) {
            this.previousValues[key] = global;
          }
        }
        if (selfDescriptor != null) {
          if (keepContext) {
            if ((selfDescriptor.get != null) || (selfDescriptor.set != null)) {
              selfDescriptor.get = (_ref = selfDescriptor.get) != null ? _ref.bind(this) : void 0;
              selfDescriptor.set = (_ref1 = selfDescriptor.set) != null ? _ref1.bind(this) : void 0;
            } else if (typeof selfDescriptor.value === 'function') {
              selfDescriptor.value = selfDescriptor.value.bind(this);
            }
          }
          return Object.defineProperty(global, key, selfDescriptor);
        } else {
          value = this[key];
          if (typeof value === 'function' && keepContext) {
            value = value.bind(this);
          }
          return Object.defineProperty(global, key, {
            value: value,
            enumerable: true,
            writable: true,
            configurable: true
          });
        }
      };

      ConcreteGlobalizable.prototype.unglobalizeMember = function(key) {
        if (this.previousDescriptors[key] != null) {
          return Object.defineProperty(global, key, this.previousDescriptors[key]);
        } else if (this.previousValues[key] != null) {
          return global[key] = this.previousValues[key];
        } else {
          return global[key] = void 0;
        }
      };

      return ConcreteGlobalizable;

    })();
  };

  agt.mixins.HasAncestors = function(options) {
    var ConcreteHasAncestors, through;
    if (options == null) {
      options = {};
    }
    through = options.through || 'parent';
    return ConcreteHasAncestors = (function() {
      function ConcreteHasAncestors() {}

      ConcreteHasAncestors.getter('ancestors', function() {
        var ancestors, parent;
        ancestors = [];
        parent = this[through];
        while (parent != null) {
          ancestors.push(parent);
          parent = parent[through];
        }
        return ancestors;
      });

      ConcreteHasAncestors.getter('selfAndAncestors', function() {
        return [this].concat(this.ancestors);
      });

      ConcreteHasAncestors.ancestorsScope = function(name, block) {
        return this.getter(name, function() {
          return this.ancestors.filter(block, this);
        });
      };

      return ConcreteHasAncestors;

    })();
  };

  agt.mixins.HasCollection = function(plural, singular) {
    var ConcreteHasCollection, pluralPostfix, singularPostfix;
    pluralPostfix = plural.replace(/^./, function(s) {
      return s.toUpperCase();
    });
    singularPostfix = singular.replace(/^./, function(s) {
      return s.toUpperCase();
    });
    return ConcreteHasCollection = (function() {
      function ConcreteHasCollection() {}

      ConcreteHasCollection.extend(mixins.Aliasable);

      ConcreteHasCollection["" + plural + "Scope"] = function(name, block) {
        return this.getter(name, function() {
          return this[plural].filter(block, this);
        });
      };

      ConcreteHasCollection.getter("" + plural + "Size", function() {
        return this[plural].length;
      });

      ConcreteHasCollection.alias("" + plural + "Size", "" + plural + "Length", "" + plural + "Count");

      ConcreteHasCollection.prototype["has" + singularPostfix] = function(item) {
        return __indexOf.call(this[plural], item) >= 0;
      };

      ConcreteHasCollection.alias("has" + singularPostfix, "contains" + singularPostfix);

      ConcreteHasCollection.getter("has" + pluralPostfix, function() {
        return this[plural].length > 0;
      });

      ConcreteHasCollection.prototype["add" + singularPostfix] = function(item) {
        if (!this["has" + singularPostfix](item)) {
          this[plural].push(item);
        }
        return this["" + plural + "Size"];
      };

      ConcreteHasCollection.prototype["remove" + singularPostfix] = function(item) {
        if (this["has" + singularPostfix](item)) {
          this[plural].splice(this["find" + singularPostfix](item), 1);
        }
        return this["" + plural + "Size"];
      };

      ConcreteHasCollection.prototype["find" + singularPostfix] = function(item) {
        return this[plural].indexOf(item);
      };

      ConcreteHasCollection.alias("find" + singularPostfix, "indexOf" + singularPostfix);

      return ConcreteHasCollection;

    })();
  };

  agt.mixins.HasNestedCollection = function(name, options) {
    var ConcreteHasNestedCollection, through;
    if (options == null) {
      options = {};
    }
    through = options.through;
    if (through == null) {
      throw new Error('missing through option');
    }
    return ConcreteHasNestedCollection = (function() {
      function ConcreteHasNestedCollection() {}

      ConcreteHasNestedCollection["" + name + "Scope"] = function(scopeName, block) {
        return this.getter(scopeName, function() {
          return this[name].filter(block, this);
        });
      };

      ConcreteHasNestedCollection.getter(name, function() {
        var items;
        items = [];
        this[through].forEach(function(item) {
          items.push(item);
          if (item[name] != null) {
            return items = items.concat(item[name]);
          }
        });
        return items;
      });

      return ConcreteHasNestedCollection;

    })();
  };

  agt.mixins.Memoizable = (function() {
    function Memoizable() {}

    Memoizable.prototype.memoized = function(prop) {
      var _ref;
      if (this.memoizationKey() === this.__memoizationKey__) {
        return ((_ref = this.__memo__) != null ? _ref[prop] : void 0) != null;
      } else {
        this.__memo__ = {};
        return false;
      }
    };

    Memoizable.prototype.memoFor = function(prop) {
      return this.__memo__[prop];
    };

    Memoizable.prototype.memoize = function(prop, value) {
      this.__memo__ || (this.__memo__ = {});
      this.__memoizationKey__ = this.memoizationKey();
      return this.__memo__[prop] = value;
    };

    Memoizable.prototype.memoizationKey = function() {
      return this.toString();
    };

    return Memoizable;

  })();

  agt.mixins.Parameterizable = function(method, parameters, allowPartial) {
    var ConcreteParameterizable;
    if (allowPartial == null) {
      allowPartial = false;
    }
    return ConcreteParameterizable = (function() {
      function ConcreteParameterizable() {}

      ConcreteParameterizable.included = function(klass) {
        var f;
        f = function() {
          var args, firstArgumentIsObject, k, n, o, output, parameterType, strict, v, value, _i;
          args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), strict = arguments[_i++];
          if (typeof strict !== 'boolean') {
            args.push(strict);
            strict = false;
          }
          output = {};
          o = arguments[0];
          n = 0;
          firstArgumentIsObject = (o != null) && typeof o === 'object';
          for (k in parameters) {
            v = parameters[k];
            value = firstArgumentIsObject ? o[k] : arguments[n++];
            parameterType = typeof v;
            if (strict) {
              if (typeof value === parameterType) {
                output[k] = value;
              } else {
                if (parameterType === 'number') {
                  value = parseFloat(value);
                  if (isNaN(value)) {
                    throw new Error("value for " + k + " doesn't match type " + parameterType);
                  } else {
                    output[k] = value;
                  }
                } else {
                  throw new Error("value for " + k + " doesn't match type " + parameterType);
                }
              }
            } else {
              if (value != null) {
                if (parameterType === 'number') {
                  value = parseFloat(value);
                  if (isNaN(value)) {
                    if (!allowPartial) {
                      output[k] = v;
                    }
                  } else {
                    output[k] = value;
                  }
                } else {
                  output[k] = value;
                }
              } else {
                if (!allowPartial) {
                  output[k] = v;
                }
              }
            }
          }
          return output;
        };
        klass[method] = f;
        return klass.prototype[method] = f;
      };

      return ConcreteParameterizable;

    })();
  };

  agt.mixins.Poolable = (function() {
    function Poolable() {}

    Poolable.extended = function(klass) {
      klass.usedInstances = [];
      return klass.unusedInstances = [];
    };

    Poolable.resetPools = function() {
      this.usedInstances = [];
      return this.unusedInstances = [];
    };

    Poolable.get = function(options) {
      var instance;
      if (options == null) {
        options = {};
      }
      if (this.unusedInstances.length > 0) {
        instance = this.unusedInstances.shift();
      } else {
        instance = new this;
      }
      this.usedInstances.push(instance);
      instance.init(options);
      return instance;
    };

    Poolable.release = function(instance) {
      var index;
      if (__indexOf.call(this.usedInstances, instance) < 0) {
        return;
      }
      index = this.usedInstances.indexOf(instance);
      this.usedInstances.splice(index, 1);
      return this.unusedInstances.push(instance);
    };

    Poolable.prototype.init = function(options) {
      var k, v, _results;
      if (options == null) {
        options = {};
      }
      _results = [];
      for (k in options) {
        v = options[k];
        _results.push(this[k] = v);
      }
      return _results;
    };

    Poolable.prototype.dispose = function() {
      return this.constructor.release(this);
    };

    return Poolable;

  })();

  agt.mixins.Sourcable = function() {
    var ConcreteSourcable, name, signature;
    name = arguments[0], signature = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return ConcreteSourcable = (function() {
      var sourceFor;

      function ConcreteSourcable() {}

      sourceFor = function(value) {
        var isArray;
        switch (typeof value) {
          case 'object':
            isArray = Object.prototype.toString.call(value).indexOf('Array') !== -1;
            if (isArray) {
              return "[" + (value.map(function(el) {
                return sourceFor(el);
              })) + "]";
            } else {
              if (value.toSource != null) {
                return value.toSource();
              } else {
                return value;
              }
            }
            break;
          case 'string':
            return "'" + (value.replace("'", "\\'")) + "'";
          default:
            return value;
        }
      };

      ConcreteSourcable.prototype.toSource = function() {
        var arg, args;
        args = ((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = signature.length; _i < _len; _i++) {
            arg = signature[_i];
            _results.push(this[arg]);
          }
          return _results;
        }).call(this)).map(function(o) {
          return sourceFor(o);
        });
        return "new " + name + "(" + (args.join(',')) + ")";
      };

      return ConcreteSourcable;

    })();
  };

  mixins.Sourcable._name = 'Sourcable';

  net.Router = (function() {
    function Router(block) {
      this.routes = {};
      this.beforeFilters = [];
      this.afterFilters = [];
      block.call(this);
      this.buildRoutesHandlers();
    }

    Router.prototype.get = function(path, options, handle) {
      var _ref;
      if (options == null) {
        options = {};
      }
      if (typeof options === 'function') {
        _ref = [{}, options], options = _ref[0], handle = _ref[1];
      }
      path = path.replace(/^\/|\/$/g, '');
      return this.routes[path] = {
        handle: handle,
        options: options
      };
    };

    Router.prototype.beforeFilter = function(filter) {
      return this.beforeFilters.push(filter);
    };

    Router.prototype.afterFilter = function(filter) {
      return this.afterFilters.push(filter);
    };

    Router.prototype.notFound = function(notFoundHandle) {
      this.notFoundHandle = notFoundHandle;
    };

    Router.prototype.goto = function(route) {
      var handler;
      if (route !== '/') {
        route = route.replace(/\/$/, '');
      }
      handler = this.findRoute(route);
      this.beforeFilters.forEach((function(_this) {
        return function(filter) {
          return filter(route, _this);
        };
      })(this));
      if (handler != null) {
        handler(route);
      } else {
        if (typeof this.notFoundHandle === "function") {
          this.notFoundHandle(route);
        }
      }
      $(document).trigger('page:change');
      return this.afterFilters.forEach((function(_this) {
        return function(filter) {
          return filter(route, _this);
        };
      })(this));
    };

    Router.prototype.findRoute = function(route) {
      var handle, k, test, _ref, _ref1;
      _ref = this.routes;
      for (k in _ref) {
        _ref1 = _ref[k], test = _ref1.test, handle = _ref1.handle;
        if (test(route)) {
          return handle;
        }
      }
    };

    Router.prototype.buildRoutesHandlers = function() {
      var data, route, _ref, _results;
      _ref = this.routes;
      _results = [];
      for (route in _ref) {
        data = _ref[route];
        _results.push(this.routes[route] = this.buildRouteHandler(route, data));
      }
      return _results;
    };

    Router.prototype.buildRouteHandler = function(route, _arg) {
      var handle, options, param_name, params_re, part, pathArray, pathParams, pathRe, re, res, _i, _len, _ref;
      handle = _arg.handle, options = _arg.options;
      pathArray = route.split('/');
      pathRe = [];
      pathParams = [];
      for (_i = 0, _len = pathArray.length; _i < _len; _i++) {
        part = pathArray[_i];
        params_re = /^:(.+)$/;
        if (res = params_re.exec(part)) {
          param_name = res[1];
          pathRe.push((_ref = options[param_name]) != null ? _ref : '([^/]+)');
          pathParams.push(param_name);
        } else {
          pathRe.push(part);
        }
      }
      re = new RegExp('^/' + pathRe.join('/') + '$');
      return {
        options: options,
        test: function(route) {
          return re.test(route);
        },
        handle: function(route) {
          var i, params, pname, _j, _len1;
          params = {
            path: route
          };
          res = re.exec(route);
          if ((res != null) && res.length > 1) {
            for (i = _j = 0, _len1 = pathParams.length; _j < _len1; i = ++_j) {
              pname = pathParams[i];
              params[pname] = decodeURI(res[i + 1]);
            }
          }
          return handle(params);
        }
      };
    };

    return Router;

  })();

  floor = Math.floor, round = Math.round;

  agt.random.Random = (function() {
    Random.include(mixins.Cloneable('generator'));

    Random.include(mixins.Sourcable('agt.random.Random', 'generator'));

    Random.include(mixins.Formattable('Random', 'generator'));


    /* Public */

    function Random(generator) {
      this.generator = generator;
    }

    Random.prototype.get = function() {
      return this.generator.get();
    };

    Random.prototype.boolean = function(rate) {
      if (rate == null) {
        rate = 0.5;
      }
      if (!((0 <= rate && rate <= 1))) {
        rate = 0.5;
      }
      return this.get() < rate;
    };

    Random.prototype.bit = function(rate) {
      if (rate == null) {
        rate = 0.5;
      }
      if (this.boolean(rate)) {
        return 1;
      } else {
        return 0;
      }
    };

    Random.prototype.sign = function(rate) {
      if (rate == null) {
        rate = 0.5;
      }
      if (this.boolean(rate)) {
        return 1;
      } else {
        return -1;
      }
    };

    Random.prototype.char = function(arg, rangeEnd) {
      var n, str, _i, _ref, _ref1, _ref2;
      if (arg == null) {
        _ref = ['abcdefghijklmnopqrstuvwxyz', null], arg = _ref[0], rangeEnd = _ref[1];
      }
      switch (typeof arg) {
        case 'string':
          if (typeof rangeEnd === 'string') {
            str = '';
            for (n = _i = _ref1 = arg.charCodeAt(0), _ref2 = rangeEnd.charCodeAt(0); _ref1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; n = _ref1 <= _ref2 ? ++_i : --_i) {
              str += String.fromCharCode(n);
            }
            arg = str;
          }
          return arg.substr(this.intRandom(arg.length - 1), 1);
        case 'number':
          if (typeof rangeEnd === 'number') {
            return n = String.fromCharCode(floor(this.inRange(arg, rangeEnd)));
          } else {
            return String.fromCharCode(this.intRandom(arg));
          }
      }
    };

    Random.prototype.inRange = function(a, b, c) {
      var r, res;
      res = a + this.random(b - a);
      if (typeof c === 'number') {
        r = 1 / c;
        if (floor(res * r) !== res * r) {
          res -= res % c;
        }
      }
      res = floor(res * 1000000000) / 1000000000;
      return res;
    };

    Random.prototype.inArray = function(array, ratios, summed) {
      var a, b, i, last, n, rand, sum, v, _i, _j, _k, _len, _len1, _len2;
      if (array != null) {
        if (ratios != null) {
          if (ratios.length !== array.length) {
            throw new Error('array and ratios arrays must have the same length');
          }
          if (summed) {
            for (i = _i = 0, _len = ratios.length; _i < _len; i = ++_i) {
              b = ratios[i];
              if (i > 0) {
                a = ratios[i - 1];
                if (a > b) {
                  throw new Error('ratios must be ordered when summed is true');
                }
              }
            }
          }
          if (summed) {
            last = ratios[ratios.length - 1];
            ratios = ratios.map(function(n) {
              return n / last;
            });
          } else {
            sum = ratios.reduce(function(a, b) {
              return a + b;
            });
            ratios = ratios.map(function(n) {
              return n / sum;
            });
            for (i = _j = 0, _len1 = ratios.length; _j < _len1; i = ++_j) {
              n = ratios[i];
              if (i > 0) {
                ratios[i] += ratios[i - 1];
              }
            }
          }
          rand = this.get();
          for (i = _k = 0, _len2 = ratios.length; _k < _len2; i = ++_k) {
            v = ratios[i];
            if (rand <= v) {
              return array[i];
            }
          }
        } else {
          return array[this.intRandom(array.length - 1)];
        }
      } else {
        return null;
      }
    };

    Random.prototype["in"] = function(a, b, c) {
      if (arguments.length > 3) {
        return this.inArray(arguments);
      } else {
        switch (typeof a) {
          case 'number':
            return this.inRange(a, b);
          case 'string':
            return this.inArray(a, b, c);
          case 'object':
            if (Object.prototype.toString.call(a) === '[object Array]') {
              return this.inArray(a, b, c);
            } else {
              if ((a.min != null) && (a.max != null)) {
                return this.inRange(a.min, a.max, a.step);
              }
            }
            break;
          default:
            return null;
        }
      }
    };

    Random.prototype.sort = function() {
      return (function(_this) {
        return function() {
          return _this.intPad(2);
        };
      })(this);
    };

    Random.prototype.random = function(amount) {
      return this.get() * (amount || 1);
    };

    Random.prototype.intRandom = function(amount) {
      return round(this.random(amount));
    };

    Random.prototype.pad = function(amount) {
      return amount / 2 - this.random(amount);
    };

    Random.prototype.intPad = function(amount) {
      return round(this.pad(amount));
    };

    return Random;

  })();

  agt.random.LaggedFibonnacci = (function() {
    LaggedFibonnacci.include(mixins.Cloneable('seed'));

    LaggedFibonnacci.include(mixins.Sourcable('chancejs.LaggedFibonnacci', 'seed'));

    LaggedFibonnacci.include(mixins.Formattable('LaggedFibonnacci', 'seed'));


    /* Public */

    function LaggedFibonnacci(seed) {
      if (seed == null) {
        seed = 0;
      }
      this.plantSeed(seed);
    }

    LaggedFibonnacci.prototype.get = function() {
      var uni;
      uni = this.u[this.i97] - this.u[this.j97];
      if (uni < 0.0) {
        uni += 1.0;
      }
      this.u[this.i97] = uni;
      if (--this.i97 < 0) {
        this.i97 = 96;
      }
      if (--this.j97 < 0) {
        this.j97 = 96;
      }
      this.c -= this.cd;
      if (this.c < 0.0) {
        this.c += this.cm;
      }
      uni -= this.c;
      if (uni < 0.0) {
        uni += 1.0;
      }
      return uni;
    };

    LaggedFibonnacci.prototype.plantSeed = function(seed) {
      var i, ii, ij, j, jj, k, kl, l, m, s, t, _i, _j, _ref, _ref1;
      if (seed == null) {
        seed = 0;
      }
      this.u = new Array(97);
      ij = seed / 30082;
      kl = seed - 30082 * ij;
      i = ((ij / 177) % 177) + 2;
      j = (ij % 177) + 2;
      k = ((kl / 169) % 178) + 1;
      l = kl % 169;
      for (ii = _i = 0; _i <= 96; ii = ++_i) {
        _ref = [0.0, 0.5], s = _ref[0], t = _ref[1];
        for (jj = _j = 0; _j <= 23; jj = ++_j) {
          m = (((i * j) % 179) * k) % 179;
          _ref1 = [j, k, m], i = _ref1[0], j = _ref1[1], k = _ref1[2];
          l = (53 * l + 1) % 169;
          if ((l * m) % 64 >= 32) {
            s += t;
          }
          t *= 0.5;
        }
        this.u[ii] = s;
      }
      this.c = 362436.0 / 16777216.0;
      this.cd = 7654321.0 / 16777216.0;
      this.cm = 16777213.0 / 16777216.0;
      this.i97 = 96;
      return this.j97 = 32;
    };

    return LaggedFibonnacci;

  })();

  agt.random.Linear = (function() {
    Linear.include(mixins.Cloneable('step'));

    Linear.include(mixins.Sourcable('chancejs.Linear', 'step'));

    Linear.include(mixins.Formattable('Linear', 'step'));


    /* Public */

    function Linear(step) {
      this.step = step != null ? step : 1000000000;
      this.iterator = 0;
    }

    Linear.prototype.get = function() {
      var res;
      res = this.iterator++ / this.step;
      if (this.iterator > this.step) {
        this.iterator = 0;
      }
      return res;
    };

    return Linear;

  })();

  agt.random.LinearCongruential = (function() {
    LinearCongruential.include(mixins.Cloneable('seed'));

    LinearCongruential.include(mixins.Sourcable('chancejs.LinearCongruential', 'seed'));

    LinearCongruential.include(mixins.Formattable('LinearCongruential', 'seed'));


    /* Public */

    function LinearCongruential(seed) {
      this.seed = seed != null ? seed : 1;
    }

    LinearCongruential.prototype.plantSeed = function(seed) {
      this.seed = seed != null ? seed : 1;
    };

    LinearCongruential.prototype.get = function() {
      var m, p, q, tmp;
      tmp = this.seed;
      q = tmp;
      q = q << 1;
      p = tmp << 32;
      m = p + q;
      if (m & 0x80000000) {
        m = m & 0x7fffffff;
        m++;
      }
      this.seed = m;
      return m / 0x80000000;
    };

    return LinearCongruential;

  })();

  agt.random.MathRandom = (function() {
    function MathRandom() {}

    MathRandom.include(mixins.Cloneable());

    MathRandom.include(mixins.Sourcable('chancejs.MathRandom'));

    MathRandom.include(mixins.Formattable('MathRandom'));

    MathRandom.prototype.get = function() {
      return Math.random();
    };

    return MathRandom;

  })();

  agt.random.MersenneTwister = (function() {
    MersenneTwister.include(mixins.Cloneable('seed'));

    MersenneTwister.include(mixins.Sourcable('chancejs.MersenneTwister', 'seed'));

    MersenneTwister.include(mixins.Formattable('MersenneTwister', 'seed'));


    /* Public */

    function MersenneTwister(seed) {
      if (seed == null) {
        seed = 0;
      }
      this.mt = Array(623);
      this.z = 0;
      this.y = 0;
      this.plantSeed(seed);
    }

    MersenneTwister.prototype.plantSeed = function(seed) {
      var i, _i, _results;
      if (seed == null) {
        seed = 0;
      }
      this.mt[0] = seed;
      _results = [];
      for (i = _i = 1; _i <= 623; i = ++_i) {
        _results.push(this.mt[i] = ((0x10dcd * this.mt[i - 1]) + 1) & 0xFFFFFFFF);
      }
      return _results;
    };

    MersenneTwister.prototype.get = function() {
      if (this.z >= 623) {
        this.generateNumbers();
      }
      return this.extractNumber(this.z++) / 0x80000000;
    };


    /* Internal: */

    MersenneTwister.prototype.generateNumbers = function() {
      var i, _i, _results;
      this.z = 0;
      _results = [];
      for (i = _i = 0; _i <= 623; i = ++_i) {
        this.y = 0x80000000 & this.mt[i] + 0x7FFFFFFF & this.mt[(i + 1) % 623];
        if (this.y % 2 === 0) {
          _results.push(this.mt[i] = this.mt[(i + 397) % 623] ^ (this.y >> 1));
        } else {
          _results.push(this.mt[i] = this.mt[(i + 397) % 623] ^ (this.y >> 1) ^ 0x9908B0DF);
        }
      }
      return _results;
    };

    MersenneTwister.prototype.extractNumber = function(i) {
      this.y = this.mt[i];
      this.y ^= this.y >> 11;
      this.y ^= (this.y << 7) & 0x9d2c5680;
      this.y ^= (this.y << 15) & 0xefc60000;
      return this.y ^= this.y >> 18;
    };

    return MersenneTwister;

  })();

  agt.random.NoRandom = (function() {
    NoRandom.include(mixins.Cloneable('seed'));

    NoRandom.include(mixins.Sourcable('chancejs.NoRandom', 'seed'));

    NoRandom.include(mixins.Formattable('NoRandom', 'seed'));


    /* Public */

    function NoRandom(seed) {
      this.seed = seed != null ? seed : 0;
    }

    NoRandom.prototype.get = function() {
      return this.seed;
    };

    return NoRandom;

  })();

  agt.random.PaulHoule = (function() {
    PaulHoule.include(mixins.Cloneable('seed'));

    PaulHoule.include(mixins.Sourcable('chancejs.PaulHoule', 'seed'));

    PaulHoule.include(mixins.Formattable('PaulHoule', 'seed'));


    /* Public */

    function PaulHoule(seed) {
      this.seed = seed;
    }

    PaulHoule.prototype.get = function() {
      this.seed = (this.seed * 9301 + 49297) % 233280;
      return this.seed / 233280.0;
    };

    return PaulHoule;

  })();

  agt.geom.Geometry = (function() {
    var pointsBounds;

    function Geometry() {}


    /* Public */

    Geometry.prototype.points = function() {};

    Geometry.prototype.closedGeometry = function() {
      return false;
    };

    pointsBounds = function(points, mode, axis) {
      return Math[mode].apply(Math, points.map(function(pt) {
        return pt[axis];
      }));
    };

    Geometry.prototype.top = function() {
      return pointsBounds(this.points(), 'min', 'y');
    };

    Geometry.prototype.bottom = function() {
      return pointsBounds(this.points(), 'max', 'y');
    };

    Geometry.prototype.left = function() {
      return pointsBounds(this.points(), 'min', 'x');
    };

    Geometry.prototype.right = function() {
      return pointsBounds(this.points(), 'max', 'x');
    };

    Geometry.prototype.bounds = function() {
      return {
        top: this.top(),
        left: this.left(),
        right: this.right(),
        bottom: this.bottom()
      };
    };

    Geometry.prototype.boundingBox = function() {
      return new agt.geom.Rectangle(this.left(), this.top(), this.right() - this.left(), this.bottom() - this.top());
    };

    Geometry.prototype.stroke = function(context, color) {
      if (color == null) {
        color = agt.COLORS.STROKE;
      }
      if (context == null) {
        return;
      }
      context.strokeStyle = color;
      this.drawPath(context);
      return context.stroke();
    };

    Geometry.prototype.fill = function(context, color) {
      if (color == null) {
        color = agt.COLORS.FILL;
      }
      if (context == null) {
        return;
      }
      context.fillStyle = color;
      this.drawPath(context);
      return context.fill();
    };

    Geometry.prototype.drawPath = function(context) {
      var p, points, start, _i, _len;
      points = this.points();
      start = points.shift();
      context.beginPath();
      context.moveTo(start.x, start.y);
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        p = points[_i];
        context.lineTo(p.x, p.y);
      }
      return context.closePath();
    };

    return Geometry;

  })();

  agt.geom.Intersections = (function() {
    function Intersections() {}

    Intersections.iterators = {};


    /* Public */

    Intersections.prototype.intersects = function(geometry) {
      var iterator, output;
      if ((geometry.bounds != null) && !this.boundsCollide(geometry)) {
        return false;
      }
      output = false;
      iterator = this.intersectionsIterator(this, geometry);
      iterator.call(this, this, geometry, function() {
        return output = true;
      });
      return output;
    };

    Intersections.prototype.intersections = function(geometry) {
      var iterator, output;
      if ((geometry.bounds != null) && !this.boundsCollide(geometry)) {
        return null;
      }
      output = [];
      iterator = this.intersectionsIterator(this, geometry);
      iterator.call(this, this, geometry, function(intersection) {
        output.push(intersection);
        return false;
      });
      if (output.length > 0) {
        return output;
      } else {
        return null;
      }
    };

    Intersections.prototype.boundsCollide = function(geometry) {
      var bounds1, bounds2;
      bounds1 = this.bounds();
      bounds2 = geometry.bounds();
      return !(bounds1.top > bounds2.bottom || bounds1.left > bounds2.right || bounds1.bottom < bounds2.top || bounds1.right < bounds2.left);
    };

    Intersections.prototype.intersectionsIterator = function(geom1, geom2) {
      var c1, c2, iterator;
      c1 = geom1.classname ? geom1.classname() : '';
      c2 = geom2.classname ? geom2.classname() : '';
      iterator = null;
      iterator = Intersections.iterators[c1 + c2];
      iterator || (iterator = Intersections.iterators[c1]);
      iterator || (iterator = Intersections.iterators[c2]);
      return iterator || this.eachIntersections;
    };

    Intersections.prototype.eachIntersections = function(geom1, geom2, block, providesDataInCallback) {
      var context, cross, d1l, d1x, d1y, d2l, d2x, d2y, d3l, d3x, d3y, d4l, d4x, d4y, dif1l, dif1x, dif1y, dif2l, dif2x, dif2y, ev1, ev2, i, j, lastIntersection, length1, length2, points1, points2, sv1, sv2, _i, _j, _ref, _ref1;
      if (providesDataInCallback == null) {
        providesDataInCallback = false;
      }
      points1 = geom1.points();
      points2 = geom2.points();
      length1 = points1.length;
      length2 = points2.length;
      lastIntersection = null;
      for (i = _i = 0, _ref = length1 - 2; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        sv1 = points1[i];
        ev1 = points1[i + 1];
        dif1x = ev1.x - sv1.x;
        dif1y = ev1.y - sv1.y;
        dif1l = dif1x * dif1x + dif1y * dif1y;
        for (j = _j = 0, _ref1 = length2 - 2; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          sv2 = points2[j];
          ev2 = points2[j + 1];
          dif2x = ev2.x - sv2.x;
          dif2y = ev2.y - sv2.y;
          dif2l = dif2x * dif2x + dif2y * dif2y;
          cross = this.perCrossing(sv1, {
            x: dif1x,
            y: dif1y
          }, sv2, {
            x: dif2x,
            y: dif2y
          });
          d1x = cross.x - ev1.x;
          d1y = cross.y - ev1.y;
          d2x = cross.x - sv1.x;
          d2y = cross.y - sv1.y;
          d3x = cross.x - ev2.x;
          d3y = cross.y - ev2.y;
          d4x = cross.x - sv2.x;
          d4y = cross.y - sv2.y;
          d1l = d1x * d1x + d1y * d1y;
          d2l = d2x * d2x + d2y * d2y;
          d3l = d3x * d3x + d3y * d3y;
          d4l = d4x * d4x + d4y * d4y;
          if (d1l <= dif1l && d2l <= dif1l && d3l <= dif2l && d4l <= dif2l) {
            if (cross.equals(lastIntersection)) {
              lastIntersection = cross;
              continue;
            }
            if (providesDataInCallback) {
              context = {
                segment1: new agt.geom.Point(dif1x, dif1y),
                segmentIndex1: i,
                segmentStart1: sv1,
                segmentEnd1: ev1,
                segment2: new agt.geom.Point(dif2x, dif2y),
                segmentIndex2: j,
                segmentStart2: sv2,
                segmentEnd2: ev2
              };
            }
            if (block.call(this, cross, context)) {
              return;
            }
            lastIntersection = cross;
          }
        }
      }
    };


    /* Internal */

    Intersections.prototype.perCrossing = function(start1, dir1, start2, dir2) {
      var cx, cy, perP1, perP2, t, v3bx, v3by;
      v3bx = start2.x - start1.x;
      v3by = start2.y - start1.y;
      perP1 = v3bx * dir2.y - v3by * dir2.x;
      perP2 = dir1.x * dir2.y - dir1.y * dir2.x;
      t = perP1 / perP2;
      cx = start1.x + dir1.x * t;
      cy = start1.y + dir1.y * t;
      return new agt.geom.Point(cx, cy);
    };

    return Intersections;

  })();

  agt.geom.Path = (function() {
    function Path() {}


    /* Public */

    Path.prototype.length = function() {
      var i, points, sum, _i, _ref;
      sum = 0;
      points = this.points();
      if (points.length > 1) {
        for (i = _i = 1, _ref = points.length; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          sum += points[i - 1].distance(points[i]);
        }
      }
      return sum;
    };

    Path.prototype.pathPointAt = function(pos, pathBasedOnLength) {
      var points;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      if (pos < 0) {
        pos = 0;
      }
      if (pos > 1) {
        pos = 1;
      }
      points = this.points();
      if (pos === 0) {
        return points[0];
      }
      if (pos === 1) {
        return points[points.length - 1];
      }
      if (pathBasedOnLength) {
        return this.walkPathBasedOnLength(pos, points);
      } else {
        return this.walkPathBasedOnSegments(pos, points);
      }
    };

    Path.prototype.pathOrientationAt = function(pos, pathBasedOnLength) {
      var d, p1, p2;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      p1 = this.pathPointAt(pos - 0.01, pathBasedOnLength);
      p2 = this.pathPointAt(pos + 0.01, pathBasedOnLength);
      d = p2.subtract(p1);
      return d.angle();
    };

    Path.prototype.pathTangentAt = function(pos, accuracy, pathBasedOnLength) {
      var _ref;
      if (accuracy == null) {
        accuracy = 1 / 100;
      }
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      if (typeof accuracy === 'boolean') {
        _ref = [accuracy, 1 / 100], pathBasedOnLength = _ref[0], accuracy = _ref[1];
      }
      return this.pathPointAt((pos + accuracy) % 1, pathBasedOnLength).subtract(this.pathPointAt((1 + pos - accuracy) % 1), pathBasedOnLength).normalize(1);
    };


    /* Internal */

    Path.prototype.walkPathBasedOnLength = function(pos, points) {
      var i, innerStepPos, length, p1, p2, stepLength, walked, _i, _ref;
      walked = 0;
      length = this.length();
      for (i = _i = 1, _ref = points.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        p1 = points[i - 1];
        p2 = points[i];
        stepLength = p1.distance(p2) / length;
        if (walked + stepLength > pos) {
          innerStepPos = Math.map(pos, walked, walked + stepLength, 0, 1);
          return this.pointInSegment(innerStepPos, [p1, p2]);
        }
        walked += stepLength;
      }
    };

    Path.prototype.walkPathBasedOnSegments = function(pos, points) {
      var segment, segments;
      segments = points.length - 1;
      pos = pos * segments;
      segment = Math.floor(pos);
      if (segment === segments) {
        segment -= 1;
      }
      return this.pointInSegment(pos - segment, points.slice(segment, +(segment + 1) + 1 || 9e9));
    };

    Path.prototype.pointInSegment = function(pos, segment) {
      return segment[0].add(segment[1].subtract(segment[0]).scale(pos));
    };

    return Path;

  })();

  agt.geom.Proxyable = (function() {
    function Proxyable() {}

    Proxyable.included = function(klass) {
      return klass.proxy = function() {
        var k, options, targets, type, _i, _j, _len, _results;
        targets = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), options = arguments[_i++];
        if (options == null) {
          options = {};
        }
        type = options.as;
        _results = [];
        for (_j = 0, _len = targets.length; _j < _len; _j++) {
          k = targets[_j];
          _results.push(klass.prototype[k].proxyable = type);
        }
        return _results;
      };
    };

    return Proxyable;

  })();

  agt.geom.Spline = function(segmentSize) {
    var ConcreteSpline;
    return ConcreteSpline = (function() {
      function ConcreteSpline() {}

      ConcreteSpline.include(mixins.Memoizable);


      /* Public */

      ConcreteSpline.included = function(klass) {
        return klass.segmentSize = function() {
          return segmentSize;
        };
      };

      ConcreteSpline.prototype.initSpline = function(vertices, bias) {
        this.vertices = vertices;
        this.bias = bias != null ? bias : 20;
        if (!this.validateVertices(this.vertices)) {
          throw new Error("The number of vertices for " + this + " doesn't match");
        }
      };

      ConcreteSpline.prototype.center = function() {
        var vertex, x, y, _i, _len, _ref;
        x = y = 0;
        _ref = this.vertices;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          vertex = _ref[_i];
          x += vertex.x;
          y += vertex.y;
        }
        x = x / this.vertices.length;
        y = y / this.vertices.length;
        return new Point(x, y);
      };

      ConcreteSpline.prototype.translate = function(x, y) {
        var i, vertex, _i, _len, _ref, _ref1;
        _ref = Point.pointFrom(x, y), x = _ref.x, y = _ref.y;
        _ref1 = this.vertices;
        for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
          vertex = _ref1[i];
          this.vertices[i] = vertex.add(x, y);
        }
        return this;
      };

      ConcreteSpline.prototype.rotate = function(rotation) {
        var center, i, vertex, _i, _len, _ref;
        center = this.center();
        _ref = this.vertices;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          vertex = _ref[i];
          this.vertices[i] = vertex.rotateAround(center, rotation);
        }
        return this;
      };

      ConcreteSpline.prototype.scale = function(scale) {
        var center, i, vertex, _i, _len, _ref;
        center = this.center();
        _ref = this.vertices;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          vertex = _ref[i];
          this.vertices[i] = center.add(vertex.subtract(center).scale(scale));
        }
        return this;
      };

      ConcreteSpline.prototype.points = function() {
        var i, points, segments;
        if (this.memoized('points')) {
          return this.memoFor('points').concat();
        }
        segments = this.segments() * this.bias;
        points = (function() {
          var _i, _results;
          _results = [];
          for (i = _i = 0; 0 <= segments ? _i <= segments : _i >= segments; i = 0 <= segments ? ++_i : --_i) {
            _results.push(this.pathPointAt(i / segments));
          }
          return _results;
        }).call(this);
        return this.memoize('points', points).concat();
      };

      ConcreteSpline.prototype.validateVertices = function(vertices) {
        return vertices.length % segmentSize === 1 && vertices.length >= segmentSize + 1;
      };

      ConcreteSpline.prototype.segments = function() {
        if ((this.vertices == null) || this.vertices.length === 0) {
          return 0;
        }
        if (this.memoized('segments')) {
          return this.memoFor('segments');
        }
        return this.memoize('segments', (this.vertices.length - 1) / segmentSize);
      };

      ConcreteSpline.prototype.segmentSize = function() {
        return segmentSize;
      };

      ConcreteSpline.prototype.segment = function(index) {
        var end, k, start, _ref;
        if (index < this.segments()) {
          k = "segment" + index;
          if (this.memoized(k)) {
            return this.memoFor(k);
          }
          _ref = [index * segmentSize, (index + 1) * segmentSize + 1], start = _ref[0], end = _ref[1];
          return this.memoize(k, this.vertices.slice(start, +end + 1 || 9e9));
        } else {
          return null;
        }
      };

      ConcreteSpline.prototype.length = function() {
        return this.measure(this.bias);
      };

      ConcreteSpline.prototype.measure = function(bias) {
        var i, length, _i, _ref;
        if (this.memoized('measure')) {
          return this.memoFor('measure');
        }
        length = 0;
        for (i = _i = 0, _ref = this.segments() - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          length += this.measureSegment(this.segment(i), bias);
        }
        return this.memoize('measure', length);
      };

      ConcreteSpline.prototype.measureSegment = function(segment, bias) {
        var i, k, length, step, _i;
        k = "segment" + segment + "_" + bias + "Length";
        if (this.memoized(k)) {
          return this.memoFor(k);
        }
        step = 1 / bias;
        length = 0;
        for (i = _i = 1; 1 <= bias ? _i <= bias : _i >= bias; i = 1 <= bias ? ++_i : --_i) {
          length += this.pointInSegment((i - 1) * step, segment).distance(this.pointInSegment(i * step, segment));
        }
        return this.memoize(k, length);
      };

      ConcreteSpline.prototype.pathPointAt = function(pos, pathBasedOnLength) {
        if (pathBasedOnLength == null) {
          pathBasedOnLength = true;
        }
        if (pos < 0) {
          pos = 0;
        }
        if (pos > 1) {
          pos = 1;
        }
        if (pos === 0) {
          return this.vertices[0];
        }
        if (pos === 1) {
          return this.vertices[this.vertices.length - 1];
        }
        if (pathBasedOnLength) {
          return this.walkPathBasedOnLength(pos);
        } else {
          return this.walkPathBasedOnSegments(pos);
        }
      };

      ConcreteSpline.prototype.walkPathBasedOnLength = function(pos) {
        var i, innerStepPos, length, segment, segments, stepLength, walked, _i, _ref;
        walked = 0;
        length = this.length();
        segments = this.segments();
        for (i = _i = 0, _ref = segments - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          segment = this.segment(i);
          stepLength = this.measureSegment(segment, this.bias) / length;
          if (walked + stepLength > pos) {
            innerStepPos = Math.map(pos, walked, walked + stepLength, 0, 1);
            return this.pointInSegment(innerStepPos, segment);
          }
          walked += stepLength;
        }
      };

      ConcreteSpline.prototype.walkPathBasedOnSegments = function(pos) {
        var segment, segments;
        segments = this.segments();
        pos = pos * segments;
        segment = Math.floor(pos);
        if (segment === segments) {
          segment -= 1;
        }
        return this.pointInSegment(pos - segment, this.segment(segment));
      };

      ConcreteSpline.prototype.fill = function() {};

      ConcreteSpline.prototype.drawPath = function(context) {
        var p, points, start, _i, _len, _results;
        points = this.points();
        start = points.shift();
        context.beginPath();
        context.moveTo(start.x, start.y);
        _results = [];
        for (_i = 0, _len = points.length; _i < _len; _i++) {
          p = points[_i];
          _results.push(context.lineTo(p.x, p.y));
        }
        return _results;
      };

      ConcreteSpline.prototype.drawVertices = function(context, color) {
        var vertex, _i, _len, _ref, _results;
        if (color == null) {
          color = agt.COLORS.VERTICES;
        }
        context.fillStyle = color;
        _ref = this.vertices;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          vertex = _ref[_i];
          context.beginPath();
          context.arc(vertex.x, vertex.y, 2, 0, Math.PI * 2);
          context.fill();
          _results.push(context.closePath());
        }
        return _results;
      };

      ConcreteSpline.prototype.drawVerticesConnections = function(context, color) {
        var i, vertexEnd, vertexStart, _i, _ref, _results;
        if (color == null) {
          color = agt.COLORS.VERTICES_CONNECTIONS;
        }
        context.strokeStyle = color;
        _results = [];
        for (i = _i = 1, _ref = this.vertices.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          vertexStart = this.vertices[i - 1];
          vertexEnd = this.vertices[i];
          context.beginPath();
          context.moveTo(vertexStart.x, vertexStart.y);
          context.lineTo(vertexEnd.x, vertexEnd.y);
          context.stroke();
          _results.push(context.closePath());
        }
        return _results;
      };

      ConcreteSpline.prototype.memoizationKey = function() {
        return this.vertices.map(function(pt) {
          return "" + pt.x + ";" + pt.y;
        }).join(';');
      };

      ConcreteSpline.prototype.clone = function() {
        return new this.constructor(this.vertices.map(function(pt) {
          return pt.clone();
        }), this.bias);
      };

      return ConcreteSpline;

    })();
  };

  agt.geom.Surface = (function() {
    function Surface() {}


    /* Public */

    Surface.prototype.acreage = function() {
      return null;
    };

    Surface.prototype.randomPointInSurface = function() {
      return null;
    };

    Surface.prototype.contains = function(x, y) {
      return null;
    };

    Surface.prototype.containsGeometry = function(geometry) {
      return geometry.points().every((function(_this) {
        return function(point) {
          return _this.contains(point);
        };
      })(this));
    };

    return Surface;

  })();

  agt.geom.Triangulable = (function() {
    var arrayCopy, pointInTriangle, polyArea, triangulate;

    function Triangulable() {}

    Triangulable.include(mixins.Memoizable);


    /* Public */

    Triangulable.prototype.triangles = function() {
      var a, b, c, i, index, indices, triangles, vertices, _i, _ref;
      if (this.memoized('triangles')) {
        return this.memoFor('triangles');
      }
      vertices = this.points();
      vertices.pop();
      indices = triangulate(vertices);
      triangles = [];
      for (i = _i = 0, _ref = indices.length / 3 - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        index = i * 3;
        a = vertices[indices[index]];
        b = vertices[indices[index + 1]];
        c = vertices[indices[index + 2]];
        triangles.push(new agt.geom.Triangle(a, b, c));
      }
      return this.memoize('triangles', triangles);
    };

    arrayCopy = function(arrayTo, arrayFrom) {
      var i, n, _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = arrayFrom.length; _i < _len; i = ++_i) {
        n = arrayFrom[i];
        _results.push(arrayTo[i] = n);
      }
      return _results;
    };

    pointInTriangle = function(pt, v1, v2, v3) {
      var b1, b2, b3, denom;
      denom = (v1.y - v3.y) * (v2.x - v3.x) + (v2.y - v3.y) * (v3.x - v1.x);
      b1 = ((pt.y - v3.y) * (v2.x - v3.x) + (v2.y - v3.y) * (v3.x - pt.x)) / denom;
      b2 = ((pt.y - v1.y) * (v3.x - v1.x) + (v3.y - v1.y) * (v1.x - pt.x)) / denom;
      b3 = ((pt.y - v2.y) * (v1.x - v2.x) + (v1.y - v2.y) * (v2.x - pt.x)) / denom;
      if (b1 < 0 || b2 < 0 || b3 < 0) {
        return false;
      }
      return true;
    };

    polyArea = function(pts) {
      var i, l, sum, _i, _ref;
      sum = 0;
      i = 0;
      l = pts.length;
      for (i = _i = 0, _ref = l - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        sum += pts[i].x * pts[(i + 1) % l].y - pts[(i + 1) % l].x * pts[i].y;
      }
      return sum / 2;
    };

    triangulate = function(vertices) {
      var cr, i, j, l, maxSafeGuard, n, nr, ok, pArea, pts, ptsArea, r1, r2, r3, refs, safeGuard, tArea, triangulated, v1, v2, v3;
      if (vertices.length < 4) {
        return;
      }
      safeGuard = 0;
      maxSafeGuard = 100;
      pts = vertices;
      refs = (function() {
        var _i, _len, _results;
        _results = [];
        for (i = _i = 0, _len = pts.length; _i < _len; i = ++_i) {
          n = pts[i];
          _results.push(i);
        }
        return _results;
      })();
      ptsArea = [];
      i = 0;
      l = refs.length;
      while (i < l) {
        ptsArea[i] = pts[refs[i]].clone();
        ++i;
      }
      pArea = polyArea(ptsArea);
      cr = [];
      nr = [];
      arrayCopy(cr, refs);
      while (cr.length > 3) {
        i = 0;
        l = cr.length;
        while (i < l) {
          r1 = cr[i % l];
          r2 = cr[(i + 1) % l];
          r3 = cr[(i + 2) % l];
          v1 = pts[r1];
          v2 = pts[r2];
          v3 = pts[r3];
          ok = true;
          j = (i + 3) % l;
          while (j !== i) {
            ptsArea = [v1, v2, v3];
            tArea = polyArea(ptsArea);
            if ((pArea < 0 && tArea > 0) || (pArea > 0 && tArea < 0) || pointInTriangle(pts[cr[j]], v1, v2, v3)) {
              ok = false;
              break;
            }
            j = (j + 1) % l;
            safeGuard += 1;
            if (safeGuard > maxSafeGuard) {
              break;
            }
          }
          if (ok) {
            nr.push(r1, r2, r3);
            cr.splice((i + 1) % l, 1);
            break;
          }
          ++i;
        }
      }
      nr.push.apply(nr, cr.slice(0, 3));
      triangulated = true;
      return nr;
    };

    return Triangulable;

  })();

  agt.geom.Point = (function() {
    Point.include(mixins.Equatable('x', 'y'));

    Point.include(mixins.Formattable('Point', 'x', 'y'));

    Point.include(mixins.Sourcable('agt.geom.Point', 'x', 'y'));

    Point.include(mixins.Cloneable());


    /* Public: Static methods */

    Point.isPoint = function(pt) {
      return (pt != null) && (pt.x != null) && (pt.y != null);
    };

    Point.pointFrom = function(xOrPt, y, strict) {
      var x;
      if (strict == null) {
        strict = false;
      }
      x = xOrPt;
      if ((xOrPt != null) && typeof xOrPt === 'object') {
        x = xOrPt.x, y = xOrPt.y;
      }
      if (strict && (isNaN(x) || isNaN(y))) {
        this.notAPoint([x, y]);
      }
      return new Point(x, y);
    };

    Point.polar = function(angle, length) {
      if (length == null) {
        length = 1;
      }
      return new Point(Math.sin(angle) * length, Math.cos(angle) * length);
    };

    Point.interpolate = function(pt1, pt2, pos) {
      var args, dif, extract, i, v, _i, _len;
      args = [];
      for (i = _i = 0, _len = arguments.length; _i < _len; i = ++_i) {
        v = arguments[i];
        args[i] = v;
      }
      extract = (function(_this) {
        return function(args, name) {
          var pt;
          pt = null;
          if (_this.isPoint(args[0])) {
            pt = args.shift();
          } else if (Math.isFloat(args[0]) && Math.isFloat(args[1])) {
            pt = new Point(args[0], args[1]);
            args.splice(0, 2);
          } else {
            _this.missingPoint(args, name);
          }
          return pt;
        };
      })(this);
      pt1 = extract(args, 'first');
      pt2 = extract(args, 'second');
      pos = parseFloat(args.shift());
      if (isNaN(pos)) {
        this.missingPosition(pos);
      }
      dif = pt2.subtract(pt1);
      return new Point(pt1.x + dif.x * pos, pt1.y + dif.y * pos);
    };


    /* Internal: Class error methods */

    Point.missingPosition = function(pos) {
      throw new Error("Point.interpolate require a position but " + pos + " was given");
    };

    Point.missingPoint = function(args, pos) {
      var msg;
      msg = "Can't find the " + pos + " point in Point.interpolate arguments " + args;
      throw new Error(msg);
    };

    Point.notAPoint = function(args) {
      throw new Error("" + args + " is not a point");
    };


    /* Public */

    function Point(x, y) {
      if (x != null) {
        y = x.y || y;
      }
      if (isNaN(y)) {
        y = 0;
      }
      if (x != null) {
        x = x.x || x;
      }
      if (isNaN(x)) {
        x = 0;
      }
      this.x = x;
      this.y = y;
    }

    Point.prototype.length = function() {
      return Math.sqrt((this.x * this.x) + (this.y * this.y));
    };

    Point.prototype.angle = function() {
      return Math.atan2(this.y, this.x);
    };

    Point.prototype.angleWith = function(x, y) {
      var d, isPoint;
      if ((x == null) && (y == null)) {
        this.noPoint('dot');
      }
      isPoint = this.isPoint(x);
      y = isPoint ? x.y : y;
      x = isPoint ? x.x : x;
      if (isNaN(x) || isNaN(y)) {
        Point.notAPoint([x, y]);
      }
      d = this.normalize().dot(new Point(x, y).normalize());
      return Math.acos(Math.abs(d)) * (d < 0 ? -1 : 1);
    };

    Point.prototype.normalize = function(length) {
      var l;
      if (length == null) {
        length = 1;
      }
      if (!Math.isFloat(length)) {
        this.invalidLength(length);
      }
      l = this.length();
      return new Point(this.x / l * length, this.y / l * length);
    };

    Point.prototype.add = function(x, y) {
      if (x != null) {
        y = x.y || y;
      }
      if (isNaN(y)) {
        y = 0;
      }
      if (x != null) {
        x = x.x || x;
      }
      if (isNaN(x)) {
        x = 0;
      }
      return new Point(this.x + x, this.y + y);
    };

    Point.prototype.subtract = function(x, y) {
      if (x != null) {
        y = x.y || y;
      }
      if (isNaN(y)) {
        y = 0;
      }
      if (x != null) {
        x = x.x || x;
      }
      if (isNaN(x)) {
        x = 0;
      }
      return new Point(this.x - x, this.y - y);
    };

    Point.prototype.dot = function(x, y) {
      var isPoint;
      if ((x == null) && (y == null)) {
        this.noPoint('dot');
      }
      isPoint = this.isPoint(x);
      y = isPoint ? x.y : y;
      x = isPoint ? x.x : x;
      if (isNaN(x) || isNaN(y)) {
        Point.notAPoint([x, y]);
      }
      return this.x * x + this.y * y;
    };

    Point.prototype.distance = function(x, y) {
      var isPoint;
      if ((x == null) && (y == null)) {
        this.noPoint('distance');
      }
      isPoint = this.isPoint(x);
      y = isPoint ? x.y : y;
      x = isPoint ? x.x : x;
      if (isNaN(x) || isNaN(y)) {
        Point.notAPoint([x, y]);
      }
      return this.subtract(x, y).length();
    };

    Point.prototype.scale = function(n) {
      if (!Math.isFloat(n)) {
        this.invalidScale(n);
      }
      return new Point(this.x * n, this.y * n);
    };

    Point.prototype.rotate = function(n) {
      var a, l, x, y;
      if (!Math.isFloat(n)) {
        this.invalidRotation(n);
      }
      l = this.length();
      a = Math.atan2(this.y, this.x) + n;
      x = Math.cos(a) * l;
      y = Math.sin(a) * l;
      return new Point(x, y);
    };

    Point.prototype.rotateAround = function(x, y, a) {
      var isPoint;
      isPoint = this.isPoint(x);
      if (isPoint) {
        a = y;
      }
      y = isPoint ? x.y : y;
      x = isPoint ? x.x : x;
      return this.subtract(x, y).rotate(a).add(x, y);
    };

    Point.prototype.isPoint = Point.isPoint;

    Point.prototype.pointFrom = Point.pointFrom;

    Point.prototype.defaultToZero = function(x, y) {
      x = isNaN(x) ? 0 : x;
      y = isNaN(y) ? 0 : y;
      return [x, y];
    };

    Point.prototype.paste = function(x, y) {
      var isObject;
      if ((x == null) && (y == null)) {
        return this;
      }
      isObject = (x != null) && typeof x === 'object';
      y = isObject ? x.y : y;
      x = isObject ? x.x : x;
      if (!isNaN(x)) {
        this.x = x;
      }
      if (!isNaN(y)) {
        this.y = y;
      }
      return this;
    };


    /* Internal: Instances error methods */

    Point.prototype.noPoint = function(method) {
      throw new Error("" + method + " was called without arguments");
    };

    Point.prototype.invalidLength = function(l) {
      throw new Error("Invalid length " + l + " provided");
    };

    Point.prototype.invalidScale = function(s) {
      throw new Error("Invalid scale " + s + " provided");
    };

    Point.prototype.invalidRotation = function(a) {
      throw new Error("Invalid rotation " + a + " provided");
    };

    return Point;

  })();

  _ref = agt.geom, Point = _ref.Point, Path = _ref.Path, Surface = _ref.Surface, Geometry = _ref.Geometry, Intersections = _ref.Intersections;

  agt.geom.Triangle = (function() {
    Triangle.extend(mixins.Aliasable);

    Triangle.include(mixins.Equatable('a', 'b', 'c'));

    Triangle.include(mixins.Formattable('Triangle', 'a', 'b', 'c'));

    Triangle.include(mixins.Sourcable('agt.geom.Triangle', 'a', 'b', 'c'));

    Triangle.include(mixins.Cloneable());

    Triangle.include(mixins.Memoizable);

    Triangle.include(Geometry);

    Triangle.include(Surface);

    Triangle.include(Path);

    Triangle.include(Intersections);


    /* Public */

    Triangle.triangleFrom = function(a, b, c) {
      var _ref1;
      if ((a != null) && typeof a === 'object' && !Point.isPoint(a)) {
        _ref1 = a, a = _ref1.a, b = _ref1.b, c = _ref1.c;
      }
      if (!Point.isPoint(a)) {
        this.invalidPoint('a', a);
      }
      if (!Point.isPoint(b)) {
        this.invalidPoint('b', b);
      }
      if (!Point.isPoint(c)) {
        this.invalidPoint('c', c);
      }
      return {
        a: new Point(a),
        b: new Point(b),
        c: new Point(c)
      };
    };

    function Triangle(a, b, c) {
      var _ref1;
      _ref1 = this.triangleFrom(a, b, c), this.a = _ref1.a, this.b = _ref1.b, this.c = _ref1.c;
    }

    Triangle.prototype.center = function() {
      return new Point((this.a.x + this.b.x + this.c.x) / 3, (this.a.y + this.b.y + this.c.y) / 3);
    };

    Triangle.prototype.abCenter = function() {
      return this.a.add(this.ab().scale(0.5));
    };

    Triangle.prototype.acCenter = function() {
      return this.a.add(this.ac().scale(0.5));
    };

    Triangle.prototype.bcCenter = function() {
      return this.b.add(this.bc().scale(0.5));
    };

    Triangle.prototype.edges = function() {
      return [this.ab(), this.bc(), this.ca()];
    };

    Triangle.prototype.ab = function() {
      return this.b.subtract(this.a);
    };

    Triangle.prototype.ac = function() {
      return this.c.subtract(this.a);
    };

    Triangle.prototype.ba = function() {
      return this.a.subtract(this.b);
    };

    Triangle.prototype.bc = function() {
      return this.c.subtract(this.b);
    };

    Triangle.prototype.ca = function() {
      return this.a.subtract(this.c);
    };

    Triangle.prototype.cb = function() {
      return this.b.subtract(this.c);
    };

    Triangle.prototype.abc = function() {
      return this.ba().angleWith(this.bc());
    };

    Triangle.prototype.bac = function() {
      return this.ab().angleWith(this.ac());
    };

    Triangle.prototype.acb = function() {
      return this.ca().angleWith(this.cb());
    };

    Triangle.prototype.top = function() {
      return Math.min(this.a.y, this.b.y, this.c.y);
    };

    Triangle.prototype.bottom = function() {
      return Math.max(this.a.y, this.b.y, this.c.y);
    };

    Triangle.prototype.left = function() {
      return Math.min(this.a.x, this.b.x, this.c.x);
    };

    Triangle.prototype.right = function() {
      return Math.max(this.a.x, this.b.x, this.c.x);
    };

    Triangle.prototype.equilateral = function() {
      return Math.deltaBelowRatio(this.ab().length(), this.bc().length()) && Math.deltaBelowRatio(this.ab().length(), this.ac().length());
    };

    Triangle.prototype.isosceles = function() {
      return Math.deltaBelowRatio(this.ab().length(), this.bc().length()) || Math.deltaBelowRatio(this.ab().length(), this.ac().length()) || Math.deltaBelowRatio(this.bc().length(), this.ac().length());
    };

    Triangle.prototype.rectangle = function() {
      var sqr;
      sqr = Math.PI / 2;
      return Math.deltaBelowRatio(Math.abs(this.abc()), sqr) || Math.deltaBelowRatio(Math.abs(this.bac()), sqr) || Math.deltaBelowRatio(Math.abs(this.acb()), sqr);
    };

    Triangle.prototype.translate = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y);
      this.a.x += pt.x;
      this.a.y += pt.y;
      this.b.x += pt.x;
      this.b.y += pt.y;
      this.c.x += pt.x;
      this.c.y += pt.y;
      return this;
    };

    Triangle.prototype.rotate = function(rotation) {
      var center;
      center = this.center();
      this.a = this.a.rotateAround(center, rotation);
      this.b = this.b.rotateAround(center, rotation);
      this.c = this.c.rotateAround(center, rotation);
      return this;
    };

    Triangle.alias('rotate', 'rotateAroundCenter');

    Triangle.prototype.scale = function(scale) {
      var center;
      center = this.center();
      this.a = center.add(this.a.subtract(center).scale(scale));
      this.b = center.add(this.b.subtract(center).scale(scale));
      this.c = center.add(this.c.subtract(center).scale(scale));
      return this;
    };

    Triangle.alias('scale', 'scaleAroundCenter');

    Triangle.prototype.closedGeometry = function() {
      return true;
    };

    Triangle.prototype.points = function() {
      return [this.a.clone(), this.b.clone(), this.c.clone(), this.a.clone()];
    };

    Triangle.prototype.pointAtAngle = function(angle) {
      var center, vec, _ref1;
      center = this.center();
      vec = center.add(Math.cos(angle) * 10000, Math.sin(angle) * 10000);
      return (_ref1 = this.intersections({
        points: function() {
          return [center, vec];
        }
      })) != null ? _ref1[0] : void 0;
    };

    Triangle.prototype.acreage = function() {
      if (this.memoized('acreage')) {
        return this.memoFor('acreage');
      }
      return this.memoize('acreage', this.ab().length() * this.bc().length() * Math.abs(Math.sin(this.abc())) / 2);
    };

    Triangle.prototype.contains = function(x, y) {
      var dot00, dot01, dot02, dot11, dot12, invDenom, p, u, v, v0, v1, v2;
      p = new Point(x, y);
      v0 = this.ac();
      v1 = this.ab();
      v2 = p.subtract(this.a);
      dot00 = v0.dot(v0);
      dot01 = v0.dot(v1);
      dot02 = v0.dot(v2);
      dot11 = v1.dot(v1);
      dot12 = v1.dot(v2);
      invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
      u = (dot11 * dot02 - dot01 * dot12) * invDenom;
      v = (dot00 * dot12 - dot01 * dot02) * invDenom;
      return u > 0 && v > 0 && u + v < 1;
    };

    Triangle.prototype.randomPointInSurface = function(random) {
      var a1, a2, p;
      if (random == null) {
        random = new chancejs.Random(new chancejs.MathRandom);
      }
      a1 = random.get();
      a2 = random.get();
      p = this.a.add(this.ab().scale(a1)).add(this.ca().scale(a2 * -1));
      if (this.contains(p)) {
        return p;
      } else {
        return p.add(this.bcCenter().subtract(p).scale(2));
      }
    };

    Triangle.prototype.length = function() {
      return this.ab().length() + this.bc().length() + this.ca().length();
    };

    Triangle.prototype.pathPointAt = function(n, pathBasedOnLength) {
      var l1, l2, _ref1;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      _ref1 = this.pathSteps(pathBasedOnLength), l1 = _ref1[0], l2 = _ref1[1];
      if (n < l1) {
        return this.a.add(this.ab().scale(Math.map(n, 0, l1, 0, 1)));
      } else if (n < l2) {
        return this.b.add(this.bc().scale(Math.map(n, l1, l2, 0, 1)));
      } else {
        return this.c.add(this.ca().scale(Math.map(n, l2, 1, 0, 1)));
      }
    };

    Triangle.prototype.pathOrientationAt = function(n, pathBasedOnLength) {
      var l1, l2, _ref1;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      _ref1 = this.pathSteps(pathBasedOnLength), l1 = _ref1[0], l2 = _ref1[1];
      if (n < l1) {
        return this.ab().angle();
      } else if (n < l2) {
        return this.bc().angle();
      } else {
        return this.ca().angle();
      }
    };

    Triangle.prototype.pathSteps = function(pathBasedOnLength) {
      var l, l1, l2;
      if (pathBasedOnLength) {
        l = this.length();
        l1 = this.ab().length() / l;
        l2 = l1 + this.bc().length() / l;
      } else {
        l1 = 1 / 3;
        l2 = 2 / 3;
      }
      return [l1, l2];
    };

    Triangle.prototype.drawPath = function(context) {
      context.beginPath();
      context.moveTo(this.a.x, this.a.y);
      context.lineTo(this.b.x, this.b.y);
      context.lineTo(this.c.x, this.c.y);
      context.lineTo(this.a.x, this.a.y);
      return context.closePath();
    };

    Triangle.prototype.memoizationKey = function() {
      return "" + this.a.x + ";" + this.a.y + ";" + this.b.x + ";" + this.b.y + ";" + this.c.x + ";" + this.c.y;
    };

    Triangle.prototype.triangleFrom = Triangle.triangleFrom;


    /* Internal */

    Triangle.prototype.invalidPoint = function(k, v) {
      throw new Error("Invalid point " + v + " for vertex " + k);
    };

    return Triangle;

  })();

  _ref1 = agt.geom, Point = _ref1.Point, Triangulable = _ref1.Triangulable, Proxyable = _ref1.Proxyable, Geometry = _ref1.Geometry, Surface = _ref1.Surface, Path = _ref1.Path, Intersections = _ref1.Intersections;

  agt.geom.Rectangle = (function() {
    var iterators, k, properties;

    properties = ['x', 'y', 'width', 'height', 'rotation'];

    Rectangle.extend(mixins.Aliasable);

    Rectangle.include(mixins.Cloneable());

    Rectangle.include(mixins.Equatable.apply(null, properties));

    Rectangle.include(mixins.Formattable.apply(null, ['Rectangle'].concat(properties)));

    Rectangle.include(mixins.Sourcable.apply(null, ['agt.geom.Rectangle'].concat(properties)));

    Rectangle.include(mixins.Parameterizable('rectangleFrom', {
      x: NaN,
      y: NaN,
      width: NaN,
      height: NaN,
      rotation: NaN
    }));

    Rectangle.include(Geometry);

    Rectangle.include(Surface);

    Rectangle.include(Path);

    Rectangle.include(Triangulable);

    Rectangle.include(Proxyable);

    Rectangle.include(Intersections);


    /* Public */

    Rectangle.eachRectangleRectangleIntersections = function(geom1, geom2, block, data) {
      var p, _i, _len, _ref2;
      if (data == null) {
        data = false;
      }
      if (geom1.equals(geom2)) {
        _ref2 = geom1.points();
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          p = _ref2[_i];
          if (block.call(this, p)) {
            return;
          }
        }
      } else {
        return this.eachIntersections(geom1, geom2, block, data);
      }
    };

    iterators = Intersections.iterators;

    k = 'RectangleRectangle';

    iterators[k] = Rectangle.eachRectangleRectangleIntersections;

    function Rectangle(x, y, width, height, rotation) {
      var args;
      args = this.defaultToZero(this.rectangleFrom.apply(this, arguments));
      this.x = args.x, this.y = args.y, this.width = args.width, this.height = args.height, this.rotation = args.rotation;
    }

    Rectangle.prototype.corners = function() {
      return [this.topLeft(), this.topRight(), this.bottomRight(), this.bottomLeft()];
    };

    Rectangle.prototype.topLeft = function() {
      return new Point(this.x, this.y);
    };

    Rectangle.prototype.topRight = function() {
      return this.topLeft().add(this.topEdge());
    };

    Rectangle.prototype.bottomLeft = function() {
      return this.topLeft().add(this.leftEdge());
    };

    Rectangle.prototype.bottomRight = function() {
      return this.topLeft().add(this.topEdge()).add(this.leftEdge());
    };

    Rectangle.prototype.center = function() {
      return this.topLeft().add(this.diagonal().scale(0.5));
    };

    Rectangle.prototype.topEdgeCenter = function() {
      return this.topLeft().add(this.topEdge().scale(0.5));
    };

    Rectangle.prototype.bottomEdgeCenter = function() {
      return this.bottomLeft().add(this.topEdge().scale(0.5));
    };

    Rectangle.prototype.leftEdgeCenter = function() {
      return this.topLeft().add(this.leftEdge().scale(0.5));
    };

    Rectangle.prototype.rightEdgeCenter = function() {
      return this.topRight().add(this.leftEdge().scale(0.5));
    };

    Rectangle.prototype.edges = function() {
      return [this.topEdge(), this.topRight(), this.bottomRight(), this.bottomLeft()];
    };

    Rectangle.prototype.topEdge = function() {
      return new Point(this.width * Math.cos(this.rotation), this.width * Math.sin(this.rotation));
    };

    Rectangle.prototype.leftEdge = function() {
      return new Point(this.height * Math.cos(this.rotation + Math.PI / 2), this.height * Math.sin(this.rotation + Math.PI / 2));
    };

    Rectangle.prototype.bottomEdge = function() {
      return this.topEdge();
    };

    Rectangle.prototype.rightEdge = function() {
      return this.leftEdge();
    };

    Rectangle.prototype.diagonal = function() {
      return this.leftEdge().add(this.topEdge());
    };

    Rectangle.prototype.top = function() {
      return Math.min(this.y, this.topRight().y, this.bottomRight().y, this.bottomLeft().y);
    };

    Rectangle.prototype.bottom = function() {
      return Math.max(this.y, this.topRight().y, this.bottomRight().y, this.bottomLeft().y);
    };

    Rectangle.prototype.left = function() {
      return Math.min(this.x, this.topRight().x, this.bottomRight().x, this.bottomLeft().x);
    };

    Rectangle.prototype.right = function() {
      return Math.max(this.x, this.topRight().x, this.bottomRight().x, this.bottomLeft().x);
    };

    Rectangle.prototype.setCenter = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y).subtract(this.center());
      this.x += pt.x;
      this.y += pt.y;
      return this;
    };

    Rectangle.prototype.translate = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y);
      this.x += pt.x;
      this.y += pt.y;
      return this;
    };

    Rectangle.prototype.rotate = function(rotation) {
      var _ref2;
      _ref2 = this.topLeft().rotateAround(this.center(), rotation), this.x = _ref2.x, this.y = _ref2.y;
      this.rotation += rotation;
      return this;
    };

    Rectangle.alias('rotate', 'rotateAroundCenter');

    Rectangle.prototype.scale = function(scale) {
      var center;
      center = this.center();
      this.width *= scale;
      this.height *= scale;
      this.setCenter(center);
      return this;
    };

    Rectangle.alias('scale', 'scaleAroundCenter');

    Rectangle.prototype.inflateAroundCenter = function(x, y) {
      var center;
      center = this.center();
      this.inflate(x, y);
      this.setCenter(center);
      return this;
    };

    Rectangle.prototype.inflate = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y);
      this.width += pt.x;
      this.height += pt.y;
      return this;
    };

    Rectangle.prototype.inflateLeft = function(inflate) {
      var offset, _ref2;
      this.width += inflate;
      offset = this.topEdge().normalize(-inflate);
      _ref2 = this.topLeft().add(offset), this.x = _ref2.x, this.y = _ref2.y;
      return this;
    };

    Rectangle.prototype.inflateRight = function(inflate) {
      this.width += inflate;
      return this;
    };

    Rectangle.prototype.inflateTop = function(inflate) {
      var offset, _ref2;
      this.height += inflate;
      offset = this.leftEdge().normalize(-inflate);
      _ref2 = this.topLeft().add(offset), this.x = _ref2.x, this.y = _ref2.y;
      return this;
    };

    Rectangle.prototype.inflateBottom = function(inflate) {
      this.height += inflate;
      return this;
    };

    Rectangle.prototype.inflateTopLeft = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y);
      this.inflateLeft(pt.x);
      this.inflateTop(pt.y);
      return this;
    };

    Rectangle.prototype.inflateTopRight = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y);
      this.inflateRight(pt.x);
      this.inflateTop(pt.y);
      return this;
    };

    Rectangle.prototype.inflateBottomLeft = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y);
      this.inflateLeft(pt.x);
      this.inflateBottom(pt.y);
      return this;
    };

    Rectangle.prototype.inflateBottomRight = function(x, y) {
      return this.inflate(x, y);
    };

    Rectangle.prototype.closedGeometry = function() {
      return true;
    };

    Rectangle.prototype.points = function() {
      return [this.topLeft(), this.topRight(), this.bottomRight(), this.bottomLeft(), this.topLeft()];
    };

    Rectangle.prototype.pointAtAngle = function(angle) {
      var center, vec, _ref2;
      center = this.center();
      vec = center.add(Math.cos(angle) * 10000, Math.sin(angle) * 10000);
      return (_ref2 = this.intersections({
        points: function() {
          return [center, vec];
        }
      })) != null ? _ref2[0] : void 0;
    };

    Rectangle.prototype.acreage = function() {
      return this.width * this.height;
    };

    Rectangle.prototype.contains = function(x, y) {
      var _ref2;
      _ref2 = new Point(x, y).rotateAround(this.topLeft(), -this.rotation), x = _ref2.x, y = _ref2.y;
      return ((this.x <= x && x <= this.x + this.width)) && ((this.y <= y && y <= this.y + this.height));
    };

    Rectangle.prototype.randomPointInSurface = function(random) {
      if (random == null) {
        random = new chancejs.Random(new chancejs.MathRandom);
      }
      return this.topLeft().add(this.topEdge().scale(random.get())).add(this.leftEdge().scale(random.get()));
    };

    Rectangle.prototype.length = function() {
      return this.width * 2 + this.height * 2;
    };

    Rectangle.prototype.pathPointAt = function(n, pathBasedOnLength) {
      var p1, p2, p3, _ref2;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      _ref2 = this.pathSteps(pathBasedOnLength), p1 = _ref2[0], p2 = _ref2[1], p3 = _ref2[2];
      if (n < p1) {
        return this.topLeft().add(this.topEdge().scale(Math.map(n, 0, p1, 0, 1)));
      } else if (n < p2) {
        return this.topRight().add(this.rightEdge().scale(Math.map(n, p1, p2, 0, 1)));
      } else if (n < p3) {
        return this.bottomRight().add(this.bottomEdge().scale(Math.map(n, p2, p3, 0, 1) * -1));
      } else {
        return this.bottomLeft().add(this.leftEdge().scale(Math.map(n, p3, 1, 0, 1) * -1));
      }
    };

    Rectangle.prototype.pathOrientationAt = function(n, pathBasedOnLength) {
      var p, p1, p2, p3, _ref2;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      _ref2 = this.pathSteps(pathBasedOnLength), p1 = _ref2[0], p2 = _ref2[1], p3 = _ref2[2];
      if (n < p1) {
        p = this.topEdge();
      } else if (n < p2) {
        p = this.rightEdge();
      } else if (n < p3) {
        p = this.bottomEdge().scale(-1);
      } else {
        p = this.leftEdge().scale(-1);
      }
      return p.angle();
    };

    Rectangle.prototype.pathSteps = function(pathBasedOnLength) {
      var l, p1, p2, p3;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      if (pathBasedOnLength) {
        l = this.length();
        p1 = this.width / l;
        p2 = (this.width + this.height) / l;
        p3 = p1 + p2;
      } else {
        p1 = 1 / 4;
        p2 = 1 / 2;
        p3 = 3 / 4;
      }
      return [p1, p2, p3];
    };

    Rectangle.prototype.drawPath = function(context) {
      context.beginPath();
      context.moveTo(this.x, this.y);
      context.lineTo(this.topRight().x, this.topRight().y);
      context.lineTo(this.bottomRight().x, this.bottomRight().y);
      context.lineTo(this.bottomLeft().x, this.bottomLeft().y);
      context.lineTo(this.x, this.y);
      return context.closePath();
    };

    Rectangle.prototype.paste = function(x, y, width, height, rotation) {
      var v, values, _results;
      values = this.rectangleFrom(x, y, width, height, rotation);
      _results = [];
      for (k in values) {
        v = values[k];
        if (Math.isFloat(v)) {
          _results.push(this[k] = parseFloat(v));
        }
      }
      return _results;
    };

    Rectangle.prototype.defaultToZero = function(values) {
      var v;
      for (k in values) {
        v = values[k];
        if (!Math.isFloat(v)) {
          values[k] = 0;
        }
      }
      return values;
    };

    Rectangle.proxy('pathOrientationAt', {
      as: 'Angle'
    });

    Rectangle.proxy('points', 'corners', 'edges', {
      as: 'PointList'
    });

    Rectangle.proxy('topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'center', 'topEdgeCenter', 'bottomEdgeCenter', 'leftEdgeCenter', 'rightEdgeCenter', 'topEdge', 'leftEdge', 'rightEdge', 'bottomEdge', 'diagonal', 'pathPointAt', {
      as: 'Point'
    });

    return Rectangle;

  })();

  _ref2 = agt.geom, Point = _ref2.Point, Triangle = _ref2.Triangle, Geometry = _ref2.Geometry, Surface = _ref2.Surface, Path = _ref2.Path, Intersections = _ref2.Intersections;

  agt.geom.Circle = (function() {
    var iterators;

    Circle.include(mixins.Equatable('x', 'y', 'radius', 'rotation'));

    Circle.include(mixins.Formattable('Circle', 'x', 'y', 'radius', 'rotation'));

    Circle.include(mixins.Parameterizable('circleFrom', {
      radius: 1,
      x: 0,
      y: 0,
      rotation: 0,
      segments: 36
    }));

    Circle.include(mixins.Sourcable('agt.geom.Circle', 'radius', 'x', 'y', 'rotation', 'segments'));

    Circle.include(mixins.Cloneable());

    Circle.include(mixins.Memoizable);

    Circle.include(Geometry);

    Circle.include(Surface);

    Circle.include(Path);

    Circle.include(Intersections);


    /* Public */

    Circle.eachIntersections = function(geom1, geom2, block) {
      var ev, i, length, output, points, sv, _i, _ref3, _ref4;
      if ((typeof geom2.classname === "function" ? geom2.classname() : void 0) === 'Circle') {
        _ref3 = [geom2, geom1], geom1 = _ref3[0], geom2 = _ref3[1];
      }
      points = geom2.points();
      length = points.length;
      output = [];
      for (i = _i = 0, _ref4 = length - 2; 0 <= _ref4 ? _i <= _ref4 : _i >= _ref4; i = 0 <= _ref4 ? ++_i : --_i) {
        sv = points[i];
        ev = points[i + 1];
        if (geom1.eachLineIntersections(sv, ev, block)) {
          return;
        }
      }
    };

    Circle.eachCircleCircleIntersections = function(geom1, geom2, block) {
      var a, d, dv, h, hv, p, p1, p2, r1, r2, radii, _i, _len, _ref3;
      if (geom1.equals(geom2)) {
        _ref3 = geom1.points();
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          p = _ref3[_i];
          if (block.call(this, p)) {
            return;
          }
        }
      } else {
        r1 = geom1.radius;
        r2 = geom2.radius;
        p1 = geom1.center();
        p2 = geom2.center();
        d = p1.distance(p2);
        dv = p2.subtract(p1);
        radii = r1 + r2;
        if (d > radii) {
          return;
        }
        if (d === radii) {
          return block.call(this, p1.add(dv.normalize(r1)));
        }
        a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
        h = Math.sqrt(r1 * r1 - a * a);
        hv = new Point(h * (p2.y - p1.y) / d, -h * (p2.x - p1.x) / d);
        p = p1.add(dv.normalize(a)).add(hv);
        block.call(this, p);
        p = p1.add(dv.normalize(a)).add(hv.scale(-1));
        return block.call(this, p);
      }
    };

    iterators = Intersections.iterators;

    iterators['Circle'] = Circle.eachIntersections;

    iterators['CircleCircle'] = Circle.eachCircleCircleIntersections;

    function Circle(radius, x, y, rotation, segments) {
      var _ref3;
      _ref3 = this.circleFrom(radius, x, y, rotation, segments), this.radius = _ref3.radius, this.x = _ref3.x, this.y = _ref3.y, this.rotation = _ref3.rotation, this.segments = _ref3.segments;
    }

    Circle.prototype.center = function() {
      return new Point(this.x, this.y);
    };

    Circle.prototype.top = function() {
      return this.y - this.radius;
    };

    Circle.prototype.bottom = function() {
      return this.y + this.radius;
    };

    Circle.prototype.left = function() {
      return this.x - this.radius;
    };

    Circle.prototype.right = function() {
      return this.x + this.radius;
    };

    Circle.prototype.translate = function(x, y) {
      var _ref3;
      _ref3 = Point.pointFrom(x, y), x = _ref3.x, y = _ref3.y;
      this.x += x;
      this.y += y;
      return this;
    };

    Circle.prototype.rotate = function(rotation) {
      this.rotation += rotation;
      return this;
    };

    Circle.prototype.scale = function(scale) {
      this.radius *= scale;
      return this;
    };

    Circle.prototype.points = function() {
      var n, step, _i, _ref3, _results;
      step = Math.PI * 2 / this.segments;
      _results = [];
      for (n = _i = 0, _ref3 = this.segments; 0 <= _ref3 ? _i <= _ref3 : _i >= _ref3; n = 0 <= _ref3 ? ++_i : --_i) {
        _results.push(this.pointAtAngle(n * step));
      }
      return _results;
    };

    Circle.prototype.triangles = function() {
      var center, i, points, triangles, _i, _ref3;
      if (this.memoized('triangles')) {
        return this.memoFor('triangles');
      }
      triangles = [];
      points = this.points();
      center = this.center();
      for (i = _i = 1, _ref3 = points.length - 1; 1 <= _ref3 ? _i <= _ref3 : _i >= _ref3; i = 1 <= _ref3 ? ++_i : --_i) {
        triangles.push(new Triangle(center, points[i - 1], points[i]));
      }
      return this.memoize('triangles', triangles);
    };

    Circle.prototype.closedGeometry = function() {
      return true;
    };

    Circle.prototype.eachLineIntersections = function(a, b, block) {
      var c, cc, deter, e, u1, u2, _a, _b;
      c = this.center();
      _a = (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y);
      _b = 2 * ((b.x - a.x) * (a.x - c.x) + (b.y - a.y) * (a.y - c.y));
      cc = c.x * c.x + c.y * c.y + a.x * a.x + a.y * a.y - 2 * (c.x * a.x + c.y * a.y) - this.radius * this.radius;
      deter = _b * _b - 4 * _a * cc;
      if (deter > 0) {
        e = Math.sqrt(deter);
        u1 = (-_b + e) / (2 * _a);
        u2 = (-_b - e) / (2 * _a);
        if (!((u1 < 0 || u1 > 1) && (u2 < 0 || u2 > 1))) {
          if (0 <= u2 && u2 <= 1) {
            if (block.call(this, Point.interpolate(a, b, u2))) {
              return;
            }
          }
          if (0 <= u1 && u1 <= 1) {
            if (block.call(this, Point.interpolate(a, b, u1))) {

            }
          }
        }
      }
    };

    Circle.prototype.pointAtAngle = function(angle) {
      return new Point(this.x + Math.cos(this.rotation + angle) * this.radius, this.y + Math.sin(this.rotation + angle) * this.radius);
    };

    Circle.prototype.acreage = function() {
      return this.radius * this.radius * Math.PI;
    };

    Circle.prototype.contains = function(x, y) {
      var pt;
      pt = Point.pointFrom(x, y, true);
      return this.center().subtract(pt).length() <= this.radius;
    };

    Circle.prototype.randomPointInSurface = function(random) {
      var center, dif, pt;
      if (random == null) {
        random = new random.Random(new random.MathRandom);
      }
      pt = this.pointAtAngle(random.random(Math.PI * 2));
      center = this.center();
      dif = pt.subtract(center);
      return center.add(dif.scale(Math.sqrt(random.random())));
    };

    Circle.prototype.length = function() {
      return this.radius * Math.PI * 2;
    };

    Circle.prototype.pathPointAt = function(n) {
      return this.pointAtAngle(n * Math.PI * 2);
    };

    Circle.prototype.drawPath = function(context) {
      context.beginPath();
      return context.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
    };

    Circle.prototype.memoizationKey = function() {
      return "" + this.radius + ";" + this.x + ";" + this.y + ";" + this.rotation + ";" + this.segments;
    };

    return Circle;

  })();

  _ref3 = agt.geom, Point = _ref3.Point, Intersections = _ref3.Intersections, Geometry = _ref3.Geometry, Spline = _ref3.Spline, Path = _ref3.Path;

  agt.geom.CubicBezier = (function() {
    CubicBezier.include(mixins.Formattable('CubicBezier'));

    CubicBezier.include(mixins.Sourcable('agt.geom.CubicBezier', 'vertices', 'bias'));

    CubicBezier.include(Geometry);

    CubicBezier.include(Path);

    CubicBezier.include(Intersections);

    CubicBezier.include(Spline(3));


    /* Public */

    function CubicBezier(vertices, bias) {
      if (bias == null) {
        bias = 20;
      }
      this.initSpline(vertices, bias);
    }

    CubicBezier.prototype.pointInSegment = function(t, seg) {
      var pt;
      pt = new Point();
      pt.x = (seg[0].x * this.b1(t)) + (seg[1].x * this.b2(t)) + (seg[2].x * this.b3(t)) + (seg[3].x * this.b4(t));
      pt.y = (seg[0].y * this.b1(t)) + (seg[1].y * this.b2(t)) + (seg[2].y * this.b3(t)) + (seg[3].y * this.b4(t));
      return pt;
    };


    /* Internal */

    CubicBezier.prototype.b1 = function(t) {
      return (1 - t) * (1 - t) * (1 - t);
    };

    CubicBezier.prototype.b2 = function(t) {
      return 3 * t * (1 - t) * (1 - t);
    };

    CubicBezier.prototype.b3 = function(t) {
      return 3 * t * t * (1 - t);
    };

    CubicBezier.prototype.b4 = function(t) {
      return t * t * t;
    };

    return CubicBezier;

  })();

  _ref4 = agt.geom, Geometry = _ref4.Geometry, Surface = _ref4.Surface, Path = _ref4.Path, Intersections = _ref4.Intersections;

  agt.geom.Diamond = (function() {
    var properties;

    properties = ['topLength', 'rightLength', 'bottomLength', 'leftLength', 'x', 'y', 'rotation'];

    Diamond.include(mixins.Formattable.apply(mixins, ['Diamond'].concat(properties)));

    Diamond.include(mixins.Parameterizable('diamondFrom', {
      topLength: 1,
      rightLength: 1,
      bottomLength: 1,
      leftLength: 1,
      x: 0,
      y: 0,
      rotation: 0
    }));

    Diamond.include(mixins.Sourcable(['agt.geom.Diamond'].concat(properties)));

    Diamond.include(mixins.Equatable.apply(mixins, properties));

    Diamond.include(mixins.Cloneable());

    Diamond.include(mixins.Memoizable);

    Diamond.include(Geometry);

    Diamond.include(Surface);

    Diamond.include(Path);

    Diamond.include(Intersections);


    /* Public */

    function Diamond(topLength, rightLength, bottomLength, leftLength, x, y, rotation) {
      var args;
      args = this.diamondFrom(topLength, rightLength, bottomLength, leftLength, x, y, rotation);
      this.topLength = args.topLength, this.rightLength = args.rightLength, this.bottomLength = args.bottomLength, this.leftLength = args.leftLength, this.x = args.x, this.y = args.y, this.rotation = args.rotation;
    }

    Diamond.prototype.center = function() {
      return new geom.Point(this.x, this.y);
    };

    Diamond.prototype.topAxis = function() {
      return new geom.Point(0, -this.topLength).rotate(this.rotation);
    };

    Diamond.prototype.bottomAxis = function() {
      return new geom.Point(0, this.bottomLength).rotate(this.rotation);
    };

    Diamond.prototype.leftAxis = function() {
      return new geom.Point(-this.leftLength, 0).rotate(this.rotation);
    };

    Diamond.prototype.rightAxis = function() {
      return new geom.Point(this.rightLength, 0).rotate(this.rotation);
    };

    Diamond.prototype.corners = function() {
      return [this.topCorner(), this.rightCorner(), this.bottomCorner(), this.leftCorner()];
    };

    Diamond.prototype.topCorner = function() {
      return this.center().add(this.topAxis());
    };

    Diamond.prototype.bottomCorner = function() {
      return this.center().add(this.bottomAxis());
    };

    Diamond.prototype.leftCorner = function() {
      return this.center().add(this.leftAxis());
    };

    Diamond.prototype.rightCorner = function() {
      return this.center().add(this.rightAxis());
    };

    Diamond.prototype.edges = function() {
      return [this.topLeftEdge(), this.topRightEdge(), this.bottomRightEdge(), this.bottomLeftEdge()];
    };

    Diamond.prototype.topLeftEdge = function() {
      return this.topCorner().subtract(this.leftCorner());
    };

    Diamond.prototype.topRightEdge = function() {
      return this.rightCorner().subtract(this.topCorner());
    };

    Diamond.prototype.bottomLeftEdge = function() {
      return this.leftCorner().subtract(this.bottomCorner());
    };

    Diamond.prototype.bottomRightEdge = function() {
      return this.bottomCorner().subtract(this.rightCorner());
    };

    Diamond.prototype.quadrants = function() {
      return [this.topLeftQuadrant(), this.topRightQuadrant(), this.bottomRightQuadrant(), this.bottomLeftQuadrant()];
    };

    Diamond.prototype.topLeftQuadrant = function() {
      var k;
      k = 'topLeftQuadrant';
      if (this.memoized(k)) {
        return this.memoFor(k);
      }
      return this.memoize(k, new geom.Triangle(this.center(), this.topCorner(), this.leftCorner()));
    };

    Diamond.prototype.topRightQuadrant = function() {
      var k;
      k = 'topRightQuadrant';
      if (this.memoized(k)) {
        return this.memoFor(k);
      }
      return this.memoize(k, new geom.Triangle(this.center(), this.topCorner(), this.rightCorner()));
    };

    Diamond.prototype.bottomLeftQuadrant = function() {
      var k;
      k = 'bottomLeftQuadrant';
      if (this.memoized(k)) {
        return this.memoFor(k);
      }
      return this.memoize(k, new geom.Triangle(this.center(), this.bottomCorner(), this.leftCorner()));
    };

    Diamond.prototype.bottomRightQuadrant = function() {
      var k;
      k = 'bottomRightQuadrant';
      if (this.memoized(k)) {
        return this.memoFor(k);
      }
      return this.memoize(k, new geom.Triangle(this.center(), this.bottomCorner(), this.rightCorner()));
    };

    Diamond.prototype.top = function() {
      return Math.min(this.topCorner().y, this.bottomCorner().y, this.leftCorner().y, this.rightCorner().y);
    };

    Diamond.prototype.bottom = function() {
      return Math.max(this.topCorner().y, this.bottomCorner().y, this.leftCorner().y, this.rightCorner().y);
    };

    Diamond.prototype.left = function() {
      return Math.min(this.topCorner().x, this.bottomCorner().x, this.leftCorner().x, this.rightCorner().x);
    };

    Diamond.prototype.right = function() {
      return Math.max(this.topCorner().x, this.bottomCorner().x, this.leftCorner().x, this.rightCorner().x);
    };

    Diamond.prototype.translate = function(xOrPt, y) {
      var x, _ref5;
      _ref5 = geom.Point.pointFrom(xOrPt, y), x = _ref5.x, y = _ref5.y;
      this.x += x;
      this.y += y;
      return this;
    };

    Diamond.prototype.rotate = function(rotation) {
      this.rotation += rotation;
      return this;
    };

    Diamond.prototype.scale = function(scale) {
      this.topLength *= scale;
      this.bottomLength *= scale;
      this.rightLength *= scale;
      this.leftLength *= scale;
      return this;
    };

    Diamond.prototype.points = function() {
      var t;
      return [t = this.topCorner(), this.rightCorner(), this.bottomCorner(), this.leftCorner(), t];
    };

    Diamond.prototype.triangles = function() {
      return this.quadrants();
    };

    Diamond.prototype.closedGeometry = function() {
      return true;
    };

    Diamond.prototype.pointAtAngle = function(angle) {
      var center, vec, _ref5;
      center = this.center();
      vec = center.add(Math.cos(angle) * 10000, Math.sin(angle) * 10000);
      return (_ref5 = this.intersections({
        points: function() {
          return [center, vec];
        }
      })) != null ? _ref5[0] : void 0;
    };

    Diamond.prototype.acreage = function() {
      return this.topLeftQuadrant().acreage() + this.topRightQuadrant().acreage() + this.bottomLeftQuadrant().acreage() + this.bottomRightQuadrant().acreage();
    };

    Diamond.prototype.contains = function(x, y) {
      return this.center().equals(x, y) || this.topLeftQuadrant().contains(x, y) || this.topRightQuadrant().contains(x, y) || this.bottomLeftQuadrant().contains(x, y) || this.bottomRightQuadrant().contains(x, y);
    };

    Diamond.prototype.randomPointInSurface = function(random) {
      var a, a1, a2, a3, a4, l, l1, l2, l3, l4, n, q1, q2, q3, q4;
      l = this.acreage();
      q1 = this.topLeftQuadrant();
      q2 = this.topRightQuadrant();
      q3 = this.bottomRightQuadrant();
      q4 = this.bottomLeftQuadrant();
      a1 = q1.acreage();
      a2 = q2.acreage();
      a3 = q3.acreage();
      a4 = q4.acreage();
      a = a1 + a2 + a3 + a4;
      l1 = a1 / a;
      l2 = a2 / a;
      l3 = a3 / a;
      l4 = a4 / a;
      n = random.get();
      if (n < l1) {
        return q1.randomPointInSurface(random);
      } else if (n < l1 + l2) {
        return q2.randomPointInSurface(random);
      } else if (n < l1 + l2 + l3) {
        return q3.randomPointInSurface(random);
      } else {
        return q4.randomPointInSurface(random);
      }
    };

    Diamond.prototype.length = function() {
      return this.topRightEdge().length() + this.topLeftEdge().length() + this.bottomRightEdge().length() + this.bottomLeftEdge().length();
    };

    Diamond.prototype.pathPointAt = function(n, pathBasedOnLength) {
      var p1, p2, p3, _ref5;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      _ref5 = this.pathSteps(pathBasedOnLength), p1 = _ref5[0], p2 = _ref5[1], p3 = _ref5[2];
      if (n < p1) {
        return this.topCorner().add(this.topRightEdge().scale(Math.map(n, 0, p1, 0, 1)));
      } else if (n < p2) {
        return this.rightCorner().add(this.bottomRightEdge().scale(Math.map(n, p1, p2, 0, 1)));
      } else if (n < p3) {
        return this.bottomCorner().add(this.bottomLeftEdge().scale(Math.map(n, p2, p3, 0, 1)));
      } else {
        return this.leftCorner().add(this.topLeftEdge().scale(Math.map(n, p3, 1, 0, 1)));
      }
    };

    Diamond.prototype.pathOrientationAt = function(n, pathBasedOnLength) {
      var p, p1, p2, p3, _ref5;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      _ref5 = this.pathSteps(pathBasedOnLength), p1 = _ref5[0], p2 = _ref5[1], p3 = _ref5[2];
      if (n < p1) {
        p = this.topRightEdge();
      } else if (n < p2) {
        p = this.bottomRightEdge();
      } else if (n < p3) {
        p = this.bottomLeftEdge().scale(-1);
      } else {
        p = this.topLeftEdge().scale(-1);
      }
      return p.angle();
    };

    Diamond.prototype.pathSteps = function(pathBasedOnLength) {
      var l, p1, p2, p3;
      if (pathBasedOnLength == null) {
        pathBasedOnLength = true;
      }
      if (pathBasedOnLength) {
        l = this.length();
        p1 = this.topRightEdge().length() / l;
        p2 = p1 + this.bottomRightEdge().length() / l;
        p3 = p2 + this.bottomLeftEdge().length() / l;
      } else {
        p1 = 1 / 4;
        p2 = 1 / 2;
        p3 = 3 / 4;
      }
      return [p1, p2, p3];
    };

    Diamond.prototype.memoizationKey = function() {
      return "" + this.x + ";" + this.y + ";" + this.rotation + ";" + this.topLength + ";" + this.bottomLength + ";" + this.leftLength + ";" + this.rightLength + ";";
    };

    return Diamond;

  })();

  _ref5 = agt.geom, Point = _ref5.Point, Geometry = _ref5.Geometry, Triangle = _ref5.Triangle, Surface = _ref5.Surface, Path = _ref5.Path, Intersections = _ref5.Intersections;

  agt.geom.Ellipsis = (function() {
    var properties;

    properties = ['radius1', 'radius2', 'x', 'y', 'rotation', 'segments'];

    Ellipsis.include(mixins.Equatable.apply(mixins, properties));

    Ellipsis.include(mixins.Formattable.apply(mixins, ['Ellipsis'].concat(properties)));

    Ellipsis.include(mixins.Parameterizable('ellipsisFrom', {
      radius1: 1,
      radius2: 1,
      x: 0,
      y: 0,
      rotation: 0,
      segments: 36
    }));

    Ellipsis.include(mixins.Sourcable.apply(mixins, ['agt.geom.Ellipsis'].concat(properties)));

    Ellipsis.include(mixins.Cloneable());

    Ellipsis.include(mixins.Memoizable);

    Ellipsis.include(Geometry);

    Ellipsis.include(Surface);

    Ellipsis.include(Path);

    Ellipsis.include(Intersections);


    /* Public */

    function Ellipsis(r1, r2, x, y, rot, segments) {
      var _ref6;
      _ref6 = this.ellipsisFrom(r1, r2, x, y, rot, segments), this.radius1 = _ref6.radius1, this.radius2 = _ref6.radius2, this.x = _ref6.x, this.y = _ref6.y, this.rotation = _ref6.rotation, this.segments = _ref6.segments;
    }

    Ellipsis.prototype.center = function() {
      return new Point(this.x, this.y);
    };

    Ellipsis.prototype.left = function() {
      return Math.min.apply(Math, this.xBounds());
    };

    Ellipsis.prototype.right = function() {
      return Math.max.apply(Math, this.xBounds());
    };

    Ellipsis.prototype.bottom = function() {
      return Math.max.apply(Math, this.yBounds());
    };

    Ellipsis.prototype.top = function() {
      return Math.min.apply(Math, this.yBounds());
    };

    Ellipsis.prototype.xBounds = function() {
      var phi, t;
      phi = this.rotation;
      t = Math.atan(-this.radius2 * Math.tan(phi) / this.radius1);
      return [t, t + Math.PI].map((function(_this) {
        return function(t) {
          return _this.x + _this.radius1 * Math.cos(t) * Math.cos(phi) - _this.radius2 * Math.sin(t) * Math.sin(phi);
        };
      })(this));
    };

    Ellipsis.prototype.yBounds = function() {
      var phi, t;
      phi = this.rotation;
      t = Math.atan(this.radius2 * (Math.cos(phi) / Math.sin(phi)) / this.radius1);
      return [t, t + Math.PI].map((function(_this) {
        return function(t) {
          return _this.y + _this.radius1 * Math.cos(t) * Math.sin(phi) + _this.radius2 * Math.sin(t) * Math.cos(phi);
        };
      })(this));
    };

    Ellipsis.prototype.translate = function(xOrPt, y) {
      var x, _ref6;
      _ref6 = Point.pointFrom(xOrPt, y), x = _ref6.x, y = _ref6.y;
      this.x += x;
      this.y += y;
      return this;
    };

    Ellipsis.prototype.rotate = function(rotation) {
      this.rotation += rotation;
      return this;
    };

    Ellipsis.prototype.scale = function(scale) {
      this.radius1 *= scale;
      this.radius2 *= scale;
      return this;
    };

    Ellipsis.prototype.points = function() {
      var n;
      if (this.memoized('points')) {
        this.memoFor('points').concat();
      }
      return this.memoize('points', (function() {
        var _i, _ref6, _results;
        _results = [];
        for (n = _i = 0, _ref6 = this.segments; 0 <= _ref6 ? _i <= _ref6 : _i >= _ref6; n = 0 <= _ref6 ? ++_i : --_i) {
          _results.push(this.pathPointAt(n / this.segments));
        }
        return _results;
      }).call(this));
    };

    Ellipsis.prototype.triangles = function() {
      var center, i, points, triangles, _i, _ref6;
      if (this.memoized('triangles')) {
        return this.memoFor('triangles');
      }
      triangles = [];
      points = this.points();
      center = this.center();
      for (i = _i = 1, _ref6 = points.length - 1; 1 <= _ref6 ? _i <= _ref6 : _i >= _ref6; i = 1 <= _ref6 ? ++_i : --_i) {
        triangles.push(new Triangle(center, points[i - 1], points[i]));
      }
      return this.memoize('triangles', triangles);
    };

    Ellipsis.prototype.closedGeometry = function() {
      return true;
    };

    Ellipsis.prototype.pointAtAngle = function(angle) {
      var a, p, ratio, vec;
      a = angle - this.rotation;
      ratio = this.radius1 / this.radius2;
      vec = new Point(Math.cos(a) * this.radius1, Math.sin(a) * this.radius1);
      if (this.radius1 < this.radius2) {
        vec.x = vec.x / ratio;
      }
      if (this.radius1 > this.radius2) {
        vec.y = vec.y * ratio;
      }
      a = vec.angle();
      p = new Point(Math.cos(a) * this.radius1, Math.sin(a) * this.radius2);
      return this.center().add(p.rotate(this.rotation));
    };

    Ellipsis.prototype.acreage = function() {
      return Math.PI * this.radius1 * this.radius2;
    };

    Ellipsis.prototype.randomPointInSurface = function(random) {
      var center, dif, pt;
      if (random == null) {
        random = new random.Random(new random.MathRandom);
      }
      pt = this.pathPointAt(random.get());
      center = this.center();
      dif = pt.subtract(center);
      return center.add(dif.scale(Math.sqrt(random.random())));
    };

    Ellipsis.prototype.contains = function(xOrPt, y) {
      var a, c, d, p, p2;
      p = new Point(xOrPt, y);
      c = this.center();
      d = p.subtract(c);
      a = d.angle();
      p2 = this.pointAtAngle(a);
      return c.distance(p2) >= c.distance(p);
    };

    Ellipsis.prototype.length = function() {
      return Math.PI * (3 * (this.radius1 + this.radius2) - Math.sqrt((3 * this.radius1 + this.radius2) * (this.radius1 + this.radius2 * 3)));
    };

    Ellipsis.prototype.pathPointAt = function(n) {
      var a, p;
      a = n * Math.PI * 2;
      p = new Point(Math.cos(a) * this.radius1, Math.sin(a) * this.radius2);
      return this.center().add(p.rotate(this.rotation));
    };

    Ellipsis.prototype.drawPath = function(context) {
      context.save();
      context.translate(this.x, this.y);
      context.rotate(this.rotation);
      context.scale(this.radius1, this.radius2);
      context.beginPath();
      context.arc(0, 0, 1, 0, Math.PI * 2);
      context.closePath();
      return context.restore();
    };

    Ellipsis.prototype.memoizationKey = function() {
      return "" + this.radius1 + ";" + this.radius2 + ";" + this.x + ";" + this.y + ";" + this.rotation + ";" + this.segments;
    };

    return Ellipsis;

  })();

  _ref6 = agt.geom, Point = _ref6.Point, Intersections = _ref6.Intersections, Geometry = _ref6.Geometry, Spline = _ref6.Spline, Path = _ref6.Path;

  agt.geom.LinearSpline = (function() {
    LinearSpline.include(mixins.Formattable('LinearSpline'));

    LinearSpline.include(mixins.Sourcable('agt.geom.LinearSpline', 'vertices', 'bias'));

    LinearSpline.include(Geometry);

    LinearSpline.include(Path);

    LinearSpline.include(Intersections);

    LinearSpline.include(Spline(1));


    /* Public */

    function LinearSpline(vertices, bias) {
      this.initSpline(vertices, bias);
    }

    LinearSpline.prototype.points = function() {
      var vertex, _i, _len, _ref7, _results;
      _ref7 = this.vertices;
      _results = [];
      for (_i = 0, _len = _ref7.length; _i < _len; _i++) {
        vertex = _ref7[_i];
        _results.push(vertex.clone());
      }
      return _results;
    };

    LinearSpline.prototype.segments = function() {
      return this.vertices.length - 1;
    };

    LinearSpline.prototype.validateVertices = function(vertices) {
      return vertices.length >= 2;
    };

    LinearSpline.prototype.drawVerticesConnections = function() {};

    return LinearSpline;

  })();

  Point = agt.geom.Point;

  agt.geom.Matrix = (function() {
    var properties;

    properties = ['a', 'b', 'c', 'd', 'tx', 'ty'];

    Matrix.include(mixins.Equatable.apply(mixins, properties));

    Matrix.include(mixins.Formattable.apply(mixins, ['Matrix'].concat(properties)));

    Matrix.include(mixins.Sourcable.apply(mixins, ['agt.geom.Matrix'].concat(properties)));

    Matrix.include(mixins.Parameterizable('matrixFrom', {
      a: 1,
      b: 0,
      c: 0,
      d: 1,
      tx: 0,
      ty: 0
    }));

    Matrix.include(mixins.Cloneable());


    /* Public */

    Matrix.isMatrix = function(m) {
      var k, _i, _len;
      if (m == null) {
        return false;
      }
      for (_i = 0, _len = PROPERTIES.length; _i < _len; _i++) {
        k = PROPERTIES[_i];
        if (!Math.isFloat(m[k])) {
          return false;
        }
      }
      return true;
    };

    function Matrix(a, b, c, d, tx, ty) {
      var _ref7;
      if (a == null) {
        a = 1;
      }
      if (b == null) {
        b = 0;
      }
      if (c == null) {
        c = 0;
      }
      if (d == null) {
        d = 1;
      }
      if (tx == null) {
        tx = 0;
      }
      if (ty == null) {
        ty = 0;
      }
      _ref7 = this.matrixFrom(a, b, c, d, tx, ty, true), this.a = _ref7.a, this.b = _ref7.b, this.c = _ref7.c, this.d = _ref7.d, this.tx = _ref7.tx, this.ty = _ref7.ty;
    }

    Matrix.prototype.transformPoint = function(xOrPt, y) {
      var x, _ref7;
      if ((xOrPt == null) && (y == null)) {
        throw new Error("transformPoint was called without arguments");
      }
      _ref7 = Point.pointFrom(xOrPt, y, true), x = _ref7.x, y = _ref7.y;
      return new Point(x * this.a + y * this.c + this.tx, x * this.b + y * this.d + this.ty);
    };

    Matrix.prototype.translate = function(xOrPt, y) {
      var x, _ref7;
      if (xOrPt == null) {
        xOrPt = 0;
      }
      if (y == null) {
        y = 0;
      }
      _ref7 = Point.pointFrom(xOrPt, y), x = _ref7.x, y = _ref7.y;
      this.tx += x;
      this.ty += y;
      return this;
    };

    Matrix.prototype.scale = function(xOrPt, y) {
      var x, _ref7;
      if (xOrPt == null) {
        xOrPt = 1;
      }
      if (y == null) {
        y = 1;
      }
      _ref7 = Point.pointFrom(xOrPt, y), x = _ref7.x, y = _ref7.y;
      this.a *= x;
      this.d *= y;
      this.tx *= x;
      this.ty *= y;
      return this;
    };

    Matrix.prototype.rotate = function(angle) {
      var cos, sin, _ref7;
      if (angle == null) {
        angle = 0;
      }
      cos = Math.cos(angle);
      sin = Math.sin(angle);
      _ref7 = [this.a * cos - this.b * sin, this.a * sin + this.b * cos, this.c * cos - this.d * sin, this.c * sin + this.d * cos, this.tx * cos - this.ty * sin, this.tx * sin + this.ty * cos], this.a = _ref7[0], this.b = _ref7[1], this.c = _ref7[2], this.d = _ref7[3], this.tx = _ref7[4], this.ty = _ref7[5];
      return this;
    };

    Matrix.prototype.skew = function(xOrPt, y) {
      var pt;
      pt = Point.pointFrom(xOrPt, y, 0);
      return this.append(Math.cos(pt.y), Math.sin(pt.y), -Math.sin(pt.x), Math.cos(pt.x));
    };

    Matrix.prototype.append = function(a, b, c, d, tx, ty) {
      var _ref7, _ref8;
      if (a == null) {
        a = 1;
      }
      if (b == null) {
        b = 0;
      }
      if (c == null) {
        c = 0;
      }
      if (d == null) {
        d = 1;
      }
      if (tx == null) {
        tx = 0;
      }
      if (ty == null) {
        ty = 0;
      }
      _ref7 = this.matrixFrom(a, b, c, d, tx, ty, true), a = _ref7.a, b = _ref7.b, c = _ref7.c, d = _ref7.d, tx = _ref7.tx, ty = _ref7.ty;
      _ref8 = [a * this.a + b * this.c, a * this.b + b * this.d, c * this.a + d * this.c, c * this.b + d * this.d, tx * this.a + ty * this.c + this.tx, tx * this.b + ty * this.d + this.ty], this.a = _ref8[0], this.b = _ref8[1], this.c = _ref8[2], this.d = _ref8[3], this.tx = _ref8[4], this.ty = _ref8[5];
      return this;
    };

    Matrix.prototype.prepend = function(a, b, c, d, tx, ty) {
      var _ref7, _ref8, _ref9;
      if (a == null) {
        a = 1;
      }
      if (b == null) {
        b = 0;
      }
      if (c == null) {
        c = 0;
      }
      if (d == null) {
        d = 1;
      }
      if (tx == null) {
        tx = 0;
      }
      if (ty == null) {
        ty = 0;
      }
      _ref7 = this.matrixFrom(a, b, c, d, tx, ty, true), a = _ref7.a, b = _ref7.b, c = _ref7.c, d = _ref7.d, tx = _ref7.tx, ty = _ref7.ty;
      if (a !== 1 || b !== 0 || c !== 0 || d !== 1) {
        _ref8 = [this.a * a + this.b * c, this.a * b + this.b * d, this.c * a + this.d * c, this.c * b + this.d * d], this.a = _ref8[0], this.b = _ref8[1], this.c = _ref8[2], this.d = _ref8[3];
      }
      _ref9 = [this.tx * a + this.ty * c + tx, this.tx * b + this.ty * d + ty], this.tx = _ref9[0], this.ty = _ref9[1];
      return this;
    };

    Matrix.prototype.identity = function() {
      var _ref7;
      _ref7 = [1, 0, 0, 1, 0, 0], this.a = _ref7[0], this.b = _ref7[1], this.c = _ref7[2], this.d = _ref7[3], this.tx = _ref7[4], this.ty = _ref7[5];
      return this;
    };

    Matrix.prototype.inverse = function() {
      var n, _ref7;
      n = this.a * this.d - this.b * this.c;
      _ref7 = [this.d / n, -this.b / n, -this.c / n, this.a / n, (this.c * this.ty - this.d * this.tx) / n, -(this.a * this.ty - this.b * this.tx) / n], this.a = _ref7[0], this.b = _ref7[1], this.c = _ref7[2], this.d = _ref7[3], this.tx = _ref7[4], this.ty = _ref7[5];
      return this;
    };

    Matrix.prototype.isMatrix = function(m) {
      return Matrix.isMatrix(m);
    };

    return Matrix;

  })();

  _ref7 = agt.geom, Point = _ref7.Point, Triangulable = _ref7.Triangulable, Geometry = _ref7.Geometry, Surface = _ref7.Surface, Path = _ref7.Path, Intersections = _ref7.Intersections;

  agt.geom.Polygon = (function() {
    Polygon.extend(mixins.Aliasable);

    Polygon.include(mixins.Formattable('Polygon', 'vertices'));

    Polygon.include(mixins.Sourcable('agt.geom.Polygon', 'vertices'));

    Polygon.include(mixins.Cloneable());

    Polygon.include(Geometry);

    Polygon.include(Intersections);

    Polygon.include(Triangulable);

    Polygon.include(Surface);

    Polygon.include(Path);


    /* Public */

    Polygon.polygonFrom = function(vertices) {
      var isArray;
      if ((vertices != null) && typeof vertices === 'object') {
        isArray = Object.prototype.toString.call(vertices).indexOf('Array') !== -1;
        if (!isArray) {
          return vertices;
        }
        return {
          vertices: vertices
        };
      } else {
        return {
          vertices: null
        };
      }
    };

    function Polygon(vertices) {
      vertices = this.polygonFrom(vertices).vertices;
      if (vertices == null) {
        this.noVertices();
      }
      if (vertices.length < 3) {
        this.notEnougthVertices(vertices);
      }
      this.vertices = vertices;
    }

    Polygon.prototype.center = function() {
      var vertex, x, y, _i, _len, _ref8;
      x = y = 0;
      _ref8 = this.vertices;
      for (_i = 0, _len = _ref8.length; _i < _len; _i++) {
        vertex = _ref8[_i];
        x += vertex.x;
        y += vertex.y;
      }
      x = x / this.vertices.length;
      y = y / this.vertices.length;
      return new Point(x, y);
    };

    Polygon.prototype.translate = function(x, y) {
      var vertex, _i, _len, _ref8, _ref9;
      _ref8 = Point.pointFrom(x, y), x = _ref8.x, y = _ref8.y;
      _ref9 = this.vertices;
      for (_i = 0, _len = _ref9.length; _i < _len; _i++) {
        vertex = _ref9[_i];
        vertex.x += x;
        vertex.y += y;
      }
      return this;
    };

    Polygon.prototype.rotate = function(rotation) {
      var center, i, vertex, _i, _len, _ref8;
      center = this.center();
      _ref8 = this.vertices;
      for (i = _i = 0, _len = _ref8.length; _i < _len; i = ++_i) {
        vertex = _ref8[i];
        this.vertices[i] = vertex.rotateAround(center, rotation);
      }
      return this;
    };

    Polygon.alias('rotate', 'rotateAroundCenter');

    Polygon.prototype.scale = function(scale) {
      var center, i, vertex, _i, _len, _ref8;
      center = this.center();
      _ref8 = this.vertices;
      for (i = _i = 0, _len = _ref8.length; _i < _len; i = ++_i) {
        vertex = _ref8[i];
        this.vertices[i] = center.add(vertex.subtract(center).scale(scale));
      }
      return this;
    };

    Polygon.alias('scale', 'scaleAroundCenter');

    Polygon.prototype.points = function() {
      var vertex;
      return ((function() {
        var _i, _len, _ref8, _results;
        _ref8 = this.vertices;
        _results = [];
        for (_i = 0, _len = _ref8.length; _i < _len; _i++) {
          vertex = _ref8[_i];
          _results.push(vertex.clone());
        }
        return _results;
      }).call(this)).concat(this.vertices[0].clone());
    };

    Polygon.prototype.closedGeometry = function() {
      return true;
    };

    Polygon.prototype.pointAtAngle = function(angle) {
      var center, distance, vec, _ref8;
      center = this.center();
      distance = function(a, b) {
        return a.distance(center) - b.distance(center);
      };
      vec = center.add(Math.cos(angle) * 10000, Math.sin(angle) * 10000);
      return (_ref8 = this.intersections({
        points: function() {
          return [center, vec];
        }
      })) != null ? _ref8.sort(distance)[0] : void 0;
    };

    Polygon.prototype.acreage = function() {
      var acreage, tri, _i, _len, _ref8;
      acreage = 0;
      _ref8 = this.triangles();
      for (_i = 0, _len = _ref8.length; _i < _len; _i++) {
        tri = _ref8[_i];
        acreage += tri.acreage();
      }
      return acreage;
    };

    Polygon.prototype.contains = function(x, y) {
      var tri, _i, _len, _ref8;
      _ref8 = this.triangles();
      for (_i = 0, _len = _ref8.length; _i < _len; _i++) {
        tri = _ref8[_i];
        if (tri.contains(x, y)) {
          return true;
        }
      }
      return false;
    };

    Polygon.prototype.randomPointInSurface = function(random) {
      var acreage, i, n, ratios, triangles, _i, _len;
      if (random == null) {
        random = new chancejs.Random(new chancejs.MathRandom);
      }
      acreage = this.acreage();
      triangles = this.triangles();
      ratios = triangles.map(function(t, i) {
        return t.acreage() / acreage;
      });
      for (i = _i = 0, _len = ratios.length; _i < _len; i = ++_i) {
        n = ratios[i];
        if (i > 0) {
          ratios[i] += ratios[i - 1];
        }
      }
      return random.inArray(triangles, ratios, true).randomPointInSurface(random);
    };

    Polygon.prototype.length = function() {
      var i, length, points, _i, _ref8;
      length = 0;
      points = this.points();
      for (i = _i = 1, _ref8 = points.length - 1; 1 <= _ref8 ? _i <= _ref8 : _i >= _ref8; i = 1 <= _ref8 ? ++_i : --_i) {
        length += points[i - 1].distance(points[i]);
      }
      return length;
    };

    Polygon.prototype.memoizationKey = function() {
      return this.vertices.map(function(pt) {
        return "" + pt.x + "," + pt.y;
      }).join(";");
    };


    /* Internal */

    Polygon.prototype.polygonFrom = Polygon.polygonFrom;

    Polygon.prototype.noVertices = function() {
      throw new Error('No vertices provided to Polygon');
    };

    Polygon.prototype.notEnougthVertices = function(vertices) {
      var length;
      length = vertices.length;
      throw new Error("Polygon must have at least 3 vertices, was " + length);
    };

    return Polygon;

  })();

  _ref8 = agt.geom, Point = _ref8.Point, Intersections = _ref8.Intersections, Geometry = _ref8.Geometry, Spline = _ref8.Spline, Path = _ref8.Path;

  agt.geom.QuadBezier = (function() {
    QuadBezier.include(mixins.Formattable('QuadBezier'));

    QuadBezier.include(mixins.Sourcable('agt.geom.QuadBezier', 'vertices', 'bias'));

    QuadBezier.include(Geometry);

    QuadBezier.include(Path);

    QuadBezier.include(Intersections);

    QuadBezier.include(Spline(2));


    /* Public */

    function QuadBezier(vertices, bias) {
      if (bias == null) {
        bias = 20;
      }
      this.initSpline(vertices, bias);
    }

    QuadBezier.prototype.pointInSegment = function(t, seg) {
      var pt;
      pt = new Point();
      pt.x = (seg[0].x * this.b1(t)) + (seg[1].x * this.b2(t)) + (seg[2].x * this.b3(t));
      pt.y = (seg[0].y * this.b1(t)) + (seg[1].y * this.b2(t)) + (seg[2].y * this.b3(t));
      return pt;
    };


    /* Internal */

    QuadBezier.prototype.b1 = function(t) {
      return (1 - t) * (1 - t);
    };

    QuadBezier.prototype.b2 = function(t) {
      return 2 * t * (1 - t);
    };

    QuadBezier.prototype.b3 = function(t) {
      return t * t;
    };

    return QuadBezier;

  })();

  _ref9 = agt.geom, Point = _ref9.Point, Intersections = _ref9.Intersections, Geometry = _ref9.Geometry, Spline = _ref9.Spline, Path = _ref9.Path;

  agt.geom.QuintBezier = (function() {
    QuintBezier.include(mixins.Formattable('QuintBezier'));

    QuintBezier.include(mixins.Sourcable('agt.geom.QuintBezier', 'vertices', 'bias'));

    QuintBezier.include(Geometry);

    QuintBezier.include(Path);

    QuintBezier.include(Intersections);

    QuintBezier.include(Spline(4));


    /* Public */

    function QuintBezier(vertices, bias) {
      if (bias == null) {
        bias = 20;
      }
      this.initSpline(vertices, bias);
    }

    QuintBezier.prototype.pointInSegment = function(t, seg) {
      var pt;
      pt = new Point();
      pt.x = (seg[0].x * this.b1(t)) + (seg[1].x * this.b2(t)) + (seg[2].x * this.b3(t)) + (seg[3].x * this.b4(t)) + (seg[4].x * this.b5(t));
      pt.y = (seg[0].y * this.b1(t)) + (seg[1].y * this.b2(t)) + (seg[2].y * this.b3(t)) + (seg[3].y * this.b4(t)) + (seg[4].y * this.b5(t));
      return pt;
    };


    /* Internal */

    QuintBezier.prototype.b1 = function(t) {
      return (1 - t) * (1 - t) * (1 - t) * (1 - t);
    };

    QuintBezier.prototype.b2 = function(t) {
      return 4 * t * (1 - t) * (1 - t) * (1 - t);
    };

    QuintBezier.prototype.b3 = function(t) {
      return 6 * t * t * (1 - t) * (1 - t);
    };

    QuintBezier.prototype.b4 = function(t) {
      return 4 * t * t * t * (1 - t);
    };

    QuintBezier.prototype.b5 = function(t) {
      return t * t * t * t;
    };

    return QuintBezier;

  })();

  _ref10 = agt.geom, Point = _ref10.Point, Ellipsis = _ref10.Ellipsis, Geometry = _ref10.Geometry, Path = _ref10.Path, Intersections = _ref10.Intersections;

  agt.geom.Spiral = (function() {
    var memoizationKey, properties;

    properties = ['radius1', 'radius2', 'twirl', 'x', 'y', 'rotation', 'segments'];

    Spiral.include(mixins.Equatable.apply(null, properties));

    Spiral.include(mixins.Formattable.apply(null, ['Spiral'].concat(properties)));

    Spiral.include(mixins.Parameterizable('spiralFrom', {
      radius1: 1,
      radius2: 1,
      twirl: 1,
      x: 0,
      y: 0,
      rotation: 0,
      segments: 36
    }));

    Spiral.include(mixins.Sourcable.apply(null, ['agt.geom.Spiral'].concat(properties)));

    Spiral.include(mixins.Cloneable());

    Spiral.include(mixins.Memoizable);

    Spiral.include(Geometry);

    Spiral.include(Path);

    Spiral.include(Intersections);


    /* Public */

    function Spiral(r1, r2, twirl, x, y, rot, segments) {
      var _ref11;
      _ref11 = this.spiralFrom(r1, r2, twirl, x, y, rot, segments), this.radius1 = _ref11.radius1, this.radius2 = _ref11.radius2, this.twirl = _ref11.twirl, this.x = _ref11.x, this.y = _ref11.y, this.rotation = _ref11.rotation, this.segments = _ref11.segments;
    }

    Spiral.prototype.center = function() {
      return new Point(this.x, this.y);
    };

    Spiral.prototype.ellipsis = function() {
      if (this.memoized('ellipsis')) {
        return this.memoFor('ellipsis');
      }
      return this.memoize('ellipsis', new Ellipsis(this));
    };

    Spiral.prototype.translate = function(x, y) {
      var _ref11;
      _ref11 = Point.pointFrom(x, y), x = _ref11.x, y = _ref11.y;
      this.x += x;
      this.y += y;
      return this;
    };

    Spiral.prototype.rotate = function(rotation) {
      this.rotation += rotation;
      return this;
    };

    Spiral.prototype.scale = function(scale) {
      this.radius1 *= scale;
      this.radius2 *= scale;
      return this;
    };

    Spiral.prototype.points = function() {
      var center, ellipsis, i, p, points, _i, _ref11;
      if (this.memoized('points')) {
        return this.memoFor('points').concat();
      }
      points = [];
      center = this.center();
      ellipsis = this.ellipsis();
      for (i = _i = 0, _ref11 = this.segments; 0 <= _ref11 ? _i <= _ref11 : _i >= _ref11; i = 0 <= _ref11 ? ++_i : --_i) {
        p = i / this.segments;
        points.push(this.pathPointAt(p));
      }
      return this.memoize('points', points);
    };

    Spiral.prototype.pathPointAt = function(pos, posBasedOnLength) {
      var PI2, angle, center, ellipsis, pt, _ref11;
      if (posBasedOnLength == null) {
        posBasedOnLength = true;
      }
      center = this.center();
      ellipsis = this.ellipsis();
      PI2 = Math.PI * 2;
      angle = this.rotation + pos * PI2 * this.twirl % PI2;
      pt = (_ref11 = ellipsis.pointAtAngle(angle)) != null ? _ref11.subtract(center).scale(pos) : void 0;
      return center.add(pt);
    };

    Spiral.prototype.fill = function() {};

    Spiral.prototype.drawPath = function(context) {
      var p, points, start, _i, _len, _results;
      points = this.points();
      start = points.shift();
      context.beginPath();
      context.moveTo(start.x, start.y);
      _results = [];
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        p = points[_i];
        _results.push(context.lineTo(p.x, p.y));
      }
      return _results;
    };

    memoizationKey = function() {
      return "" + this.radius1 + ";" + this.radius2 + ";" + this.twirl + ";" + this.x + ";" + this.y + ";" + this.rotation + ";" + this.segments;
    };

    return Spiral;

  })();

  Point = agt.geom.Point;

  agt.geom.TransformationProxy = (function() {

    /* Public */
    TransformationProxy.defineProxy = function(key, type) {
      switch (type) {
        case 'PointList':
          return this.prototype[key] = function() {
            var points;
            points = this.geometry[key].apply(this.geometry, arguments);
            if (this.matrix != null) {
              return points.map((function(_this) {
                return function(pt) {
                  return _this.matrix.transformPoint(pt);
                };
              })(this));
            } else {
              return points;
            }
          };
        case 'Point':
          return this.prototype[key] = function() {
            var point;
            point = this.geometry[key].apply(this.geometry, arguments);
            if (this.matrix != null) {
              return this.matrix.transformPoint(point);
            } else {
              return point;
            }
          };
        case 'Angle':
          return this.prototype[key] = function() {
            var angle, vec;
            angle = this.geometry[key].apply(this.geometry, arguments);
            if (this.matrix != null) {
              vec = new Point(Math.cos(angle), Math.sin(angle));
              return this.matrix.transformPoint(vec).angle();
            } else {
              return angle;
            }
          };
      }
    };

    function TransformationProxy(geometry, matrix) {
      this.geometry = geometry;
      this.matrix = matrix;
      this.proxiedMethods = this.detectProxyableMethods(this.geometry);
    }

    TransformationProxy.prototype.proxied = function() {
      var k, v, _ref11, _results;
      _ref11 = this.proxiedMethods;
      _results = [];
      for (k in _ref11) {
        v = _ref11[k];
        _results.push(k);
      }
      return _results;
    };

    TransformationProxy.prototype.detectProxyableMethods = function(geometry) {
      var k, proxiedMethods, v, _ref11;
      proxiedMethods = {};
      _ref11 = geometry.constructor.prototype;
      for (k in _ref11) {
        v = _ref11[k];
        if (v.proxyable) {
          proxiedMethods[k] = v.proxyable;
          TransformationProxy.defineProxy(k, v.proxyable);
        }
      }
      return proxiedMethods;
    };

    return TransformationProxy;

  })();

  Point = agt.geom.Point;

  agt.particles.Particle = (function() {
    function Particle() {}

    Particle.concern(agt.mixins.Poolable);


    /* Public */

    Particle.prototype.init = function(options) {
      var k, v, _results;
      if (options == null) {
        options = {};
      }
      this.dead = false;
      this.life = 0;
      this.maxLife = 0;
      this.position = new Point;
      this.lastPosition = new Point;
      this.velocity = new Point;
      this.parasite = {};
      _results = [];
      for (k in options) {
        v = options[k];
        _results.push(this[k] = v);
      }
      return _results;
    };

    Particle.prototype.dispose = function() {
      this.position = null;
      this.lastPosition = null;
      this.velocity = null;
      return this.parasite = null;
    };

    Particle.prototype.die = function() {
      this.dead = true;
      return this.life = this.maxLife;
    };

    Particle.prototype.revive = function() {
      this.dead = false;
      return this.life = 0;
    };

    return Particle;

  })();

  Particle = agt.particles.Particle;

  NullTimer = agt.particles.timers.NullTimer;

  NullCounter = agt.particles.counters.NullCounter;

  NullEmitter = agt.particles.emitters.NullEmitter;

  agt.particles.Emission = (function() {

    /* Public */
    function Emission(particleType, emitter, timer, counter, initializer) {
      this.particleType = particleType != null ? particleType : Particle;
      this.emitter = emitter != null ? emitter : new NullEmitter();
      this.timer = timer != null ? timer : new NullTimer();
      this.counter = counter != null ? counter : new NullCounter();
      this.initializer = initializer != null ? initializer : null;
    }

    Emission.prototype.prepare = function(bias, biasInSeconds, time) {
      var nextTime;
      this.timer.prepare(bias, biasInSeconds, time);
      nextTime = this.timer.nextTime;
      this.counter.prepare(nextTime, nextTime / 1000, time);
      this.currentCount = this.counter.count;
      this.currentTime = nextTime;
      return this.iterator = 0;
    };

    Emission.prototype.hasNext = function() {
      return this.iterator < this.currentCount;
    };

    Emission.prototype.next = function() {
      var particle, _ref11;
      particle = this.particleType.get({
        position: this.emitter.get()
      });
      if ((_ref11 = this.initializer) != null) {
        _ref11.initialize(particle);
      }
      this.iterator++;
      return particle;
    };

    Emission.prototype.nextTime = function() {
      return this.currentTime - this.iterator / this.currentCount * this.currentTime;
    };

    Emission.prototype.finished = function() {
      return this.timer.finished();
    };

    return Emission;

  })();

  Signal = agt.Signal;

  Impulse = agt.Impulse;

  NullInitializer = agt.particles.initializers.NullInitializer;

  NullAction = agt.particles.actions.NullAction;

  agt.particles.System = (function() {

    /* Public */
    function System(initializer, action, subSystem) {
      this.initializer = initializer != null ? initializer : new NullInitializer;
      this.action = action != null ? action : new NullAction;
      this.subSystem = subSystem;
      this.particlesCreated = new Signal;
      this.particlesDied = new Signal;
      this.emissionStarted = new Signal;
      this.emissionFinished = new Signal;
      this.particles = [];
      this.emissions = [];
    }

    System.prototype.emit = function(emission) {
      this.emissions.push(emission);
      emission.system = this;
      return this.startEmission(emission);
    };

    System.prototype.startEmission = function(emission) {
      emission.prepare(0, 0, this.getTime());
      this.created = [];
      this.died = [];
      if (!this.running) {
        this.start();
      }
      this.processEmission(emission);
      this.emissionStarted.dispatch(this, emission);
      if (this.created.length > 0) {
        this.particlesCreated.dispatch(this, this.created);
      }
      if (this.died.length > 0) {
        this.particlesDied.dispatch(this, this.died);
      }
      this.died = null;
      return this.created = null;
    };

    System.prototype.start = function() {
      if (!this.running) {
        Impulse.instance().add(this.tick, this);
        return this.running = true;
      }
    };

    System.prototype.stop = function() {
      if (this.running) {
        Impulse.instance().remove(this.tick, this);
        return this.running = false;
      }
    };

    System.prototype.tick = function(bias, biasInSeconds, time) {
      this.died = [];
      this.created = [];
      this.processParticles(bias, biasInSeconds, time);
      if (this.emitting()) {
        this.processEmissions(bias, biasInSeconds, time);
      }
      if (this.created.length > 0) {
        this.particlesCreated.dispatch(this, this.created);
      }
      if (this.died.length > 0) {
        this.particlesDied.dispatch(this, this.died);
      }
      this.died = null;
      return this.created = null;
    };

    System.prototype.emitting = function() {
      return this.emissions.length > 0;
    };

    System.prototype.processEmissions = function(bias, biasInSeconds, time) {
      var emission, _i, _len, _ref11, _results;
      _ref11 = this.emissions.concat();
      _results = [];
      for (_i = 0, _len = _ref11.length; _i < _len; _i++) {
        emission = _ref11[_i];
        emission.prepare(bias, biasInSeconds, time);
        _results.push(this.processEmission(emission));
      }
      return _results;
    };

    System.prototype.processEmission = function(emission) {
      var particle, time, _results;
      _results = [];
      while (emission.hasNext()) {
        time = emission.nextTime();
        particle = emission.next();
        this.created.push(particle);
        this.registerParticle(particle);
        this.initializeParticle(particle, time);
        if (emission.finished()) {
          this.removeEmission(emission);
          _results.push(this.emissionFinished.dispatch(this, emission));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    System.prototype.removeEmission = function(emission) {
      return this.emissions.splice(this.emissions.indexOf(emission), 1);
    };

    System.prototype.processParticles = function(bias, biasInSeconds, time) {
      var particle, _i, _len, _ref11, _results;
      this.action.prepare(bias, biasInSeconds, time);
      _ref11 = this.particles.concat();
      _results = [];
      for (_i = 0, _len = _ref11.length; _i < _len; _i++) {
        particle = _ref11[_i];
        this.action.process(particle);
        if (particle.dead) {
          _results.push(this.unregisterParticle(particle));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    System.prototype.initializeParticle = function(particle, time) {
      this.initializer.initialize(particle);
      this.action.prepare(time, time / 1000, this.getTime());
      this.action.process(particle);
      if (particle.dead) {
        return this.unregisterParticle(particle);
      }
    };

    System.prototype.registerParticle = function(particle) {
      return this.particles.push(particle);
    };

    System.prototype.unregisterParticle = function(particle) {
      var _ref11;
      this.died.push(particle);
      if ((_ref11 = this.subSystem) != null) {
        _ref11.emitFor(particle);
      }
      this.particles.splice(this.particles.indexOf(particle), 1);
      return particle.constructor.release(particle);
    };

    System.prototype.getTime = function() {
      return new Date().valueOf();
    };

    return System;

  })();

  agt.particles.SubSystem = (function(_super) {
    __extends(SubSystem, _super);


    /* Public */

    function SubSystem(initializer, action, emissionFactory, subSystem) {
      this.emissionFactory = emissionFactory;
      SubSystem.__super__.constructor.call(this, initializer, action, subSystem);
    }

    SubSystem.prototype.emitFor = function(particle) {
      return this.emit(this.emissionFactory(particle));
    };

    return SubSystem;

  })(agt.particles.System);

  _ref11 = agt.random, Random = _ref11.Random, MathRandom = _ref11.MathRandom;

  DEFAULT_RANDOM = new Random(new MathRandom);

  agt.particles.Randomizable = (function() {
    function Randomizable() {}


    /* Public */

    Randomizable.prototype.initRandom = function() {
      return this.random || (this.random = DEFAULT_RANDOM);
    };

    return Randomizable;

  })();

  agt.particles.actions.BaseAction = (function() {
    function BaseAction() {}


    /* Public */

    BaseAction.prototype.prepare = function(bias, biasInSeconds, time) {
      this.bias = bias;
      this.biasInSeconds = biasInSeconds;
      this.time = time;
    };

    return BaseAction;

  })();

  agt.particles.actions.DieOnSurface = (function() {

    /* Public */
    function DieOnSurface(surfaces) {
      this.surfaces = surfaces;
      if (Object.prototype.toString.call(this.surface).indexOf('Array') === -1) {
        this.surfaces = [this.surfaces];
      }
    }

    DieOnSurface.prototype.prepare = function() {};

    DieOnSurface.prototype.process = function(p) {
      var surface, _i, _len, _ref12;
      _ref12 = this.surfaces;
      for (_i = 0, _len = _ref12.length; _i < _len; _i++) {
        surface = _ref12[_i];
        if (surface.contains(p.position)) {
          return p.die();
        }
      }
    };

    return DieOnSurface;

  })();

  agt.particles.actions.Force = (function(_super) {
    __extends(Force, _super);


    /* Public */

    function Force(vector) {
      this.vector = vector != null ? vector : new agt.geom.Point;
    }

    Force.prototype.process = function(particle) {
      particle.velocity.x += this.vector.x * this.biasInSeconds;
      return particle.velocity.y += this.vector.y * this.biasInSeconds;
    };

    return Force;

  })(agt.particles.actions.BaseAction);

  agt.particles.actions.Friction = (function(_super) {
    __extends(Friction, _super);


    /* Public */

    function Friction(amount) {
      this.amount = amount != null ? amount : 1;
    }

    Friction.prototype.process = function(particle) {
      var fx, fy;
      fx = particle.velocity.x * this.biasInSeconds * this.amount;
      fy = particle.velocity.y * this.biasInSeconds * this.amount;
      particle.velocity.x -= fx;
      return particle.velocity.y -= fy;
    };

    return Friction;

  })(agt.particles.actions.BaseAction);

  agt.particles.actions.Live = (function(_super) {
    __extends(Live, _super);

    function Live() {
      return Live.__super__.constructor.apply(this, arguments);
    }


    /* Public */

    Live.prototype.process = function(particle) {
      particle.life += this.bias;
      if (particle.life >= particle.maxLife) {
        return particle.die();
      }
    };

    return Live;

  })(agt.particles.actions.BaseAction);

  agt.particles.actions.MacroAction = (function(_super) {
    __extends(MacroAction, _super);


    /* Public */

    function MacroAction(actions) {
      this.actions = actions != null ? actions : [];
    }

    MacroAction.prototype.prepare = function(bias, biasInSeconds, time) {
      var action, _i, _len, _ref12, _results;
      _ref12 = this.actions;
      _results = [];
      for (_i = 0, _len = _ref12.length; _i < _len; _i++) {
        action = _ref12[_i];
        _results.push(action.prepare(bias, biasInSeconds, time));
      }
      return _results;
    };

    MacroAction.prototype.process = function(particle) {
      var action, _i, _len, _ref12, _results;
      _ref12 = this.actions;
      _results = [];
      for (_i = 0, _len = _ref12.length; _i < _len; _i++) {
        action = _ref12[_i];
        _results.push(action.process(particle));
      }
      return _results;
    };

    return MacroAction;

  })(agt.particles.actions.BaseAction);

  agt.particles.actions.Move = (function(_super) {
    __extends(Move, _super);

    function Move() {
      return Move.__super__.constructor.apply(this, arguments);
    }


    /* Public */

    Move.prototype.process = function(particle) {
      particle.lastPosition.x = particle.position.x;
      particle.lastPosition.y = particle.position.y;
      particle.position.x += particle.velocity.x * this.biasInSeconds;
      return particle.position.y += particle.velocity.y * this.biasInSeconds;
    };

    return Move;

  })(agt.particles.actions.BaseAction);

  agt.particles.actions.NullAction = (function() {
    function NullAction() {}


    /* Public */

    NullAction.prototype.prepare = function() {};

    NullAction.prototype.process = function() {};

    return NullAction;

  })();

  agt.particles.counters.ByRate = (function() {

    /* Public */
    function ByRate(rate) {
      this.rate = rate != null ? rate : 1;
      this.count = 0;
      this.rest = 0;
      this.offset = 1;
    }

    ByRate.prototype.prepare = function(bias, biasInSeconds, time) {
      this.rest += biasInSeconds * this.rate;
      this.count = Math.floor(this.rest);
      this.rest -= this.count;
      this.count += this.offset;
      return this.offset = 0;
    };

    return ByRate;

  })();

  agt.particles.counters.Fixed = (function() {

    /* Public */
    function Fixed(count) {
      this.count = count != null ? count : 1;
    }

    Fixed.prototype.prepare = function() {};

    return Fixed;

  })();

  agt.particles.counters.NullCounter = (function() {
    function NullCounter() {}


    /* Public */

    NullCounter.prototype.count = 0;

    NullCounter.prototype.prepare = function() {};

    return NullCounter;

  })();

  agt.particles.emitters.NullEmitter = (function() {
    function NullEmitter() {}


    /* Public */

    NullEmitter.prototype.get = function() {
      return new agt.geom.Point;
    };

    return NullEmitter;

  })();

  agt.particles.emitters.Path = (function() {
    Path.include(agt.particles.Randomizable);


    /* Public */

    function Path(path, random) {
      this.path = path;
      this.random = random;
      this.initRandom();
    }

    Path.prototype.get = function() {
      return this.path.pathPointAt(this.random.get());
    };

    return Path;

  })();

  agt.particles.emitters.Ponctual = (function() {

    /* Public */
    function Ponctual(point) {
      this.point = point != null ? point : new agt.geom.Point;
    }

    Ponctual.prototype.get = function() {
      return this.point.clone();
    };

    return Ponctual;

  })();

  agt.particles.emitters.Surface = (function() {
    Surface.include(agt.particles.Randomizable);


    /* Public */

    function Surface(surface, random) {
      this.surface = surface;
      this.random = random;
      this.initRandom();
    }

    Surface.prototype.get = function() {
      return this.surface.randomPointInSurface(this.random);
    };

    return Surface;

  })();

  agt.particles.initializers.Explosion = (function() {
    Explosion.include(agt.particles.Randomizable);


    /* Public */

    function Explosion(velocityMin, velocityMax, angleMin, angleMax, random) {
      this.velocityMin = velocityMin != null ? velocityMin : 0;
      this.velocityMax = velocityMax != null ? velocityMax : 1;
      this.angleMin = angleMin != null ? angleMin : 0;
      this.angleMax = angleMax != null ? angleMax : Math.PI * 2;
      this.random = random;
      this.initRandom();
    }

    Explosion.prototype.initialize = function(particle) {
      var angle, velocity;
      angle = this.random["in"](this.angleMin, this.angleMax);
      velocity = this.random["in"](this.velocityMin, this.velocityMax);
      particle.velocity.x = Math.cos(angle) * velocity;
      return particle.velocity.y = Math.sin(angle) * velocity;
    };

    return Explosion;

  })();

  agt.particles.initializers.Life = (function() {
    Life.include(agt.particles.Randomizable);


    /* Public */

    function Life(lifeMin, lifeMax, random) {
      this.lifeMin = lifeMin;
      this.lifeMax = lifeMax;
      this.random = random;
      if (this.lifeMax == null) {
        this.lifeMax = this.lifeMin;
      }
      this.initRandom();
    }

    Life.prototype.initialize = function(particle) {
      if (this.lifeMin === this.lifeMax) {
        return particle.maxLife = this.lifeMin;
      } else {
        return particle.maxLife = this.random["in"](this.lifeMin, this.lifeMax);
      }
    };

    return Life;

  })();

  agt.particles.initializers.MacroInitializer = (function() {

    /* Public */
    function MacroInitializer(initializers) {
      this.initializers = initializers;
    }

    MacroInitializer.prototype.initialize = function(particle) {
      var initializer, _i, _len, _ref12, _results;
      _ref12 = this.initializers;
      _results = [];
      for (_i = 0, _len = _ref12.length; _i < _len; _i++) {
        initializer = _ref12[_i];
        _results.push(initializer.initialize(particle));
      }
      return _results;
    };

    return MacroInitializer;

  })();

  agt.particles.initializers.NullInitializer = (function() {
    function NullInitializer() {}


    /* Public */

    NullInitializer.prototype.initialize = function() {};

    return NullInitializer;

  })();

  agt.particles.initializers.ParticleSubSystem = (function() {

    /* Public */
    function ParticleSubSystem(initializer, action, emissionFactory, subSystem) {
      this.subSystem = new agt.particles.SubSystem(initializer, action, emissionFactory, subSystem);
    }

    ParticleSubSystem.prototype.initialize = function(particle) {
      return this.subSystem.emitFor(particle);
    };

    return ParticleSubSystem;

  })();

  agt.particles.initializers.Stream = (function() {
    Stream.include(agt.particles.Randomizable);


    /* Public */

    function Stream(direction, velocityMin, velocityMax, angleRandom, random) {
      this.direction = direction != null ? direction : new agt.geom.Point(1, 1);
      this.velocityMin = velocityMin != null ? velocityMin : 0;
      this.velocityMax = velocityMax != null ? velocityMax : 1;
      this.angleRandom = angleRandom != null ? angleRandom : 0;
      this.random = random;
      this.initRandom();
    }

    Stream.prototype.initialize = function(particle) {
      var angle, velocity;
      velocity = this.random["in"](this.velocityMin, this.velocityMax);
      angle = this.direction.angle();
      if (this.angleRandom !== 0) {
        angle += this.random.pad(this.angleRandom);
      }
      particle.velocity.x = Math.cos(angle) * velocity;
      return particle.velocity.y = Math.sin(angle) * velocity;
    };

    return Stream;

  })();

  agt.particles.timers.Instant = (function() {
    function Instant() {}


    /* Public */

    Instant.prototype.prepare = function() {};

    Instant.prototype.finished = function() {
      return true;
    };

    Instant.prototype.nextTime = function() {
      return 0;
    };

    return Instant;

  })();

  agt.particles.timers.Limited = (function() {

    /* Public */
    function Limited(duration, since) {
      this.duration = duration != null ? duration : 1000;
      this.since = since != null ? since : 0;
      this.time = 0;
      this.nextTime = 0;
    }

    Limited.prototype.prepare = function(bias, biasInSeconds, time) {
      if (!this.firstTime) {
        this.nextTime = this.since + bias;
        this.firstTime = true;
      } else {
        this.nextTime = bias;
      }
      return this.time += bias;
    };

    Limited.prototype.finished = function() {
      return this.time >= this.duration;
    };

    return Limited;

  })();

  agt.particles.timers.NullTimer = (function() {
    function NullTimer() {}


    /* Public */

    NullTimer.prototype.nextTime = 0;

    NullTimer.prototype.prepare = function() {};

    NullTimer.prototype.finished = function() {
      return true;
    };

    return NullTimer;

  })();

  agt.particles.timers.Unlimited = (function(_super) {
    __extends(Unlimited, _super);


    /* Public */

    function Unlimited(since) {
      Unlimited.__super__.constructor.call(this, Infinity, since);
    }

    Unlimited.prototype.finished = function() {
      return false;
    };

    return Unlimited;

  })(agt.particles.timers.Limited);

  agt.particles.timers.UntilDeath = (function() {

    /* Public */
    function UntilDeath(particle) {
      this.particle = particle;
    }

    UntilDeath.prototype.prepare = function(bias, biasInSeconds, time) {
      return this.nextTime = bias;
    };

    UntilDeath.prototype.finished = function() {
      return this.particle.dead;
    };

    return UntilDeath;

  })();

}).call(this);
