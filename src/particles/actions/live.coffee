namespace('agt.particles.actions')
# Public:
class agt.particles.actions.Live extends agt.particles.actions.BaseAction

  ### Public ###

  process: (particle) ->
    particle.life += @bias
    particle.die() if particle.life >= particle.maxLife
