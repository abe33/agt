
global.matrix = (a, b, c, d, tx, ty) -> new agt.geom.Matrix a, b, c, d, tx, ty

matrix.identity = -> new agt.geom.Matrix
matrix.transformed = -> new agt.geom.Matrix 1, 2, 3, 4, 5, 6
matrix.inverted = -> new agt.geom.Matrix -2, 1, 1.5, -0.5, 1, -2
matrix.translated = -> new agt.geom.Matrix 1, 2, 3, 4, 3, 8
matrix.scaled = -> new agt.geom.Matrix 0.5, 2, 3, 8, 2.5, 12
matrix.rotated = ->
  [a,b,c,d,tx,ty] = [1,2,3,4,5,6]
  angle = 72
  cos = Math.cos angle
  sin = Math.sin angle
  new agt.geom.Matrix(
    a*cos - b*sin,
    a*sin + b*cos,
    c*cos - d*sin,
    c*sin + d*cos,
    tx*cos - ty*sin,
    tx*sin + ty*cos,
  )

matrix.appended = ->
  new agt.geom.Matrix(
    6*1 + 5*3,
    6*2 + 5*4,
    4*1 + 3*3,
    4*2 + 3*4,
    2*1 + 1*3 + 5,
    2*2 + 1*4 + 6,
  )

matrix.prepended = ->
  new agt.geom.Matrix(
    1*6 + 2*4
    1*5 + 2*3
    3*6 + 4*4
    3*5 + 4*3
    5*6 + 6*4 + 2
    5*5 + 6*3 + 1
  )

matrix.skewed = ->
  [a,b,c,d] = [
    Math.cos 2
    Math.sin 2
    -Math.sin -2
    Math.cos -2
  ]
  new agt.geom.Matrix(
    a*1 + b*3,
    a*2 + b*4,
    c*1 + d*3,
    c*2 + d*4,
    5,
    6,
  )

global.addMatrixMatchers = (scope) ->
  jasmine.addMatchers
    toBeSameMatrix: ->
      compare: (actual,m) ->
        result = {}
        result.message = "Expected #{actual} to be a matrix equal to #{m}"

        result.pass = actual.a is m.a and
        actual.b is m.b and
        actual.c is m.c and
        actual.d is m.d and
        actual.tx is m.tx and
        actual.ty is m.ty

        result

    toBeIdentity: ->
      compare: (actual) ->
        result = {}
        result.message = "Expected #{@actual} to be an identity matrix"

        result.pass = actual.a is 1 and
        actual.b is 0 and
        actual.c is 0 and
        actual.d is 1 and
        actual.tx is 0 and
        actual.ty is 0

        result
