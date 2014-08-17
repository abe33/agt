namespace('agt.particles.actions')
# Public:
class agt.particles.actions.Force extends agt.particles.actions.BaseAction

  ### Public ###

  constructor: (@vector=new agt.geom.Point) ->

  process: (particle) ->
    particle.velocity.x += @vector.x * @biasInSeconds
    particle.velocity.y += @vector.y * @biasInSeconds
