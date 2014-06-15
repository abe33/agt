
Rectangle = agt.geom

describe 'Rectangle', ->
  beforeEach ->
    addRectangleMatchers this
    addPointMatchers this

  tests =
    'with four numbers':
      args: [1,2,3,4]
      acreage: 12
      length: 14
      test: [1,2,3,4,0]
    'with five numbers':
      args: [4,5,6,7,8]
      acreage: 42
      length: 26
      test: [4,5,6,7,8]
    'without arguments':
      args: []
      acreage: 0
      length: 0
      test: [0,0,0,0,0]
    'with another rectangle':
      args: [rectangle(1,2,3,4,5)]
      acreage: 12
      length: 14
      test: [1,2,3,4,5]
    'with a partial rectangle like object':
      args: [x:1,width:3,height:4]
      acreage: 12
      length: 14
      test: [1,0,3,4,0]

  describe 'when instanciated', ->
    eachPair tests, (msg, o) ->
      {args, acreage, test, length} = o
      [x,y,width,height,rotation] = test

      describe "#{msg} #{args}", ->
        beforeEach ->
          @rectangle = rectangle(args...)
          @data = rectangleData(test...)

        source = 'rectangle'

        it 'has been set with the provided values', ->
          expect(@rectangle).toBeRectangle(x, y, width, height, rotation)

        describe 'its toSource method', ->
          it 'returns the code source of the Rectangle', ->
            expect(@rectangle.toSource()).toBe(@data.source)

        # Rectangle API
        testRotatedRectangle source, x, y, width, height, rotation

        proxyable(source)
        .shouldDefine
          corners: 'PointList'
          topLeft: 'Point'
          topRight: 'Point'
          bottomLeft: 'Point'
          bottomRight: 'Point'

          center: 'Point'
          topEdgeCenter: 'Point'
          bottomEdgeCenter: 'Point'
          leftEdgeCenter: 'Point'
          rightEdgeCenter: 'Point'

          edges: 'PointList'
          topEdge: 'Point'
          leftEdge: 'Point'
          bottomEdge: 'Point'
          rightEdge: 'Point'

          diagonal: 'Point'

          points: 'PointList'

          pathPointAt: 'Point'
          pathOrientationAt: 'Angle'
        .asProxyable()

        describe 'its setCenter method', ->
          calledWithPoints(1,3,-5,2,5,-8,0,0)
          .where
            source: source
            method: 'setCenter'
          .should 'has moved the rectangle and returned it', (res, tx,ty) ->
            {x,y} = @data.topLeft
            {x:cx,y:cy} = @data.center
            [x,y] = [
              x + (tx - cx)
              y + (ty - cy)
            ]
            expect(@rectangle.topLeft()).toBePoint(x,y)
            expect(res).toBe(@rectangle)

        describe 'its rotateAroundCenter method', ->
          beforeEach ->
            @rotation = 10
            @result = @rectangle.rotateAroundCenter @rotation

          it 'rotates the rectangle around its center', ->
            target = point(@data.topLeft).rotateAround(@data.center, @rotation)
            expect(@rectangle.topLeft()).toBeSamePoint(target)

          it 'should preserve the rectangle center', ->
            expect(@rectangle.center()).toBeSamePoint(@data.center)

          it 'returns the rectangle', ->
            expect(@result).toBe(@rectangle)

        describe 'its scaleAroundCenter method', ->
          beforeEach ->
            @scale = 2
            @result = @rectangle.scaleAroundCenter @scale

          it 'scales the rectangle around its center', ->
            dif = point(@data.topLeft).subtract(@data.center)
            dif = dif.scale(@scale)
            target = point(@data.topLeft).add(dif.scale(0.5))
            expect(@rectangle.topLeft()).toBeSamePoint(target)
            expect(@rectangle.width).toBe(width * @scale)
            expect(@rectangle.height).toBe(height * @scale)

          it 'should preserve the rectangle center', ->
            expect(@rectangle.center()).toBeSamePoint(@data.center)

          it 'returns the rectangle', ->
            expect(@result).toBe(@rectangle)

        describe 'its inflateAroundCenter method', ->
          calledWithPoints(1,3,-5,2,5,-8,0,0)
          .where
            source: source
            method: 'inflateAroundCenter'
          .should 'has inflate the rectangle and returned it', (res,x,y)->
            expect(@rectangle.width).toBe(width + x)
            expect(@rectangle.height).toBe(height + y)
            expect(@rectangle.center()).toBeSamePoint(@data.center)
            expect(res).toBe(@rectangle)

        describe 'its inflate method', ->
          calledWithPoints(1,3,-5,2,5,-8,0,0)
          .where
            source: source
            method: 'inflate'
          .should 'has inflate the rectangle and returned it', (res,x,y) ->
            expect(@rectangle.width).toBe(width + x)
            expect(@rectangle.height).toBe(height + y)
            expect(@rectangle.topLeft()).toBeSamePoint(@data.topLeft)
            expect(res).toBe(@rectangle)

        describe 'its inflateTopLeft method', ->
          calledWithPoints(1,3,-5,2,5,-8,0,0)
          .where
            source: source
            method: 'inflateTopLeft'
          .should 'has inflate the rectangle and returned it', (res,x,y) ->
            topEdge = point(@rectangle.topEdge()).normalize(-x)
            leftEdge = point(@rectangle.leftEdge()).normalize(-y)

            expect(@rectangle.width).toBe(width + x)
            expect(@rectangle.height).toBe(height + y)
            expect(@rectangle.topLeft())
              .toBeSamePoint(point(@data.topLeft).add(topEdge).add(leftEdge))
            expect(res).toBe(@rectangle)

        describe 'its inflateTopRight method', ->
          calledWithPoints(1,3,-5,2,5,-8,0,0)
          .where
            source: source
            method: 'inflateTopRight'
          .should 'has inflate the rectangle and returned it', (res,x,y) ->
            leftEdge = point(@rectangle.leftEdge()).normalize(-y)

            expect(@rectangle.width).toBe(width + x)
            expect(@rectangle.height).toBe(height + y)
            expect(@rectangle.topLeft())
              .toBeSamePoint(point(@data.topLeft).add(leftEdge))
            expect(res).toBe(@rectangle)

        describe 'its inflateBottomLeft method', ->
          calledWithPoints(1,3,-5,2,5,-8,0,0)
          .where
            source: source
            method: 'inflateBottomLeft'
          .should 'has inflate the rectangle and returned it', (res,x,y) ->
            topEdge = point(@rectangle.topEdge()).normalize(-x)

            expect(@rectangle.width).toBe(width + x)
            expect(@rectangle.height).toBe(height + y)
            expect(@rectangle.topLeft())
              .toBeSamePoint(point(@data.topLeft).add(topEdge))
            expect(res).toBe(@rectangle)

        describe 'its inflateBottomRight method', ->
          calledWithPoints(1,3,-5,2,5,-8,0,0)
          .where
            source: source
            method: 'inflateBottomRight'
          .should 'has inflate the rectangle and returned it', (res,x,y) ->
            expect(@rectangle.width).toBe(width + x)
            expect(@rectangle.height).toBe(height + y)
            expect(@rectangle.topLeft()).toBeSamePoint(@data.topLeft)
            expect(res).toBe(@rectangle)

        describe 'its inflateLeft method called', ->
          beforeEach ->
            @inflate = 2
            @result = @rectangle.inflateLeft @inflate

          it 'should inflate the rectangle to the left', ->
            expect(@rectangle.width).toBe(width + @inflate)
            expect(@rectangle.height).toBe(height)
            topEdge = point(@rectangle.topEdge()).normalize(-@inflate)
            expect(@rectangle.topLeft())
              .toBeSamePoint(point(@data.topLeft).add(topEdge))

          it 'returns the rectangle', ->
            expect(@result).toBe(@rectangle)

        describe 'its inflateRight method called', ->
          beforeEach ->
            @inflate = 2
            @result = @rectangle.inflateRight @inflate

          it 'should inflate the rectangle to the right', ->
            expect(@rectangle.width).toBe(width + @inflate)
            expect(@rectangle.height).toBe(height)
            expect(@rectangle.topLeft()).toBeSamePoint(@data.topLeft)

          it 'returns the rectangle', ->
            expect(@result).toBe(@rectangle)

        describe 'its inflateTop method called', ->
          beforeEach ->
            @inflate = 2
            @result = @rectangle.inflateTop @inflate

          it 'should inflate the rectangle to the top', ->
            expect(@rectangle.width).toBe(width)
            expect(@rectangle.height).toBe(height + @inflate)
            leftEdge = point(@rectangle.leftEdge()).normalize(-@inflate)
            expect(@rectangle.topLeft())
              .toBeSamePoint(point(@data.topLeft).add(leftEdge))

          it 'returns the rectangle', ->
            expect(@result).toBe(@rectangle)

        describe 'its inflateBottom method called', ->
          beforeEach ->
            @inflate = 2
            @result = @rectangle.inflateBottom @inflate

          it 'should inflate the rectangle to the bottom', ->
            expect(@rectangle.width).toBe(width)
            expect(@rectangle.height).toBe(height + @inflate)
            expect(@rectangle.topLeft()).toBeSamePoint(@data.topLeft)

          it 'returns the rectangle', ->
            expect(@result).toBe(@rectangle)

        # Surface API
        acreageOf(source).shouldBe(acreage)

        describe 'its contains method', ->
          data = rectangleData.apply global, test
          a = []
          [0..4].forEach (n) ->
            a.push data.topLeft.x + (n / 5) * data.topEdge.x +
                                    (n / 5) * data.leftEdge.x
            a.push data.topLeft.y + (n / 5) * data.topEdge.y +
                                    (n / 5) * data.leftEdge.y

          calledWithPoints.apply(global, a)
          .where
            source: source
            method: 'contains'
          .should 'returns true for points inside the rectangle', (res) ->
            expect(res).toBeTruthy()

          calledWithPoints(-10,-10)
          .where
            source: source
            method: 'contains'
          .should 'returns false for points outside the rectangle', (res) ->
            expect(res).toBeFalsy()

        # Path API
        lengthOf(source).shouldBe(length)

        # Geometry API
        geometry(source).shouldBe.closedGeometry()
        geometry(source).shouldBe.translatable()
        geometry(source).shouldBe.rotatable()
        geometry(source).shouldBe.scalable()

        describe 'its bounds method', ->
          it 'returns the bounds of the rectangle', ->
            expect(@rectangle.bounds())
            .toEqual
              top: @rectangle.top()
              left: @rectangle.left()
              bottom: @rectangle.bottom()
              right: @rectangle.right()

        describe 'its boundingBox method', ->
          it 'returns a rectangle representing its bounds', ->
            expect(@rectangle.boundingBox())
            .toBeRectangle(
              @rectangle.left(),
              @rectangle.top(),
              @rectangle.right() - @rectangle.left(),
              @rectangle.bottom() - @rectangle.top()
            )

        # Drawing API
        testDrawingOf(source)

    eachPair tests, (msg, o) ->
      {args, test} = o
      [x,y,width,height,rotation] = test

      describe "::paste called with #{msg} #{args}", ->
        it 'should copy the passed-in data in the rectangle', ->
          rect = rectangle()
          rect.paste.apply rect, args
          expect(rect).toBeRectangle(x,y,width,height,rotation)

      describe "::equals called", ->
        it 'returns true when rectangles are equals', ->
          rect1 = rectangle.apply global, args
          rect2 = rectangle.apply global, args
          expect(rect1.equals rect2).toBeTruthy()

        it 'returns false when rectangles are different', ->
          rect1 = rectangle.apply global, args
          rect2 = rectangle -1, -1, 10, 10, 100
          expect(rect1.equals rect2).toBeFalsy()

        it 'returns false when passed null', ->
          rect = rectangle.apply global, args
          expect(rect.equals null).toBeFalsy()

      describe '::points called', ->
        it 'returnss an array with the corners of the rectangle', ->
          rect = rectangle.apply global, args
          data = rectangleData.apply global, test

          points = rect.points()
          testPoints = [
            data.topLeft
            data.topRight
            data.bottomRight
            data.bottomLeft
            data.topLeft
          ]

          expect(points.length).toBe(5)
          points.forEach (pt, i) -> expect(pt).toBeSamePoint(testPoints[i])

  describe '::clone called', ->
    it 'should the copy of the rectangle', ->
      expect(rectangle(4,5,6,7,8).clone()).toBeRectangle(4,5,6,7,8)

  describe 'path API', ->
    beforeEach ->
      @rectangle = rectangle 0, 0, 20, 10
      @data = rectangleData 0, 0, 20, 10

    describe '::pathPointAt method called', ->
      describe 'with 0', ->
        it 'returns the top left corner', ->
          expect(@rectangle.pathPointAt 0).toBeSamePoint(@data.topLeft)

      describe 'with 1', ->
        it 'returns the top left corner', ->
          expect(@rectangle.pathPointAt 1).toBeSamePoint(@data.topLeft)

      describe 'with 0.5', ->
        it 'returns the bottom right corner', ->
          expect(@rectangle.pathPointAt 0.5).toBeSamePoint(@data.bottomRight)

      describe 'with 0 and false', ->
        it 'returns the top left corner', ->
          expect(@rectangle.pathPointAt 0, false)
            .toBeSamePoint(@data.topLeft)

      describe 'with 1 and false', ->
        it 'returns the top left corner', ->
          expect(@rectangle.pathPointAt 1, false)
            .toBeSamePoint(@data.topLeft)

      describe 'with 0.5 and false', ->
        it 'returns the bottom right corner', ->
          expect(@rectangle.pathPointAt 0.5, false)
            .toBeSamePoint(@data.bottomRight)

    describe '::pathOrientationAt method called', ->
      describe 'with 0', ->
        it 'returns 0', ->
          expect(@rectangle.pathOrientationAt 0).toBeClose(0)

      describe 'with 1', ->
        it 'returns -Math.PI/2', ->
          expect(@rectangle.pathOrientationAt 1)
            .toBeClose(-Math.PI / 2)

      describe 'with 0.5', ->
        it 'returns Math.PI', ->
          expect(@rectangle.pathOrientationAt 0.5)
            .toBeClose(-Math.PI)

      describe 'with 0 and false', ->
        it 'returns 0', ->
          expect(@rectangle.pathOrientationAt 0, false).toBeClose(0)

      describe 'with 1 and false', ->
        it 'returns -Math.PI/2', ->
          expect(@rectangle.pathOrientationAt 1, false)
            .toBeClose(-Math.PI / 2)

      describe 'with 0.5 and false', ->
        it 'returns Math.PI', ->
          expect(@rectangle.pathOrientationAt 0.5, false)
            .toBeClose(-Math.PI)

    describe '::containsGeometry called', ->
      describe 'with a geometry inside the rectangle', ->
        it 'returns true', ->
          rect1 = rectangle 0, 0, 10, 10
          rect2 = rectangle 2, 2, 2, 2

          expect(rect1.containsGeometry rect2).toBeTruthy()

      describe 'with a geometry overlapping the rectangle', ->
        it 'returns false', ->
          rect1 = rectangle 0, 0, 10, 10
          rect2 = rectangle -2, -2, 4, 4

          expect(rect1.containsGeometry rect2).toBeFalsy()

      describe 'with a geometry outside the rectangle', ->
        it 'returns false', ->
          rect1 = rectangle 0, 0, 10, 10
          rect2 = rectangle -2, -2, 1, 1

          expect(rect1.containsGeometry rect2).toBeFalsy()

    describe '::intersects called', ->
      describe 'with a geometry that intersects the rectagle', ->
        it 'returns true', ->
          rect1 = rectangle 0, 0, 10, 10
          rect2 = rectangle -2, -2, 4, 4

          expect(rect1.intersects rect2).toBeTruthy()

      describe 'with a geometry that does not intersects the rectagle', ->
        it 'returns false', ->
          rect1 = rectangle 0, 0, 10, 10
          rect2 = rectangle -2, -2, 1, 1

          expect(rect1.intersects rect2).toBeFalsy()

    describe '::intersections called', ->
      describe 'with a geometry that intersects the rectagle', ->
        it 'returns an array with the 2 intersections', ->
          rect1 = rectangle 0, 0, 10, 10
          rect2 = rectangle -2, -2, 4, 4
          res = rect1.intersections rect2

          expect(res.length).toBe(2)
          expect(res[0]).toBePoint(2,0)
          expect(res[1]).toBePoint(0,2)

      describe 'with a geometry that does not intersects the rectagle', ->
        it 'returns null', ->
          rect1 = rectangle 0, 0, 10, 10
          rect2 = rectangle -2, -2, 1, 1
          res = rect1.intersections rect2

          expect(res).toBeNull()
