

describe 'Circle', ->
  beforeEach ->
    addPointMatchers this
    addRectangleMatchers this
    addCircleMatchers this

  eachPair circleFactories, (k,v) ->
    {args, test} = v
    [radius, x, y, rotation, segments] = test
    source = 'circle'
    data = circleData.apply global, test

    describe "when instanciated with #{k} #{args}", ->
      beforeEach -> @circle = circle(args...)

      it 'exists', ->
        expect(@circle).toBeDefined()

      it 'has defined the ad hoc properties', ->
        expect(@circle).toBeCircle(radius, x, y, rotation, segments)

      describe 'its center method', ->
        it 'returns the circle coordinates', ->
          expect(@circle.center()).toBePoint(@circle.x, @circle.y)
      # Path API
      lengthOf(source).shouldBe(data.length)

      describe 'its pathPointAt method', ->
        describe 'called with 0', ->
          it "returns #{data.right},#{data.y}", ->
            expect(@circle.pathPointAt 0).toBePoint(data.right, data.y)

        describe 'called with 1', ->
          it "returns #{data.right},#{data.y}", ->
            expect(@circle.pathPointAt 1).toBePoint(data.right, data.y)

        describe 'called with 0.25', ->
          it "returns #{data.x},#{data.bottom}", ->
            expect(@circle.pathPointAt 0.25).toBePoint(data.x, data.bottom)

        describe 'called with 0.5', ->
          it "returns #{data.left},#{data.y}", ->
            expect(@circle.pathPointAt 0.5).toBePoint(data.left, data.y)

        describe 'called with 0.75', ->
          it "returns #{data.x},#{data.top}", ->
            expect(@circle.pathPointAt 0.75).toBePoint(data.x, data.top)

      describe 'its pathOrientationAt method', ->
        describe 'called with 0', ->
          it 'returns Math.PI / 2', ->
            expect(@circle.pathOrientationAt 0).toBeClose(Math.PI / 2)

        describe 'called with 1', ->
          it 'returns Math.PI / 2', ->
            expect(@circle.pathOrientationAt 1).toBeClose(Math.PI / 2)

        describe 'called with 0.25', ->
          it 'returns Math.PI', ->
            expect(@circle.pathOrientationAt 0.25).toBeClose(Math.PI)

        describe 'called with 0.5', ->
          it 'returns -Math.PI / 2', ->
            expect(@circle.pathOrientationAt 0.5).toBeClose(-Math.PI / 2)

        describe 'called with 0.75', ->
          it 'returns 0', ->
            expect(@circle.pathOrientationAt 0.75).toBe(0)

      # Surface API
      acreageOf(source).shouldBe(data.acreage)

      describe 'its contains method', ->
        calledWithPoints(data.x, data.y)
        .where
          source: source
          method: 'contains'
        .should 'returns true', (res) ->
          expect(res).toBeTruthy()

        calledWithPoints(-100, -100)
        .where
          source: source
          method: 'contains'
        .should 'returns false', (res) ->
          expect(res).toBeFalsy()

      # Geometry API
      describe 'its top method', ->
        it 'returnss the circle top', ->
          expect(@circle.top()).toEqual(data.top)

      describe 'its bottom method', ->
        it 'returnss the circle bottom', ->
          expect(@circle.bottom()).toEqual(data.bottom)

      describe 'its left method', ->
        it 'returnss the circle left', ->
          expect(@circle.left()).toEqual(data.left)

      describe 'its right method', ->
        it 'returnss the circle right', ->
          expect(@circle.right()).toEqual(data.right)

      describe 'its bounds method', ->
        it 'returnss the circle bounds', ->
          expect(@circle.bounds()).toEqual(data.bounds)

      geometry(source).shouldBe.closedGeometry()
      geometry(source).shouldBe.translatable()
      geometry(source).shouldBe.scalable()

      # Drawing API
      testDrawingOf(source)

      # Others
      describe 'its equals method', ->
        describe 'when called with an object equal to the current circle', ->
          it 'returns true', ->
            target = circle.apply global, args
            expect(@circle.equals target).toBeTruthy()

        describe 'when called with an object different than the circle', ->
          it 'returns false', ->
            target = circle 5, 1, 3
            expect(@circle.equals target).toBeFalsy()

      describe 'its clone method', ->
        it 'returns a copy of this circle', ->
          expect(@circle.clone())
          .toBeCircle(
            @circle.radius,
            @circle.x,
            @circle.y,
            @circle.rotation,
            @circle.segments)
