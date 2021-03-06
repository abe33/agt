Point = agt.geom.Point

Ponctual = agt.particles.emitters.Ponctual

describe 'Ponctual', ->
  describe 'when instanciated with a point', ->
    beforeEach -> @emitter = new Ponctual new Point

    describe 'its get method', ->
      it 'should return a copy of the specified point', ->
        pt = @emitter.get()
        expect(pt.x).toEqual(@emitter.point.x)
        expect(pt.y).toEqual(@emitter.point.y)
        expect(pt).not.toBe(@emitter.point)
