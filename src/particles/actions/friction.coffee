
class agt.particles.actions.Friction extends agt.particles.actions.BaseAction
  constructor: (@amount=1) ->
  process: (particle) ->
    fx = particle.velocity.x * @biasInSeconds * @amount
    fy = particle.velocity.y * @biasInSeconds * @amount

    particle.velocity.x -= fx
    particle.velocity.y -= fy
