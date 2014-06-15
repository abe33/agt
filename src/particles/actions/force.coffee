Point = agt.geom.Point

class agt.particles.actions.Force extends agt.particles.actions.BaseAction
  constructor: (@vector=new Point) ->
  process: (particle) ->
    particle.velocity.x += @vector.x * @biasInSeconds
    particle.velocity.y += @vector.y * @biasInSeconds
