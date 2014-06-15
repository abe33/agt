
describe 'Spiral', ->
  eachPair spiralFactories, (k,v) ->
    {args, test} = v
    [radius1, radius2, twirl, x, y, rotation, segments] = test
    data = spiralData radius1, radius2, twirl, x, y, rotation, segments
    source = 'spiral'

    describe "when instanciated #{k}", ->
      beforeEach ->
        addSpiralMatchers this
        addPointMatchers this
        @spiral = spiral.apply global, args

      it 'exists', ->
        expect(@spiral).toBeDefined()

      describe 'its toSource method', ->
        it 'returns the source code of the spiral', ->
          expect(@spiral.toSource()).toBe(data.source)

      it 'has been filled with the passed-in arguments', ->
        expect(@spiral)
        .toBeSpiral(radius1, radius2, twirl, x, y, rotation, segments)

      describe 'its points method', ->
        it 'returns a array', ->
          points = @spiral.points()
          expect(points.length).toBe(segments + 1)

      # Others
      describe 'its equals method', ->
        describe 'when called with an object equal to the current spiral', ->
          it 'returns true', ->
            target = spiral.apply global, args
            expect(@spiral.equals target).toBeTruthy()

        describe 'when called with an object different than the spiral', ->
          it 'returns false', ->
            target = spiral 4, 5, 1, 3
            expect(@spiral.equals target).toBeFalsy()

      describe 'its clone method', ->
        it 'returns a copy of this spiral', ->
          expect(@spiral.clone())
          .toBeSpiral(
            @spiral.radius1,
            @spiral.radius2,
            @spiral.twirl,
            @spiral.x,
            @spiral.y,
            @spiral.rotation,
            @spiral.segments)

      # Geometry API
      geometry(source).shouldBe.openGeometry()
      geometry(source).shouldBe.translatable()
      geometry(source).shouldBe.rotatable()
      geometry(source).shouldBe.scalable()
