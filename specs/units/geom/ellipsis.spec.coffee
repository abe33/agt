

describe 'Ellipsis', ->
  beforeEach ->
    addPointMatchers this
    addRectangleMatchers this
    addEllipsisMatchers this

  eachPair ellipsisFactories, (k,v) ->
    {args, test} = v
    [radius1, radius2, x, y, rotation, segments] = test
    source = 'ellipsis'
    data = ellipsisData.apply global, test

    describe "when instanciated with #{k} #{args}", ->
      beforeEach ->
        @ellipsis = ellipsis.apply global, args

      it 'exists', ->
        expect(@ellipsis).toBeDefined()

      it 'has defined the ad hoc properties', ->
        expect(@ellipsis)
          .toBeEllipsis(radius1, radius2, x, y, rotation, segments)

      describe 'its center method', ->
        it 'returns the ellipsis coordinates', ->
          expect(@ellipsis.center()).toBePoint(@ellipsis.x, @ellipsis.y)

      # Path API
      lengthOf(source).shouldBe(data.length)

      # Surface API
      acreageOf(source).shouldBe(data.acreage)

      describe 'its contains method', ->
        calledWithPoints(data.x, data.y)
        .where
          source: 'ellipsis'
          method: 'contains'
        .should 'returns true', (res) ->
          expect(res).toBeTruthy()

        calledWithPoints(-100, -100)
        .where
          source: 'ellipsis'
          method: 'contains'
        .should 'returns false', (res) ->
          expect(res).toBeFalsy()

      # Geometry API
      geometry(source).shouldBe.closedGeometry()
      geometry(source).shouldBe.translatable()
      geometry(source).shouldBe.rotatable()
      geometry(source).shouldBe.scalable()

      describe 'its top method', ->
        it 'returnss the ellipsis top', ->
          expect(@ellipsis.top()).toBeClose(data.top)

      describe 'its bottom method', ->
        it 'returnss the ellipsis bottom', ->
          expect(@ellipsis.bottom()).toBeClose(data.bottom)

      describe 'its left method', ->
        it 'returnss the ellipsis left', ->
          expect(@ellipsis.left()).toBeClose(data.left)

      describe 'its right method', ->
        it 'returnss the ellipsis right', ->
          expect(@ellipsis.right()).toBeClose(data.right)

      describe 'its bounds method', ->
        it 'returnss the ellipsis bounds', ->
          expect(@ellipsis.bounds()).toEqual(data.bounds)

      # Drawing API
      testDrawingOf(source)

      # Others
      describe 'its equals method', ->
        describe 'when called with an object equal to the current ellipsis', ->
          it 'returns true', ->
            target = ellipsis.apply global, args
            expect(@ellipsis.equals target).toBeTruthy()

        describe 'when called with an object different than the ellipsis', ->
          it 'returns false', ->
            target = ellipsis 4, 5, 1, 3
            expect(@ellipsis.equals target).toBeFalsy()

      describe 'its clone method', ->
        it 'returns a copy of this ellipsis', ->
          expect(@ellipsis.clone())
          .toBeEllipsis(
            @ellipsis.radius1,
            @ellipsis.radius2,
            @ellipsis.x,
            @ellipsis.y,
            @ellipsis.rotation,
            @ellipsis.segments)
