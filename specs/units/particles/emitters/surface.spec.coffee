{Random, NoRandom} = agt.random
Rectangle = agt.geom.Rectangle
Surface = agt.particles.emitters.Surface

describe 'Surface', ->
  describe 'when instanciated with a surface and a randomizer', ->
    beforeEach ->
      @emitter = new Surface(
        new Rectangle(0, 0, 10, 10),
        new Random(new NoRandom(0.5))
      )

    it 'should return a point within the surface', ->
      pt = @emitter.get()
      expect(pt.x).toBe(5)
      expect(pt.y).toBe(5)

  describe 'when instanciated without random', ->
    it 'should set a default random object', ->
      expect(new Surface().random).toBeDefined()
