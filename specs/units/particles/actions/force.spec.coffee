
Point = agt.geom.Point
Particle = agt.particles.Particle
Force = agt.particles.actions.Force

describe 'Force', ->
  describe 'Created with a vector', ->
    it 'should modify the particle velocity based on the vector', ->
      particle = new Particle
      particle.init()

      force = new Force new Point 10, 10
      force.prepare 500, 0.5, 500
      force.process particle

      expect(particle.velocity.x).toBe(5)
      expect(particle.velocity.y).toBe(5)
