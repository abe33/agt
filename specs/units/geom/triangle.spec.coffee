

describe 'Triangle', ->
  beforeEach ->
    addPointMatchers this
    addRectangleMatchers this

  factories = [
    triangle
    # triangle.equilateral
    # triangle.isosceles
    # triangle.rectangle
    # triangle.withPointLike
  ]
  dataFactories = [
    triangleData
    triangleData.equilateral
    triangleData.isosceles
    triangleData.rectangle
    triangleData
  ]

  factories.forEach (factory, i) ->
    data = dataFactories[i]()
    source = 'triangle'

    describe 'when instanciated with three valid points', ->
      beforeEach ->
        @triangle = factory()

      it 'creates a valid triangle instance', ->
        expect(@triangle).toBeDefined()

      ['a','b','c'].forEach (k) ->
        describe "its '#{k}' property", ->
          it "has been filled with #{data[k]}", ->
            expect(@triangle[k]).toBeSamePoint(data[k])

      [
        'ab','ac','ba', 'bc', 'ca', 'cb',
        'abCenter', 'acCenter', 'bcCenter'
      ].forEach (k) ->
        describe "its '#{k}' method", ->
          it "returns #{data[k]}", ->
            expect(@triangle[k]()).toBeSamePoint(data[k])

      ['abc', 'bac', 'acb'].forEach (k) ->
        describe "its '#{k}' method", ->
          it "returns #{data[k]}", ->
            expect(@triangle[k]()).toBeClose(data[k])

      describe 'its center method', ->
        it 'returns the triangle center', ->
          expect(@triangle.center()).toBeSamePoint(data.center)

      describe 'its translate method', ->
        beforeEach ->
          @x = 3
          @y = 4
          @result = @triangle.translate @x, @y

        it 'translates the triangle', ->
          expect(@triangle.a).toBePoint(data.a.x + @x, data.a.y + @y)
          expect(@triangle.b).toBePoint(data.b.x + @x, data.b.y + @y)
          expect(@triangle.c).toBePoint(data.c.x + @x, data.c.y + @y)

        it 'returns the triangle', ->
          expect(@result).toBe(@triangle)

      describe 'its rotateAroundCenter method', ->
        beforeEach ->
          @rotation = 10
          @result = @triangle.rotateAroundCenter @rotation

        it 'rotates the triangle around its center', ->
          a = data.a.rotateAround(data.center, @rotation)
          b = data.b.rotateAround(data.center, @rotation)
          c = data.c.rotateAround(data.center, @rotation)

          expect(@triangle.a).toBeSamePoint(a)
          expect(@triangle.b).toBeSamePoint(b)
          expect(@triangle.c).toBeSamePoint(c)

        it 'preserves the triangle center', ->
          expect(@triangle.center()).toBeSamePoint(data.center)

        it 'returns the triangle', ->
          expect(@result).toBe(@triangle)

      describe 'its scaleAroundCenter method', ->
        beforeEach ->
          @scale = 2
          @result = @triangle.scaleAroundCenter @scale

        it 'scales the triangle around its center', ->
          center = point(data.center)
          a = center.add data.a.subtract(center).scale(@scale)
          b = center.add data.b.subtract(center).scale(@scale)
          c = center.add data.c.subtract(center).scale(@scale)

          expect(@triangle.a).toBeSamePoint(a)
          expect(@triangle.b).toBeSamePoint(b)
          expect(@triangle.c).toBeSamePoint(c)

        it 'preserves the triangle center', ->
          expect(@triangle.center()).toBeSamePoint(data.center)

        it 'returns the triangle', ->
          expect(@result).toBe(@triangle)

      # Drawing API
      testDrawingOf(source)

      # Surface API
      acreageOf(source).shouldBe(data.acreage)

      # acreage memoization
      describe '::acreage memoization', ->
        it 'does not break the behavior of the function', ->
          a1 = @triangle.acreage()
          a2 = @triangle.acreage()
          expect(a2).toBe(a1)

          @triangle.a.x = 100
          a3 = @triangle.acreage()
          a4 = @triangle.acreage()
          expect(a3).not.toBe(a1)
          expect(a4).toBe(a3)


      calledWithPoints(data.center.x, data.center.y)
      .where
        source: source
        method: 'contains'
      .should 'returns true for points inside the triangle', (res) ->
        expect(res).toBeTruthy()

      calledWithPoints(100,100)
      .where
        source: source
        method: 'contains'
      .should 'returns false for points outside the triangle', (res) ->
        expect(res).toBeFalsy()

      # Path API
      lengthOf(source).shouldBe(data.length)

      describe 'its pathPointAt method', ->
        describe 'called with 0', ->
          it 'returns a', ->
            expect(@triangle.pathPointAt 0).toBeSamePoint(@triangle.a)

        describe 'called with 1', ->
          it 'returns a', ->
            expect(@triangle.pathPointAt 1).toBeSamePoint(@triangle.a)

        describe 'called with 1/3 and false', ->
          it 'returns b', ->
            expect(@triangle.pathPointAt 1 / 3, false)
              .toBeSamePoint(@triangle.b)

        describe 'called with 2/3 and false', ->
          it 'returns c', ->
            expect(@triangle.pathPointAt 2 / 3, false)
              .toBeSamePoint(@triangle.c)

      describe 'its pathOrientationAt method', ->
        describe 'called with 0', ->
          it 'returns ab angle', ->
            expect(@triangle.pathOrientationAt 0)
              .toBeClose(data.ab.angle())

        describe 'called with 1', ->
          it 'returns ca angle', ->
            expect(@triangle.pathOrientationAt 1)
              .toBeClose(data.ca.angle())

        describe 'called with 1/3 and false', ->
          it 'returns bc angle', ->
            expect(@triangle.pathOrientationAt 1 / 3, false)
              .toBeClose(data.bc.angle())

        describe 'called with 2/3 and false', ->
          it 'returns ca angle', ->
            expect(@triangle.pathOrientationAt 2 / 3, false)
              .toBeClose(data.ca.angle())

      # Geometry API
      describe 'its points method', ->
        it 'returns four points', ->
          points = @triangle.points()
          expect(points.length).toBe(4)
          expect(points[0]).toBeSamePoint(data.a)
          expect(points[1]).toBeSamePoint(data.b)
          expect(points[2]).toBeSamePoint(data.c)
          expect(points[3]).toBeSamePoint(data.a)

      geometry(source).shouldBe.closedGeometry()
      geometry(source).shouldBe.translatable()
      geometry(source).shouldBe.rotatable()
      geometry(source).shouldBe.scalable()

      ['top', 'left', 'bottom', 'right'].forEach (k) ->
        describe "its #{k} method", ->
          it "returns #{data[k]}", ->
            expect(@triangle[k]()).toBe(data[k])


      describe 'its bounds method', ->
        it 'returns the bounds of the triangle', ->
          expect(@triangle.bounds()).toEqual(data.bounds)

      describe 'its boundingBox method', ->
        it 'returns the bounds of the triangle', ->
          expect(@triangle.boundingBox())
            .toBeRectangle(data.left,
                           data.top,
                           data.right - data.left
                           data.bottom - data.top)

  describe 'when instanciated with at least an invalid point', ->
    it 'throws an error', ->
      expect(-> triangle point(4,5), point(5,7), 'notAPoint').toThrow()

  describe '::equilateral called', ->
    describe 'on a triangle which is equilateral', ->
      it 'returns true', ->
        expect(triangle.equilateral().equilateral()).toBeTruthy()

    describe 'on a triangle which is not equilateral', ->
      it 'returns false', ->
        expect(triangle().equilateral()).toBeFalsy()

  describe '::isosceles called', ->
    describe 'on a triangle which is isosceles', ->
      it 'returns true', ->
        expect(triangle.isosceles().isosceles()).toBeTruthy()

    describe 'on a triangle which is not isosceles', ->
      it 'returns false', ->
        expect(triangle().isosceles()).toBeFalsy()

  describe '::rectangle called', ->
    describe 'on a triangle which is rectangle', ->
      it 'returns true', ->
        expect(triangle.rectangle().rectangle()).toBeTruthy()

    describe 'on a triangle which is not rectangle', ->
      it 'returns false', ->
        expect(triangle().rectangle()).toBeFalsy()

  describe '::clone called', ->
    it 'returns a copy of the object', ->
      original = triangle()
      clone = original.clone()

      expect(clone.a).toBeSamePoint(original.a)
      expect(clone.b).toBeSamePoint(original.b)
      expect(clone.c).toBeSamePoint(original.c)

  describe '::equals called', ->
    beforeEach ->
      @triangle = triangle()
    describe 'with a point that is equal', ->
      it 'returns true', ->
        expect(@triangle.equals triangle()).toBeTruthy()

    describe 'with a point that is not equal', ->
      it 'returns false', ->
        expect(@triangle.equals triangle.isosceles()).toBeFalsy()
