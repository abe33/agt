

describe 'Diamond', ->
  beforeEach -> addDiamondMatchers this

  eachPair diamondFactories, (k,v) ->
    {args, test} = v
    [topLength, rightLength, bottomLength, leftLength, x, y, rotation] = test
    data = diamondData.apply global, test
    source = 'diamond'

    describe "when instanciated #{k} #{args}", ->
      beforeEach ->
        @diamond = diamond.apply global, args

      it 'has set the ad hoc properties', ->
        expect(@diamond).toBeDiamond(topLength,
                                     rightLength,
                                     bottomLength,
                                     leftLength,
                                     x,
                                     y,
                                     rotation)

      describe 'its clone method', ->
        it 'returns a copy of the diamond', ->
          expect(@diamond.clone()).toEqual(@diamond)

      describe 'its equals method', ->
        describe 'with an object equals to the diamond', ->
          it 'returns true', ->
            expect(@diamond.clone().equals(@diamond)).toBeTruthy()

        describe 'with an object not equals to the diamond', ->
          it 'returns false', ->
            expect(diamond(0,0,0,0,0,0,0).equals(@diamond)).toBeFalsy()

      pointOf(source, 'center').shouldBe(data.center)
      pointOf(source, 'topCorner').shouldBe(data.topCorner)
      pointOf(source, 'bottomCorner').shouldBe(data.bottomCorner)
      pointOf(source, 'leftCorner').shouldBe(data.leftCorner)
      pointOf(source, 'rightCorner').shouldBe(data.rightCorner)
      pointOf(source, 'topLeftEdge').shouldBe(data.topLeftEdge)
      pointOf(source, 'topRightEdge').shouldBe(data.topRightEdge)
      pointOf(source, 'bottomRightEdge').shouldBe(data.bottomRightEdge)
      pointOf(source, 'bottomLeftEdge').shouldBe(data.bottomLeftEdge)

      describe 'its topLeftQuadrant method', ->
        it 'returns a triangle', ->
          quad = @diamond.topLeftQuadrant()
          expect(quad.a).toBeSamePoint(data.topLeftQuadrant.a)
          expect(quad.b).toBeSamePoint(data.topLeftQuadrant.b)
          expect(quad.c).toBeSamePoint(data.topLeftQuadrant.c)

      describe 'its topRightQuadrant method', ->
        it 'returns a triangle', ->
          quad = @diamond.topRightQuadrant()
          expect(quad.a).toBeSamePoint(data.topRightQuadrant.a)
          expect(quad.b).toBeSamePoint(data.topRightQuadrant.b)
          expect(quad.c).toBeSamePoint(data.topRightQuadrant.c)

      describe 'its bottomLeftQuadrant method', ->
        it 'returns a triangle', ->
          quad = @diamond.bottomLeftQuadrant()
          expect(quad.a).toBeSamePoint(data.bottomLeftQuadrant.a)
          expect(quad.b).toBeSamePoint(data.bottomLeftQuadrant.b)
          expect(quad.c).toBeSamePoint(data.bottomLeftQuadrant.c)

      describe 'its bottomRightQuadrant method', ->
        it 'returns a triangle', ->
          quad = @diamond.bottomRightQuadrant()
          expect(quad.a).toBeSamePoint(data.bottomRightQuadrant.a)
          expect(quad.b).toBeSamePoint(data.bottomRightQuadrant.b)
          expect(quad.c).toBeSamePoint(data.bottomRightQuadrant.c)


      # Path API
      lengthOf(source).shouldBe(data.length)

      # Surface API
      acreageOf(source).shouldBe(data.acreage)

      describe 'its contains method', ->
        describe 'with a point inside', ->
          it 'returns true', ->
            expect(@diamond.contains @diamond.center()).toBeTruthy()

        describe 'with a point outside', ->
          it 'returns false', ->
            expect(@diamond.contains -10, -10).toBeFalsy()

      # Geometry API
      geometry(source).shouldBe.closedGeometry()
      geometry(source).shouldBe.translatable()
      geometry(source).shouldBe.rotatable()
      geometry(source).shouldBe.scalable()

      describe 'its top method', ->
        it 'returnss the diamond top', ->
          expect(@diamond.top()).toBeClose(data.top)

      describe 'its bottom method', ->
        it 'returnss the diamond bottom', ->
          expect(@diamond.bottom()).toBeClose(data.bottom)

      describe 'its left method', ->
        it 'returnss the diamond left', ->
          expect(@diamond.left()).toBeClose(data.left)

      describe 'its right method', ->
        it 'returnss the diamond right', ->
          expect(@diamond.right()).toBeClose(data.right)

      describe 'its bounds method', ->
        it 'returnss the diamond bounds', ->
          expect(@diamond.bounds()).toEqual(data.bounds)


      # Drawing API
      testDrawingOf(source)
