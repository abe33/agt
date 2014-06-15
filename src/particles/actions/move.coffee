
class agt.particles.actions.Move extends agt.particles.actions.BaseAction
  process: (particle) ->
    particle.lastPosition.x = particle.position.x
    particle.lastPosition.y = particle.position.y
    particle.position.x += particle.velocity.x * @biasInSeconds
    particle.position.y += particle.velocity.y * @biasInSeconds
