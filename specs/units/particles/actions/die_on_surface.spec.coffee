
Rectangle = agt.geom.Rectangle
DieOnSurface = agt.particles.actions.DieOnSurface
Particle = agt.particles.Particle

describe 'DieOnSurface', ->
  describe 'when instanciated with a surface', ->
    it 'should kill the particle on contact', ->
      particle = new Particle
      particle.init()
      action = new DieOnSurface new Rectangle 1,1,10,10

      action.process particle
      expect(particle.dead).not.toBeTruthy()

      particle.position.x = 5
      particle.position.y = 5
      action.process particle
      expect(particle.dead).toBeTruthy()
