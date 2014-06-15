
equalEnough = Math.deltaBelowRatio

global.addPointMatchers = (scope) ->
  jasmine.addMatchers
    toBeClose: ->
      compare: (actual, value) ->
        result = {}
        result.message = "Expected #{actual} to be equal to #{value} with a precision of 1e-10"
        result.pass = equalEnough(actual, value)

        result

    toBePoint: ->
      compare: (actual, x=0, y=0) ->
        result = {}
        result.message = "Expected #{actual} to be a point with x=#{x} and y=#{y}"

        result.pass = equalEnough(actual.x, x) and equalEnough(actual.y, y)

        result

    toBeSamePoint: ->
      compare: (actual, pt) ->
        result = {}
        result.message = "Expected #{actual} to be a point equivalent to (#{pt.x},#{pt.y})"

        result.pass = equalEnough(actual.x, pt.x) and equalEnough(actual.y, pt.y)
        result

global.point = (x,y) -> new agt.geom.Point x, y
global.pointLike = (x,y) -> {x,y}

global.pointOperator = (operator) ->

  operatorActions =
    copy: (expectation) ->
      it "returns a copy of the point", ->
        expect(expectation.call this).toBeSamePoint(@point)
    throws: (expectation) ->
      it 'throws an error', ->
        expect(=> expectation.call this).toThrow()
    null: (expectation) ->
      it 'returns null', ->
        expect(expectation.call this).toBeNull()
    nan: (expectation) ->
      it 'returns nan', ->
        expect(expectation.call this).toBe(NaN)

  operatorOption = (value, actions={}, expectation=null) ->
    switch typeof value
      when 'function'
        it '', ->
          value.call this, expectation?.call this
      when 'string'
        actions[value]? expectation

  with: (@x1, @y1) -> this
  and: (@x2, @y2) -> this
  where: (@options) -> this
  should: (message, block) ->
    {x1, x2, y1, y2, options} = this
    describe "::#{operator} called", ->
      beforeEach ->
        @point = new agt.geom.Point x1, y1

      describe 'with another point', ->
        it message, ->
          block.call this, @point[operator] point x2, y2

      describe 'with a point-like object', ->
        it message, ->
          block.call this, @point[operator] pointLike x2, y2

      if options.emptyArguments?
        describe 'with no argument', ->
          operatorOption options.emptyArguments,
                         operatorActions,
                         -> @point[operator]()

      if options.emptyObject?
        describe 'with an empty object', ->
          operatorOption options.emptyObject,
                         operatorActions,
                         -> @point[operator] {}

      if options.partialObject?
        describe 'with a partial object', ->
          operatorOption options.partialObject,
                         operatorActions,
                         -> @point[operator] x: x2

      if options.singleNumber?
        describe 'with only one number', ->
          operatorOption options.singleNumber,
                         operatorActions,
                         -> @point[operator] x2

      if options.nullArgument?
        describe 'with null', ->
          operatorOption options.nullArgument,
                         operatorActions,
                         -> @point[operator] null

global.calledWithPoints = (coordinates...) ->
  throw new Error "coordinates must be even" if coordinates.length % 2 is 1

  where: (@options) -> this
  should: (message, block) ->
    step coordinates, 2, ([x, y]) =>
      {options} = this

      describe "called with point (#{x},#{y})", ->
        it message, ->
          block.call this, @[options.source][options.method](point x, y), x, y

      describe 'called with a point-like object', ->
        it message, ->
          block.call this,
                     @[options.source][options.method](pointLike x, y),
                     x, y


global.pointOf = (source, method, args...) ->
  shouldBe: (x, y) ->
    {x,y} = x if typeof x is 'object'

    beforeEach -> addPointMatchers this

    describe "the #{source} #{method} method", ->
      it "returns a point equal to (#{x},#{y})", ->
        source = @[source]
        expect(source[method].apply source, args).toBePoint(x, y)
