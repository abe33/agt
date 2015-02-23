
Rectangle = agt.geom.Rectangle
DieOutsideSurface = agt.particles.actions.DieOutsideSurface
Particle = agt.particles.Particle

describe 'DieOutsideSurface', ->
  describe 'when instanciated with a surface', ->
    it 'should kill the particle on contact', ->
      particle = new Particle
      particle.init()
      particle.position.x = 5
      particle.position.y = 5

      action = new DieOutsideSurface new Rectangle 1,1,10,10

      action.process particle
      expect(particle.dead).not.toBeTruthy()

      particle.position.x = 0
      particle.position.y = 0

      action.process particle
      expect(particle.dead).toBeTruthy()
