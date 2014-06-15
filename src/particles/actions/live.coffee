
class agt.particles.actions.Live extends agt.particles.actions.BaseAction
  process: (particle) ->
    particle.life += @bias
    particle.die() if particle.life >= particle.maxLife
