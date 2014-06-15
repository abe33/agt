
global.addSpiralMatchers = (scope) ->
  jasmine.addMatchers
    toBeSpiral: ->
      compare: (actual,r1, r2, twirl, x, y, rotation, segments) ->
        result = {}
        result.message = ->
          "Expected #{actual} to be an spiral with radius1=#{r1}, radius2=#{r2}, twirl=#{twirl}, x=#{x}, y=#{y}, rotation=#{rotation}, segments=#{segments}"

        result.pass = actual.radius1 is r1 and
        actual.radius2 is r2 and
        actual.twirl is twirl and
        actual.x is x and
        actual.y is y and
        actual.rotation is rotation and
        actual.segments is segments

        result

global.spiral = (r1, r2, twirl, x, y, rotation, segments) ->
  new agt.geom.Spiral r1, r2, twirl, x, y, rotation, segments


global.spiralData= (radius1, radius2, twirl, x, y, rotation, segments) ->
  data = {radius1, radius2, twirl, x, y, rotation, segments}

  source = "new agt.geom.Spiral(#{(v for k,v of data).join ','})"

  merge data, {
    source: source
    acreage: Math.PI * radius1 * radius2
    length: Math.PI * (3*(radius1 + radius2) -
            Math.sqrt((3* radius1 + radius2) * (radius1 + radius2 *3)))
  }
  a = radius1
  b = radius2
  phi = rotation
  t1 = Math.atan(-b * Math.tan(phi) / a)
  t2 = Math.atan(b * (Math.cos(phi) / Math.sin(phi)) / a)
  x1 = x + a*Math.cos(t1+Math.PI)*Math.cos(phi) -
           b*Math.sin(t1+Math.PI)*Math.sin(phi)
  x2 = x + a*Math.cos(t1)*Math.cos(phi) -
           b*Math.sin(t1)*Math.sin(phi)
  y1 = y + a*Math.cos(t2)*Math.sin(phi) +
           b*Math.sin(t2)*Math.cos(phi)
  y2 = y + a*Math.cos(t2+Math.PI)*Math.sin(phi) +
           b*Math.sin(t2+Math.PI)*Math.cos(phi)
  merge data, {
    left: Math.min x1, x2
    right: Math.max x1, x2
    top: Math.min y1, y2
    bottom: Math.max y1, y2
  }
  merge data, {
    bounds:
      top: data.top
      bottom: data.bottom
      left: data.left
      right: data.right
  }
  data

global.spiralFactories =
  'with five numbers':
    args: [1,2,3,4,5]
    test: [1,2,3,4,5,0,DEFAULT_SEGMENTS]
  'with six numbers':
    args: [1,2,3,4,5,6]
    test: [1,2,3,4,5,6,DEFAULT_SEGMENTS]
  'with seven numbers':
    args: [1,2,3,4,5,6,60]
    test: [1,2,3,4,5,6,60]
  'without arguments':
    args: []
    test: [1,1,1,0,0,0,DEFAULT_SEGMENTS]
  'with a spiral without rotation, twirl or segments':
    args: [{radius1: 1, radius2: 2, x: 3, y: 4}]
    test: [1,2,1,3,4,0,DEFAULT_SEGMENTS]
  'with a spiral without segments':
    args: [{radius1: 1, radius2: 2, twirl:3, x: 4, y: 5, rotation: 120}]
    test: [1,2,3,4,5,120,DEFAULT_SEGMENTS]
  'with a spiral':
    args: [{
      radius1: 1,
      radius2: 2,
      twirl: 3,
      x: 4, y: 5,
      rotation: 6,
      segments: 60
    }]
    test: [1,2,3,4,5,6,60]
