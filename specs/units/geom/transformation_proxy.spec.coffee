
describe 'TransformationProxy', ->
  describe 'instanciated with a target geometry', ->
    beforeEach ->
      addPointMatchers this
      @proxy = new agt.geom.TransformationProxy rectangle(0,0,10,10)
      @proxyableMethods = [
        'points'
        'pathPointAt'
        'pathOrientationAt'
      ]

    it 'has detected the proxyable methods', ->
      for proxied in @proxyableMethods
        expect(@proxy.proxied().indexOf proxied).not.toBe(-1)

    it 'is able to proxy the found methods', ->
      expect(@proxy.points()).toEqual(@proxy.geometry.points())

    describe 'when provided with a matrix', ->
      beforeEach ->
        m = matrix()
        m.scale 2, 2
        @proxy.matrix = m

      describe 'the proxied method points', ->
        it 'transforms points in the array', ->
          geomPoints = @proxy.geometry.points()
          proxyPoints = @proxy.points()

          for p,i in proxyPoints
            expect(p).toBeSamePoint(geomPoints[i].scale 2)

      describe 'the proxied method pathPointAt', ->
        it 'transforms the resulting point', ->
          expect(@proxy.pathPointAt 0.5).toBePoint(20, 20)

      describe 'the proxied method pathOrientationAt', ->
        it 'transforms the resulting angle', ->
          m = matrix()
          m.rotate Math.PI
          @proxy.matrix = m
          expect(@proxy.pathOrientationAt 0.5)
          .toBe(@proxy.geometry.pathOrientationAt(0.5) + Math.PI)
