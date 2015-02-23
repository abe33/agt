
Point = agt.geom.Point
Particle = agt.particles.Particle
ConditionalForce = agt.particles.actions.ConditionalForce

describe 'ConditionalForce', ->
  [force, particle] = []
  beforeEach ->
    particle = new Particle
    particle.init()

    force = new ConditionalForce new Point(10, 10), (p) ->
      p.position.x is 0

  describe 'when the condition is met', ->
    it 'modifies the particle velocity based on the vector', ->

      force.prepare 500, 0.5, 500
      force.process particle

      expect(particle.velocity.x).toBe(5)
      expect(particle.velocity.y).toBe(5)

  describe 'when the condition is not met', ->
    it 'does not modify the particle velocity', ->
      particle.position.x = 1

      force.prepare 500, 0.5, 500
      force.process particle

      expect(particle.velocity.x).toBe(0)
      expect(particle.velocity.y).toBe(0)
