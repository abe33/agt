Point = agt.geom.Point

describe 'Point', ->
  beforeEach -> addPointMatchers this

  describe 'after being instanciated', ->
    describe 'with two numbers as arguments', ->
      it 'creates the new instance', ->
        expect(point 3, 8).toBePoint(3, 8)

    describe 'with two strings as arguments', ->
      it 'creates the new instance', ->
        expect(point '3', '8').toBePoint(3, 8)

    describe 'with no arguments', ->
      it 'creates the new instance with default coordinates of 0', ->
        expect(point()).toBePoint()

    describe 'with another point-like object as argument', ->
      it 'creates the new instance with the values of the object', ->
        expect(point x: 10, y: 23).toBePoint(10, 23)

    describe 'with an incomplete point-like object as argument', ->
      it 'creates the new instance with the value of the object', ->
        expect(point x: 10).toBePoint(10, 0)

  describe '::toSource called', ->
    it 'returns the source code of the point', ->
      expect(point(2,2).toSource()).toBe 'new agt.geom.Point(2,2)'

  describe '::length called', ->
    describe 'with a zero length point', ->
      it 'returns 0', ->
        expect(point().length()).toBeClose(0)

    describe 'with a point such (0,5)', ->
      it 'returns 5', ->
        expect(point(0, 5).length()).toBeClose(5)

    length = Math.sqrt 7*7 + 5*5

    describe 'with a point such (7,5)', ->
      it "returns #{length}", ->
        expect(point(7, 5).length()).toBeClose(length)

    describe 'with a point such (-7,-5)', ->
      it "returns #{length}", ->
        expect(point(-7, -5).length()).toBeClose(length)

  describe '::angle called', ->
    describe 'for a point with coordinates (10,0)', ->
      it 'returns the angle in degrees of the current vector', ->
        expect(point(10,0).angle()).toBe(0)

    describe 'for a point with coordinates (5,5)', ->
      it 'returns the angle in degrees of the current vector', ->
        expect(point(5,5).angle()).toBeClose(Math.PI / 4)

    describe 'for a point with coordinates (0,10)', ->
      it 'returns the angle in degrees of the current vector', ->
        expect(point(0,10).angle()).toBeClose(Math.PI / 2)

  describe '::equals called', ->
    describe 'with a point-like object', ->
      describe 'that is equal to the current point', ->
        it 'returns true', ->
          expect(point().equals(pointLike(0,0))).toBeTruthy()
      describe 'that is not equal to the current point', ->
        it 'returns false', ->
          expect(point().equals(pointLike(1,1))).toBeFalsy()


  pointOperator('add')
  .with(2,3).and(4,5)
  .where
    emptyArguments: 'copy'
    emptyObject: 'copy'
    partialObject: (result) -> expect(result).toBePoint(6,3)
    nullArgument: 'copy'
    singleNumber: (result) -> expect(result).toBePoint(6,3)
  .should 'returns a new point corresponding to the addition product', (result) ->
    expect(result).toBePoint(6,8)

  pointOperator('subtract')
  .with(6,8).and(4,5)
  .where
    emptyArguments: 'copy'
    emptyObject: 'copy'
    partialObject: (result) -> expect(result).toBePoint(2,8)
    nullArgument: 'copy'
    singleNumber: (result) -> expect(result).toBePoint(2,8)
  .should 'returns a new point corresponding to the subtract product', (result) ->
    expect(result).toBePoint(2,3)

  pointOperator('dot')
  .with(7,3).and(4,2)
  .where
    emptyArguments: 'throws'
    emptyObject: 'throws'
    partialObject: 'throws'
    nullArgument: 'throws'
    singleNumber: 'throws'
  .should 'returns the dot product of the current point and the point argument', (result) ->
    expect(result).toBeClose(7*4 + 3*2)

  pointOperator('distance')
  .with(7,3).and(4,2)
  .where
    emptyArguments: 'throws'
    emptyObject: 'throws'
    partialObject: 'throws'
    nullArgument: 'throws'
    singleNumber: 'throws'
  .should 'returns the distance between the two points', (result) ->
    expect(result).toBeClose(point(3,1).length())

  pointOperator('angleWith')
  .with(10,0).and(0,10)
  .where
    emptyArguments: 'throws'
    emptyObject: 'throws'
    partialObject: 'throws'
    nullArgument: 'throws'
    singleNumber: 'throws'
  .should 'returns the angle formed by the two points', (result) ->
    expect(result).toBeClose(Math.PI / 2)


  leftUnchanged = (result) ->
    expect(result).toBePoint(7, 3)
    expect(result).toBe(@point)

  pointOperator('paste')
  .with(7,3).and(4,2)
  .where
    emptyArguments: leftUnchanged
    emptyObject: leftUnchanged
    partialObject: (result) -> expect(result).toBePoint(4,3)
    nullArgument: leftUnchanged
    singleNumber: (result) -> expect(result).toBePoint(4,3)
  .should 'copy the data into this point', (result) ->
    expect(result).toBePoint(4,2)
    expect(result).toBeSamePoint(@point)

  describe '::rotate called', ->
    describe 'with a number', ->
      it 'returns a new point rotated around the origin', ->
        pt = point 10, 0
        pt2 = pt.rotate Math.PI / 2
        expect(pt2).toBePoint(0, 10)

      describe 'not containing a number', ->
        it 'throws an error', ->
          expect(-> point(10,0).rotate('foo')).toThrow()

    describe 'without argument', ->
      it 'throws an error', ->
        expect(-> point(10,0).rotate()).toThrow()

    describe 'with null', ->
      it 'throws an error', ->
        expect(-> point(10,0).rotate(null)).toThrow()

  describe '::rotateAround called', ->
    describe 'with a point and a number', ->
      it 'returns a new point rotated around the given point', ->
        pt1 = point 10, 0
        pt2 = point 20, 0
        pt3 = pt1.rotateAround pt2, Math.PI / 2
        expect(pt3).toBePoint(20, -10)

    describe 'with three numbers', ->
      it 'returns a new point rotated around the given coordinates', ->
        pt1 = point 10, 0
        pt2 = pt1.rotateAround 20, 0, Math.PI / 2
        expect(pt2).toBePoint(20, -10)

    describe 'with two numbers', ->
      it 'throws an error', ->
        expect(-> point(1,2).rotateAround(10,1)).toThrow()

    describe 'with only a point', ->
      it 'throws an error', ->
        expect(-> point(1,2).rotateAround(point())).toThrow()

  describe '::scale called', ->
    describe 'with a number', ->
      describe 'that is positive', ->
        it 'returns a new scaled point', ->
          expect(point(1,2).scale(2)).toBePoint(2,4)

      describe 'that is negative', ->
        it 'returns a new scaled point with negative coordinates', ->
          expect(point(1,2).scale(-2)).toBePoint(-2,-4)

    describe 'without arguments', ->
      it 'throws an error', ->
        expect(-> point(1,2).scale()).toThrow()

  describe '::normalize called', ->
    describe 'on a point with a length of 0', ->
      it 'returns a new point of length 0', ->
        expect(point(0,0).normalize().length()).toBeClose(0)

    describe 'without arguments', ->
      beforeEach ->
        @point1 = point(5,6)
        @point2 = @point1.normalize()

      it 'returns a new point of length 1', ->
        expect(@point2.length()).toBeClose(1)

      it 'returns a new point with the same direction', ->
        expect(@point2.x / @point2.y).toBeClose(@point1.x / @point1.y)

    describe 'with null', ->
      it 'returns a new point of length 1', ->
        expect(point(5,6).normalize(null).length()).toBeClose(1)


    describe 'with a number', ->
      describe 'that is positive', ->
        beforeEach ->
          @normalizedLength = 10.5
          @point1 = point(5,6)
          @point2 = @point1.normalize(@normalizedLength)

        it 'returns a new point with length equal to the number', ->
          expect(@point2.length()).toBeClose(@normalizedLength)

        it 'returns a new point with the same direction', ->
          expect(@point2.x / @point2.y).toBeClose(@point1.x / @point1.y)

      describe 'that is negative', ->
        beforeEach ->
          @normalizedLength = -10.5
          @point1 = point(5,6)
          @point2 = @point1.normalize(@normalizedLength)

        it 'returns a new point with length equal to the number', ->
          expect(@point2.length()).toBeClose(Math.abs @normalizedLength)

        it 'returns a new point with the same direction', ->
          expect(@point2.x / @point2.y).toBeClose(@point1.x / @point1.y)

      describe 'that is 0', ->
        it 'returns a new point with length equal to 0', ->
          expect(point(5,6).normalize(0).length()).toBeClose(0)

    describe 'with an object', ->
      it 'throws an error', ->
        expect(-> point(5,6).normalize({})).toThrow()

  describe '::clone called', ->
    it 'returns a copy of the point', ->
      expect(point(4.56, 0.1).clone()).toBePoint(4.56, 0.1)

  describe '.polar called', ->
    describe 'with an angle and a length', ->
      it 'returns a point corresponding to the cartesian projection', ->
        angle = 32
        length = 10
        pt = Point.polar angle, length
        x = length * Math.sin angle
        y = length * Math.cos angle
        expect(pt).toBePoint(x, y)

    describe 'with only an angle', ->
      it 'returns a point corresponding to the cartesian projection with a length of 1', ->
        angle = 32
        length = 1
        pt = Point.polar angle
        x = length * Math.sin angle
        y = length * Math.cos angle
        expect(pt).toBePoint(x, y)

  describe '.interpolate called', ->
    describe 'with two points and a float', ->
      it 'returns a point between the two point arguments', ->
        p1 = point(4.5, 3.0)
        p2 = point(6.2, 0.1)
        pos = 0.7
        p3 = Point.interpolate p1, p2, pos
        xdif = p2.x - p1.x
        ydif = p2.y - p1.y

        expect(p3.x).toBeClose(p1.x + xdif * pos)
        expect(p3.y).toBeClose(p1.y + ydif * pos)

    describe 'with five floats', ->
      it 'returns a point between the two coordinates defined by the first four floats', ->
        x1 = 4.5
        y1 = 3.0
        x2 = 6.2
        y2 = 0.1
        pos = 0.7
        pt = Point.interpolate(x1, y1, x2, y2, pos)
        xdif = x2 - x1
        ydif = y2 - y1

        expect(pt.x).toBeClose(x1 + xdif * pos)
        expect(pt.y).toBeClose(y1 + ydif * pos)

    describe 'with a point and three floats', ->
      describe 'with the point as first argument', ->
        it 'returns a point between the point argument and the coordinates defined by the two first floats', ->
          p1 = point(4.5, 3.0)
          x2 = 6.2
          y2 = 0.1
          pos = 0.7
          pt = Point.interpolate(p1, x2, y2, pos)
          xdif = x2 - p1.x
          ydif = y2 - p1.y

          expect(pt.x).toBeClose(p1.x + xdif * pos)
          expect(pt.y).toBeClose(p1.y + ydif * pos)


      describe 'with the point as third argument', ->
        it 'returns a point between the point argument and the coordinates defined by the two first floats', ->
          x1 = 6.2
          y1 = 0.1
          p2 = point(4.5, 3.0)
          pos = 0.7
          pt = Point.interpolate(x1, y1, p2, pos)
          xdif = p2.x - x1
          ydif = p2.y - y1

          expect(pt.x).toBeClose(x1 + xdif * pos)
          expect(pt.y).toBeClose(y1 + ydif * pos)

      describe 'with a float followed by a point', ->
        it 'throws an error', ->
          expect(-> Point.interpolate 1.1, point(), 2).toThrow()

      describe 'with a point followed by only two floats', ->
        it 'throws an error', ->
          expect(-> Point.interpolate point(), 2, 4).toThrow()

      describe 'with a point followed by only one float', ->
        it 'throws an error', ->
          expect(-> Point.interpolate point(), 2).toThrow()

      describe 'with an invalid position', ->
        it 'throws an error', ->
          expect(-> Point.interpolate point(), 2, 4, 'foo').toThrow()

      describe 'with an invalid first point', ->
        it 'throws an error', ->
          expect(-> Point.interpolate 'foo', 1, 2, 3, 0.7).toThrow()

      describe 'with an invalid second point', ->
        it 'throws an error', ->
          expect(-> Point.interpolate 0, 1, 'foo', 3, 0.7).toThrow()

      describe 'with a partial first point', ->
        it 'throws an error', ->
          expect(-> Point.interpolate {x: 10}, 2, 3, 0.7).toThrow()

      describe 'with a partial second point', ->
        it 'throws an error', ->
          expect(-> Point.interpolate 0, 1, {x: 10}, 0.7).toThrow()

      describe 'with no arguments', ->
        it 'throws an error', ->
          expect(-> Point.interpolate()).toThrow()
