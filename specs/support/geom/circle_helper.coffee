
global.addCircleMatchers = (scope) ->
  jasmine.addMatchers
    toBeCircle: ->
      compare: (actual, radius, x, y, segments) ->
        result = {}
        result.message = "Expected #{actual} to be a circle with radius=#{radius}, x=#{x}, y=#{y}, segments=#{segments}"

        result.pass = actual.radius is radius and
        actual.x is x and
        actual.y is y and
        actual.segments is segments

        result

global.circle = (radius, x, y, segments) ->
  new agt.geom.Circle radius, x, y, segments

global.circleData = (radius, x, y, segments) ->
  data = {radius, x, y, segments}

  merge data, {
    acreage: Math.PI * radius * radius
    length: 2 * Math.PI * radius
    top: y - radius
    bottom: y + radius
    left: x - radius
    right: x + radius
  }

  merge data, {
    bounds:
      top: data.top
      bottom: data.bottom
      left: data.left
      right: data.right
  }

  data

global.circleFactories =
  'three numbers':
    args: [1,1,1]
    test: [1,1,1,DEFAULT_SEGMENTS]
  'with four numbers':
    args: [2,3,4,60]
    test: [2,3,4,60]
  'without arguments':
    args: []
    test: [1,0,0,DEFAULT_SEGMENTS]
  'with a circle without segments':
    args: [{x: 1, y: 1, radius: 1}]
    test: [1,1,1,DEFAULT_SEGMENTS]
  'with a circle with segments':
    args: [{x: 1, y: 1, radius: 1, segments: 60}]
    test: [1,1,1,60]
  'with partial circle':
    args: [{x:1}]
    test: [1,1,0,36]
