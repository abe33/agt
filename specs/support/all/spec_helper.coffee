if typeof module is 'undefined'
  window.global = window
  agt = global.agt
else
  global.agt = agt = require '../../../build/agt'

global.DEFAULT_SEGMENTS = 36
global.DEG_TO_RAD = Math.PI / 180
global.BUILDS = (
  new Function( "return new arguments[0](#{
    ("arguments[1][#{j-1}]" for j in [0..i] when j isnt 0 ).join ","
  });") for i in [0..24]
)

global.first = (a) -> a[0]
global.last = (a) -> a[a.length - 1]
global.merge = (a,b) -> a[k] = v for k,v of b
global.eachPair = (o, block) -> block?(k,v) for k,v of o
global.step = (a,s,b) ->
  r = []
  l = a.length / s

  r.push a[i*s..i*s+s-1] for i in [0...l]
  r.forEach((a) -> b(a) if a.length)

global.withLoop = (times=20, block) ->
  [ times, block ] = [ 20, times ] if typeof times is 'function'
  block.call this, n for n in [ 0..times ]

agt.Impulse::start = -> @running = true

time = 0
global.animate = (t) -> agt.Impulse.instance().dispatch(t, t / 1000, time += t)

global.testProperty = (source, property) ->
  shouldBe: (value) ->
    describe "#{source} #{property} property", ->
      beforeEach ->
        jasmine.addMatchers
          toBeClose: ->
            compare: (actual,value) ->
              result = {}
              result.message = "Expected #{actual} to be equal to #{value} with a precision of 1e-10"

              result.pass = Math.deltaBelowRatio(actual, value)
              result

      it "should be #{value}", ->
        expect(this[source][property]).toBeClose(value)
