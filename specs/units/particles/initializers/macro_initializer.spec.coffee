{Random, NoRandom} = agt.random
Particle = agt.particles.Particle
MacroInitializer = agt.particles.initializers.MacroInitializer
Life = agt.particles.initializers.Life
Explosion = agt.particles.initializers.Explosion

describe 'MacroInitializer', ->
  describe 'when instanciated with several initializers', ->
    it 'should call them', ->
      particle = new Particle
      initializer = new MacroInitializer([
        new Life(100),
        new Explosion(
          0, 10, 0, 1,
          new Random(new NoRandom(0.5))
        )
      ])
      particle.init()
      initializer.initialize particle

      expect(particle.maxLife).toBe(100)
      expect(particle.velocity.x).toBe(Math.cos(0.5)*5)
      expect(particle.velocity.y).toBe(Math.sin(0.5)*5)
