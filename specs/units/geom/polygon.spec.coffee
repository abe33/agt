

describe 'Polygon', ->
  beforeEach -> addPointMatchers this

  describe 'called without argument', ->
    it 'throws an error', ->
      expect(-> polygon()).toThrow()

  describe 'with less than three points', ->
    it 'throws an error', ->
      expect(-> polygon([point(), point()])).toThrow()

  eachPair polygonFactories, (k,v) ->
    {args, test} = v
    data = polygonData.call global, test()
    source = 'polygon'

    describe "called #{k}", ->
      beforeEach ->
        @polygon = polygon.apply global, args()

      it 'exists', ->
        expect(@polygon).toBeDefined()

      it 'has its vertices defined', ->
        expect(@polygon.vertices).toEqual(test())

      describe 'its clone method', ->
        it 'returns a copy of the polygon', ->
          expect(@polygon.clone()).toEqual(@polygon)

      describe 'its toSource method', ->
        it 'returns the code source of the polygon', ->
          expect(@polygon.toSource()).toBe(data.source)

      describe 'its points method', ->
        it 'returns the vertices with the first being copy at last', ->
          expect(@polygon.points())
            .toEqual(@polygon.vertices.concat @polygon.vertices[0])

      describe 'its triangles method', ->
        it 'returns two triangles', ->
          expect(@polygon.triangles().length).toBe(2)

      describe 'its contains method', ->
        describe 'with a point in the geometry', ->
          it 'returns true', ->
            expect(@polygon.contains 1, 2).toBeTruthy()

        describe 'with a point off the geometry', ->
          it 'returns false', ->
            expect(@polygon.contains -10, -10).toBeFalsy()

      describe 'its rotateAroundCenter method', ->
        it 'rotates the polygon', ->
          center = @polygon.center()
          @polygon.rotateAroundCenter(10)
          for vertex,i in @polygon.vertices
            expect(vertex)
              .toBeSamePoint(data.vertices[i].rotateAround(center,10))

      describe 'its scaleAroundCenter method', ->
        it 'scales the polygon', ->
          center = @polygon.center()
          @polygon.scaleAroundCenter(2)
          for vertex,i in @polygon.vertices
            pt = center.add data.vertices[i].subtract(center).scale(2)
            expect(vertex).toBeSamePoint(pt)

      acreageOf(source).shouldBe(16)
      lengthOf(source).shouldBe(16)

      geometry(source).shouldBe.closedGeometry()
      geometry(source).shouldBe.translatable()
      geometry(source).shouldBe.rotatable()
      geometry(source).shouldBe.scalable()

      # Drawing API
      testDrawingOf(source)
